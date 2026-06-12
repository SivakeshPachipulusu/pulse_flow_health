require "rails_helper"

RSpec.describe "Dashboard UI", type: :feature, js: true do
  let!(:patient) { create(:patient, first_name: "Grace", last_name: "Kim", ward: "Cardiology") }
  before { create_list(:vital_reading, 5, patient: patient) }

  it "loads the patient list page with the app title" do
    visit "/"
    expect(page).to have_css("span.navbar-brand", text: /PulseFlow/i, wait: 10)
  end

  it "shows the patient table with seeded data" do
    visit "/"
    expect(page).to have_css("table", wait: 10)
    expect(page).to have_content("Grace Kim", wait: 10)
  end

  it "filters patients by name as user types" do
    create(:patient, first_name: "John", last_name: "Doe", ward: "ICU")
    visit "/"
    expect(page).to have_content("Grace Kim", wait: 10)
    expect(page).to have_content("John Doe", wait: 10)

    fill_in placeholder: "Search name / MRN / notes…", with: "Grace"
    expect(page).to have_content("Grace Kim", wait: 10)
    expect(page).not_to have_content("John Doe", wait: 5)
  end

  it "filters patients by ward as user types" do
    create(:patient, first_name: "John", last_name: "Doe", ward: "ICU")
    visit "/"
    expect(page).to have_content("Grace Kim", wait: 10)

    fill_in placeholder: "Ward", with: "Cardio"
    expect(page).to have_content("Grace Kim", wait: 10)
    expect(page).not_to have_content("John Doe", wait: 5)
  end

  it "navigates to patient dashboard on View click" do
    visit "/"
    expect(page).to have_content("Grace Kim", wait: 10)
    click_button "View", match: :first
    expect(page).to have_content("Grace Kim", wait: 10)
    expect(page).to have_content("Heart Rate", wait: 10)
  end

  it "shows all metric cards on the patient dashboard" do
    visit "/"
    expect(page).to have_content("Grace Kim", wait: 10)
    click_button "View", match: :first
    expect(page).to have_content("SpO₂", wait: 10)
    expect(page).to have_content("Temperature", wait: 10)
    expect(page).to have_content("Blood Pressure", wait: 10)
  end

  it "shows the ingest test reading panel on the dashboard" do
    visit "/"
    expect(page).to have_content("Grace Kim", wait: 10)
    click_button "View", match: :first
    expect(page).to have_content("Post Test Reading", wait: 10)
  end
end
