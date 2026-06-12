class VitalReadingSerializer < Blueprinter::Base
  identifier :id

  fields :device_id, :device_type, :metrics, :status,
         :anonymized, :archived, :recorded_at,
         :created_at, :updated_at

  field :patient_id do |reading|
    reading.patient_id
  end

  field :heart_rate do |reading|
    reading.heart_rate
  end

  field :spo2 do |reading|
    reading.spo2
  end

  field :blood_pressure do |reading|
    reading.blood_pressure
  end

  field :temperature do |reading|
    reading.temperature
  end

  field :critical do |reading|
    reading.critical?
  end
end
