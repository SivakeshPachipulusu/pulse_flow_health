require "rails_helper"

RSpec.describe "Vital Readings API", type: :request do
  let!(:patient) { create(:patient) }
  let(:json_headers) { { "Content-Type" => "application/json", "Accept" => "application/json" } }

  # Stub the EHR service so ingestion doesn't try to make real HTTP calls
  before do
    stub_request(:get, /ehr\.example\.com.*thresholds/)
      .to_return(status: 200, body: { max_hr: 120, min_spo2: 90 }.to_json,
                 headers: { "Content-Type" => "application/json" })
  end

  describe "GET /api/v1/patients/:id/vital_readings" do
    before { create_list(:vital_reading, 3, patient: patient) }

    it "returns vital readings for the patient" do
      get "/api/v1/patients/#{patient.id}/vital_readings", headers: { "Accept" => "application/json" }
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["data"].length).to eq(3)
      expect(body["data"].first["patient_id"]).to eq(patient.id)
    end
  end

  describe "GET /api/v1/patients/:id/vital_readings/chart_data" do
    before { create_list(:vital_reading, 5, patient: patient) }

    it "returns time-series chart data" do
      get "/api/v1/patients/#{patient.id}/vital_readings/chart_data", headers: { "Accept" => "application/json" }
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["series"].keys).to include("heart_rate", "spo2", "temperature", "respiratory_rate")
    end

    it "includes latest reading snapshot" do
      get "/api/v1/patients/#{patient.id}/vital_readings/chart_data", headers: { "Accept" => "application/json" }
      body = JSON.parse(response.body)
      expect(body["latest_reading"]).to be_present
      expect(body["latest_reading"]["heart_rate"]).to be_present
    end
  end

  describe "POST /api/v1/patients/:id/vital_readings" do
    let(:valid_payload) do
      {
        vital_reading: {
          heart_rate:        82,
          spo2:              98,
          temperature:       98.6,
          respiratory_rate:  15,
          blood_pressure:    "118/76",
          device_id:         "DEV-REQ-001",
          device_type:       "Request Test",
          recorded_at:       Time.current.iso8601
        }
      }
    end

    it "creates a new vital reading" do
      post "/api/v1/patients/#{patient.id}/vital_readings",
           params: valid_payload.to_json, headers: json_headers
      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["data"]["status"]).to eq("received")
      expect(body["data"]["patient_id"]).to eq(patient.id)
    end

    it "flags critical readings (HR > 120 or SpO2 < 90)" do
      critical = valid_payload.deep_merge(vital_reading: { heart_rate: 135, spo2: 87 })
      post "/api/v1/patients/#{patient.id}/vital_readings",
           params: critical.to_json, headers: json_headers
      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["data"]["status"]).to eq("flagged")
    end

    it "returns errors for missing required vitals" do
      post "/api/v1/patients/#{patient.id}/vital_readings",
           params: { vital_reading: { device_id: "X" } }.to_json, headers: json_headers
      body = JSON.parse(response.body)
      expect(body["errors"]).to be_present
    end

    it "returns 404 for unknown patient" do
      post "/api/v1/patients/00000000-0000-0000-0000-000000000000/vital_readings",
           params: valid_payload.to_json, headers: json_headers
      expect(response).to have_http_status(:not_found)
    end
  end
end
