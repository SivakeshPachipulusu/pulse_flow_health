require "rails_helper"

RSpec.describe Vitals::IngestionService do
  let(:patient) { create(:patient) }
  let(:valid_payload) do
    {
      heart_rate:        82,
      spo2:              97,
      temperature:       36.9,
      respiratory_rate:  16,
      blood_pressure:    "118/76",
      device_id:         "DEV-001",
      device_type:       "Smart Patch",
      recorded_at:       Time.current.iso8601
    }
  end

  let(:ehr_client) { instance_double(Vitals::EhrClient) }

  before do
    allow(ehr_client).to receive(:fetch_patient_thresholds).and_return({ "max_hr" => 110 })
    allow(Vitals::AnonymizeAndArchiveJob).to receive(:perform_later)
  end

  def call(payload = valid_payload)
    described_class.new(patient: patient, payload: payload, ehr_client: ehr_client).call
  end

  describe "happy path" do
    it "returns success" do
      expect(call.success).to be true
    end

    it "persists a VitalReading" do
      expect { call }.to change { patient.vital_readings.count }.by(1)
    end

    it "enqueues the archive job" do
      result = call
      expect(Vitals::AnonymizeAndArchiveJob).to have_received(:perform_later).with(result.vital_reading.id)
    end

    it "stores thresholds in the metrics jsonb" do
      result = call
      expect(result.vital_reading.metrics["thresholds"]).to eq({ "max_hr" => 110 })
    end
  end

  describe "flagging critical vitals" do
    it "flags a reading with high heart rate" do
      result = call(valid_payload.merge(heart_rate: 135))
      expect(result.vital_reading.status).to eq("flagged")
    end

    it "flags a reading with low spo2" do
      result = call(valid_payload.merge(spo2: 87))
      expect(result.vital_reading.status).to eq("flagged")
    end
  end

  describe "validation failures" do
    it "fails when heart_rate is missing" do
      result = call(valid_payload.except(:heart_rate))
      expect(result.success).to be false
      expect(result.errors).to include("Missing required metric: heart_rate")
    end

    it "fails when heart_rate is out of physiological range" do
      result = call(valid_payload.merge(heart_rate: 300))
      expect(result.success).to be false
    end

    it "fails when spo2 is below minimum threshold" do
      result = call(valid_payload.merge(spo2: 30))
      expect(result.success).to be false
    end
  end

  describe "EHR connection failure" do
    it "falls back gracefully and still saves the reading" do
      allow(ehr_client).to receive(:fetch_patient_thresholds)
        .and_raise(Vitals::EhrClient::EhrConnectionError, "timeout")

      result = call
      expect(result.success).to be true
      expect(result.vital_reading).to be_persisted
    end
  end
end
