require "rails_helper"

RSpec.describe VitalReading, type: :model do
  it { is_expected.to belong_to(:patient) }
  it { is_expected.to validate_presence_of(:metrics) }
  it { is_expected.to validate_presence_of(:recorded_at) }
  it { is_expected.to validate_inclusion_of(:status).in_array(VitalReading::STATUSES) }

  describe "#critical?" do
    it "is critical when heart rate is over 120" do
      r = build(:vital_reading, metrics: { "heart_rate" => 130, "spo2" => 97 })
      expect(r.critical?).to be true
    end

    it "is critical when spo2 drops below 90" do
      r = build(:vital_reading, metrics: { "heart_rate" => 75, "spo2" => 87 })
      expect(r.critical?).to be true
    end

    it "is not critical for normal readings" do
      r = build(:vital_reading, metrics: { "heart_rate" => 72, "spo2" => 98 })
      expect(r.critical?).to be false
    end
  end

  describe "JSONB metric helpers" do
    let(:reading) do
      build(:vital_reading, metrics: {
        "heart_rate" => 88, "spo2" => 97,
        "blood_pressure" => "120/80", "temperature" => 37.1
      })
    end

    it { expect(reading.heart_rate).to eq(88) }
    it { expect(reading.spo2).to eq(97) }
    it { expect(reading.blood_pressure).to eq("120/80") }
    it { expect(reading.temperature).to eq(37.1) }
  end

  describe ".for_patient scope" do
    it "returns readings in ascending order by created_at" do
      patient  = create(:patient)
      newer    = create(:vital_reading, patient: patient, recorded_at: 1.hour.ago)
      older    = create(:vital_reading, patient: patient, recorded_at: 3.hours.ago)
      expect(VitalReading.for_patient(patient.id).first).to eq(older)
      expect(VitalReading.for_patient(patient.id).last).to eq(newer)
    end
  end
end
