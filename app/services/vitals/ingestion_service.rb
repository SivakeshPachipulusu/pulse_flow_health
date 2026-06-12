module Vitals
  class IngestionService
    REQUIRED_KEYS  = %w[heart_rate].freeze
    MAX_HEART_RATE = 250
    MIN_HEART_RATE = 20
    MIN_SPO2       = 50

    Result = Data.define(:success, :vital_reading, :errors)

    def initialize(patient:, payload:, ehr_client: EhrClient.new)
      @patient    = patient
      @payload    = payload.deep_stringify_keys
      @ehr_client = ehr_client
      @errors     = []
    end

    def call
      validate_payload
      return failure if @errors.any?

      thresholds = fetch_ehr_thresholds
      metrics    = build_metrics(thresholds)
      reading    = persist!(metrics)

      Vitals::AnonymizeAndArchiveJob.perform_later(reading.id)

      Result.new(success: true, vital_reading: reading, errors: [])
    rescue ActiveRecord::RecordInvalid => e
      Result.new(success: false, vital_reading: nil, errors: [e.message])
    rescue Vitals::EhrClient::EhrConnectionError => e
      Rails.logger.warn("[IngestionService] EHR fetch failed, using defaults: #{e.message}")
      reading = persist!(build_metrics({}))
      Vitals::AnonymizeAndArchiveJob.perform_later(reading.id)
      Result.new(success: true, vital_reading: reading, errors: [])
    end

    private

    def validate_payload
      REQUIRED_KEYS.each do |key|
        @errors << "Missing required metric: #{key}" unless @payload.key?(key)
      end

      if (hr = @payload["heart_rate"]&.to_i)
        @errors << "heart_rate out of range" unless hr.between?(MIN_HEART_RATE, MAX_HEART_RATE)
      end

      if (spo2 = @payload["spo2"]&.to_i)
        @errors << "spo2 out of range" if spo2 < MIN_SPO2 || spo2 > 100
      end
    end

    def fetch_ehr_thresholds
      @ehr_client.fetch_patient_thresholds(@patient.mrn) || {}
    end

    def build_metrics(thresholds)
      {
        heart_rate:     @payload["heart_rate"]&.to_i,
        spo2:           @payload["spo2"]&.to_i,
        blood_pressure: @payload["blood_pressure"],
        temperature:    @payload["temperature"]&.to_f,
        respiratory_rate: @payload["respiratory_rate"]&.to_i,
        thresholds:     thresholds
      }.compact
    end

    def persist!(metrics)
      @patient.vital_readings.create!(
        metrics:     metrics,
        device_id:   @payload["device_id"],
        device_type: @payload["device_type"],
        recorded_at: @payload.fetch("recorded_at", Time.current),
        status:      metrics_critical?(metrics) ? "flagged" : "received"
      )
    end

    def metrics_critical?(metrics)
      return true if metrics[:heart_rate]&.> 120
      return true if metrics[:spo2]&.< 90
      false
    end

    def failure
      Result.new(success: false, vital_reading: nil, errors: @errors)
    end
  end
end
