module Vitals
  class EhrClient
    BASE_URL = ENV.fetch("EHR_BASE_URL", "https://ehr.example.com/api/v1")
    TIMEOUT   = 5

    class EhrConnectionError < StandardError; end
    class EhrAuthError < StandardError; end

    def initialize(token: ENV["EHR_API_TOKEN"])
      @token = token
      @conn = build_connection
    end

    def fetch_patient_thresholds(patient_mrn)
      response = @conn.get("patients/#{patient_mrn}/thresholds")
      handle_response(response)
    rescue Faraday::ConnectionFailed, Faraday::TimeoutError => e
      raise EhrConnectionError, "EHR unreachable: #{e.message}"
    end

    private

    def build_connection
      Faraday.new(url: BASE_URL) do |f|
        f.request  :json
        f.response :json
        f.request  :retry, max: 2, interval: 0.5, exceptions: [Faraday::ConnectionFailed, Faraday::TimeoutError]
        f.adapter  Faraday.default_adapter
        f.options.timeout      = TIMEOUT
        f.options.open_timeout = TIMEOUT
        f.headers["Authorization"]  = "Bearer #{@token}"
        f.headers["X-Client-Name"]  = "PulseFlowHealth"
        f.headers["X-Client-Version"] = "1.0"
      end
    end

    def handle_response(response)
      case response.status
      when 200 then response.body
      when 401, 403 then raise EhrAuthError, "EHR auth failed (#{response.status})"
      else raise EhrConnectionError, "EHR error #{response.status}: #{response.body}"
      end
    end
  end
end
