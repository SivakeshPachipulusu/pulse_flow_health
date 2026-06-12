class PatientSerializer < Blueprinter::Base
  identifier :id

  fields :mrn, :first_name, :last_name, :gender, :date_of_birth,
         :email, :phone, :ward, :status, :diagnosis_notes,
         :created_at, :updated_at

  field :full_name do |patient|
    patient.full_name
  end

  view :with_latest_vitals do
    association :vital_readings, blueprint: VitalReadingSerializer do |patient|
      # Sort in Ruby to use the preloaded association — avoids N+1 per patient
      patient.vital_readings.sort_by(&:recorded_at).last(5)
    end
  end
end
