module Vitals
  class AnonymizeAndArchiveJob < ApplicationJob
    queue_as :vitals
    sidekiq_options retry: 3, dead: false

    RETRY_ERRORS = [ActiveRecord::ConnectionNotEstablished, PG::ConnectionBad].freeze

    retry_on *RETRY_ERRORS, wait: :polynomially_longer, attempts: 3

    discard_on ActiveRecord::RecordNotFound do |job, error|
      Rails.logger.warn("[AnonymizeAndArchiveJob] Record gone, discarding: #{error.message}")
    end

    def perform(vital_reading_id)
      reading = VitalReading.find(vital_reading_id)

      anonymize!(reading)
      archive!(reading)

      reading.update!(anonymized: true, archived: true, status: "archived")
      Rails.logger.info("[AnonymizeAndArchiveJob] Done for reading #{vital_reading_id}")
    end

    private

    def anonymize!(reading)
      # Strip device identifiers from the stored metrics copy
      reading.metrics.delete("device_serial")
      reading.metrics.delete("raw_payload")
      reading.save!
    end

    def archive!(reading)
      # In production this would write a PDF summary or raw binary log
      # to Azure Blob via Active Storage
      return unless Rails.env.production?

      pdf_content = generate_pdf_summary(reading)
      reading.patient.document.attach(
        io:           StringIO.new(pdf_content),
        filename:     "vitals_#{reading.id}.pdf",
        content_type: "application/pdf"
      )
    end

    def generate_pdf_summary(reading)
      "PulseFlow Vitals Summary\nPatient: #{reading.patient.mrn}\n" \
        "Recorded: #{reading.recorded_at}\nMetrics: #{reading.metrics.to_json}"
    end
  end
end
