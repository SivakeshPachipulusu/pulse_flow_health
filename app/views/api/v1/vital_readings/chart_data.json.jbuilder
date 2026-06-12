json.patient_id @patient.id
json.patient_mrn @patient.mrn
json.generated_at Time.current.iso8601

json.series do
  json.heart_rate @readings.map { |r| { t: r.recorded_at.iso8601, v: r.heart_rate } }.compact
  json.spo2       @readings.map { |r| { t: r.recorded_at.iso8601, v: r.spo2 } }.compact
  json.temperature @readings.map { |r| { t: r.recorded_at.iso8601, v: r.temperature } }.compact
  json.respiratory_rate @readings.map { |r|
    { t: r.recorded_at.iso8601, v: r.metrics["respiratory_rate"] }
  }.compact
end

json.latest_reading @readings.last do |reading|
  json.id           reading.id
  json.heart_rate   reading.heart_rate
  json.spo2         reading.spo2
  json.blood_pressure reading.blood_pressure
  json.temperature  reading.temperature
  json.status       reading.status
  json.critical     reading.critical?
  json.recorded_at  reading.recorded_at.iso8601
end
