require "rails_helper"

RSpec.describe "Patients API", type: :request do
  let!(:alice) { create(:patient, first_name: "Alice", last_name: "Hart", ward: "Cardiology") }
  let!(:bob)   { create(:patient, first_name: "Bob",   last_name: "Chen",  ward: "ICU") }

  describe "GET /api/v1/patients" do
    it "returns all patients" do
      get "/api/v1/patients", headers: { "Accept" => "application/json" }
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["total"]).to be >= 2
      names = body["data"].map { |p| p["first_name"] }
      expect(names).to include("Alice", "Bob")
    end

    it "filters patients by name with ?q=" do
      get "/api/v1/patients", params: { q: "Alice" }, headers: { "Accept" => "application/json" }
      body = JSON.parse(response.body)
      names = body["data"].map { |p| p["first_name"] }
      expect(names).to include("Alice")
      expect(names).not_to include("Bob")
    end

    it "filters patients by ward with ?ward=" do
      get "/api/v1/patients", params: { ward: "ICU" }, headers: { "Accept" => "application/json" }
      body = JSON.parse(response.body)
      wards = body["data"].map { |p| p["ward"] }
      expect(wards).to all(match(/ICU/i))
    end

    it "partial ward filter is case-insensitive" do
      get "/api/v1/patients", params: { ward: "cardio" }, headers: { "Accept" => "application/json" }
      body = JSON.parse(response.body)
      names = body["data"].map { |p| p["first_name"] }
      expect(names).to include("Alice")
      expect(names).not_to include("Bob")
    end
  end

  describe "GET /api/v1/patients/:id" do
    it "returns a single patient" do
      get "/api/v1/patients/#{alice.id}", headers: { "Accept" => "application/json" }
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["data"]["id"]).to eq(alice.id)
      expect(body["data"]["first_name"]).to eq("Alice")
    end

    it "returns 404 for unknown patient" do
      get "/api/v1/patients/00000000-0000-0000-0000-000000000000", headers: { "Accept" => "application/json" }
      expect(response).to have_http_status(:not_found)
    end
  end
end
