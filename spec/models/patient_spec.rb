require "rails_helper"

RSpec.describe Patient, type: :model do
  subject(:patient) { build(:patient) }

  it { is_expected.to have_many(:vital_readings).dependent(:destroy) }
  it { is_expected.to validate_presence_of(:first_name) }
  it { is_expected.to validate_presence_of(:last_name) }
  it { is_expected.to validate_presence_of(:mrn) }
  it { is_expected.to validate_uniqueness_of(:mrn) }
  it { is_expected.to validate_inclusion_of(:status).in_array(Patient::STATUSES) }

  describe "#full_name" do
    it "joins first and last name" do
      patient = build(:patient, first_name: "Jane", last_name: "Doe")
      expect(patient.full_name).to eq("Jane Doe")
    end
  end

  describe ".search_by_name_and_notes" do
    let!(:p1) { create(:patient, first_name: "Amelia", last_name: "Rodriguez") }
    let!(:p2) { create(:patient, first_name: "Bob", last_name: "Smith", diagnosis_notes: "hypertension chronic") }

    it "finds by first name" do
      expect(Patient.search_by_name_and_notes("Amelia")).to include(p1)
    end

    it "finds by diagnosis notes" do
      expect(Patient.search_by_name_and_notes("hypertension")).to include(p2)
    end

    it "doesn't surface unrelated patients" do
      expect(Patient.search_by_name_and_notes("Amelia")).not_to include(p2)
    end
  end
end
