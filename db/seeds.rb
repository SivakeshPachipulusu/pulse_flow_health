puts "Seeding patients and vitals..."

patients_data = [
  { first_name: "Margaret", last_name: "Chen",    mrn: "MRN-10041", gender: "female", dob: "1952-03-14", ward: "Cardiology",  status: "active",     diagnosis: "Hypertensive heart disease, atrial fibrillation" },
  { first_name: "David",    last_name: "Okafor",  mrn: "MRN-10042", gender: "male",   dob: "1978-07-22", ward: "ICU",          status: "active",     diagnosis: "Post-op cardiac bypass, monitoring for arrhythmia" },
  { first_name: "Sandra",   last_name: "Kowalski",mrn: "MRN-10043", gender: "female", dob: "1965-11-03", ward: "Neurology",   status: "active",     diagnosis: "Ischemic stroke recovery, left-side weakness" },
  { first_name: "James",    last_name: "Patel",   mrn: "MRN-10044", gender: "male",   dob: "1940-05-30", ward: "Geriatrics",  status: "active",     diagnosis: "COPD exacerbation, type-2 diabetes" },
  { first_name: "Aisha",    last_name: "Nwosu",   mrn: "MRN-10045", gender: "female", dob: "1991-09-18", ward: "Cardiology",  status: "active",     diagnosis: "Mitral valve prolapse, monitoring" },
  { first_name: "Robert",   last_name: "Tanaka",  mrn: "MRN-10046", gender: "male",   dob: "1955-01-07", ward: "ICU",          status: "active",     diagnosis: "Acute respiratory distress, post-COVID complications" },
  { first_name: "Elena",    last_name: "Vasquez", mrn: "MRN-10047", gender: "female", dob: "1983-04-25", ward: "Cardiology",  status: "discharged", diagnosis: "SVT resolved, discharged with beta blockers" },
  { first_name: "Thomas",   last_name: "Brennan", mrn: "MRN-10048", gender: "male",   dob: "1948-12-11", ward: "Geriatrics",  status: "active",     diagnosis: "Heart failure stage III, fluid retention" },
]

patients_data.each do |d|
  patient = Patient.find_or_create_by!(mrn: d[:mrn]) do |p|
    p.first_name      = d[:first_name]
    p.last_name       = d[:last_name]
    p.gender          = d[:gender]
    p.date_of_birth   = d[:dob]
    p.ward            = d[:ward]
    p.status          = d[:status]
    p.diagnosis_notes = d[:diagnosis]
    p.email           = "#{d[:first_name].downcase}.#{d[:last_name].downcase}@hospital.org"
  end

  next if patient.vital_readings.count > 5

  # 48 readings spread over last 24 hours (one every 30 mins)
  48.times do |i|
    recorded_at = (24.hours - (i * 30.minutes)).ago

    # Simulate slightly noisy vitals - drift them slightly to look real
    base_hr   = (d[:ward] == "ICU" ? 95 : 72) + rand(-5..5)
    base_spo2 = (d[:ward] == "ICU" ? 93 : 98) + rand(-2..1)

    hr   = base_hr + (Math.sin(i * 0.4) * 8).round
    spo2 = [base_spo2 + rand(-1..1), 100].min
    temp = 36.5 + (rand * 1.2).round(1)
    rr   = 14 + rand(-2..4)
    sbp  = 115 + rand(-10..15)
    dbp  = 75 + rand(-8..10)

    patient.vital_readings.create!(
      device_id:   "DEV-#{d[:ward].upcase[0..2]}-#{patient.mrn[-3..]}",
      device_type: ["Holter Monitor", "Pulse Oximeter", "Smart Patch"].sample,
      metrics: {
        heart_rate:        hr,
        spo2:              spo2,
        temperature:       temp,
        respiratory_rate:  rr,
        blood_pressure:    "#{sbp}/#{dbp}",
      },
      status:      (hr > 120 || spo2 < 90) ? "flagged" : "received",
      recorded_at: recorded_at
    )
  end

  puts "  #{patient.full_name} (#{patient.mrn}) — #{patient.vital_readings.count} readings"
end

puts "Done. #{Patient.count} patients, #{VitalReading.count} readings total."
