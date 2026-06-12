module Api
  module V1
    class VitalReadingsController < Api::BaseController
      before_action :load_patient

      def index
        readings = @patient.vital_readings.recent
        render json: { data: VitalReadingSerializer.render_as_hash(readings) }
      end

      def show
        reading = @patient.vital_readings.find(params[:id])
        render json: { data: VitalReadingSerializer.render_as_hash(reading) }
      end

      def create
        result = Vitals::IngestionService.new(patient: @patient, payload: vital_params.to_h).call

        if result.success
          render json: { data: VitalReadingSerializer.render_as_hash(result.vital_reading) }, status: :created
        else
          render json: { errors: result.errors }, status: :unprocessable_entity
        end
      end

      def chart_data
        @readings = @patient.vital_readings.for_patient(@patient.id).last(100)
      end

      private

      def load_patient
        @patient = Patient.find(params[:patient_id])
      end

      def vital_params
        params.require(:vital_reading).permit(
          :device_id, :device_type, :recorded_at,
          :heart_rate, :spo2, :blood_pressure, :temperature, :respiratory_rate,
          metrics: {}
        )
      end
    end
  end
end
