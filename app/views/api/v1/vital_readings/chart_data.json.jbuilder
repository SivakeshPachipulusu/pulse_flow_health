json.patient_id @patient.id
json.patient_mrn @patient.mrn
json.generated_at Time.current.iso8601

json.series do
  json.heart_rate       @readings.map { |r| { t: r.recorded_at.iso8601, v: r.heart_rate } }.compact
  json.spo2             @readings.map { |r| { t: r.recorded_at.iso8601, v: r.spo2 } }.compact
  json.temperature      @readings.map { |r| { t: r.recorded_at.iso8601, v: r.temperature } }.compact
  json.respiratory_rate @readings.map { |r| { t: r.recorded_at.iso8601, v: r.metrics["respiratory_rate"] } }.compact
end

latest = @readings.last
if latest
  json.latest_reading do
    json.id             latest.id
    json.heart_rate     latest.heart_rate
    json.spo2           latest.spo2
    json.blood_pressure latest.blood_pressure
    json.temperature    latest.temperature
    json.status         latest.status
    json.critical       latest.critical?
    json.recorded_at    latest.recorded_at.iso8601
  end
else
  json.latest_reading nil
end
