require "rails_helper"

RSpec.describe Vitals::EhrClient do
  subject(:client) { described_class.new(token: "test-token") }

  describe "#fetch_patient_thresholds" do
    context "when the EHR responds successfully" do
      it "returns threshold data" do
        WebMock.stub_request(:get, /patients\/MRN-001\/thresholds/)
          .to_return(
            status: 200,
            body: { max_hr: 110, min_spo2: 90 }.to_json,
            headers: { "Content-Type" => "application/json" }
          )

        result = client.fetch_patient_thresholds("MRN-001")
        expect(result["max_hr"]).to eq(110)
      end
    end

    context "when the EHR returns 401" do
      it "raises EhrAuthError" do
        WebMock.stub_request(:get, /patients\/MRN-002\/thresholds/)
          .to_return(status: 401, body: "Unauthorized")

        expect { client.fetch_patient_thresholds("MRN-002") }
          .to raise_error(Vitals::EhrClient::EhrAuthError)
      end
    end

    context "when the connection times out" do
      it "raises EhrConnectionError" do
        WebMock.stub_request(:get, /patients\/MRN-003\/thresholds/)
          .to_timeout

        expect { client.fetch_patient_thresholds("MRN-003") }
          .to raise_error(Vitals::EhrClient::EhrConnectionError)
      end
    end
  end
end
