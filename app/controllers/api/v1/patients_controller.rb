module Api
  module V1
    class PatientsController < Api::BaseController
      def index
        patients = Patient.includes(:vital_readings)
        patients = patients.search_by_name_and_notes(params[:q]) if params[:q].present?
        patients = patients.by_ward(params[:ward]) if params[:ward].present?
        patients = patients.where(status: params[:status]) if params[:status].present?

        render json: { data: PatientSerializer.render_as_hash(patients, view: :with_latest_vitals) }
      end

      def show
        patient = Patient.includes(:vital_readings).find(params[:id])
        render json: { data: PatientSerializer.render_as_hash(patient, view: :with_latest_vitals) }
      end

      def create
        patient = Patient.create!(patient_params)
        render json: { data: PatientSerializer.render_as_hash(patient) }, status: :created
      end

      def update
        patient = Patient.find(params[:id])
        patient.update!(patient_params)
        render json: { data: PatientSerializer.render_as_hash(patient) }
      end

      private

      def patient_params
        params.require(:patient).permit(
          :first_name, :last_name, :mrn, :date_of_birth,
          :gender, :email, :phone, :diagnosis_notes, :ward, :status
        )
      end
    end
  end
end
