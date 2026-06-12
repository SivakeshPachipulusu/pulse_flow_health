module Api
  class BaseController < ApplicationController
    protect_from_forgery with: :null_session
    before_action :authenticate_request!

    rescue_from ActiveRecord::RecordNotFound, with: :not_found
    rescue_from ActiveRecord::RecordInvalid, with: :unprocessable
    rescue_from ActionController::ParameterMissing, with: :bad_request

    private

    def authenticate_request!
      token = request.headers["Authorization"]&.split(" ")&.last
      return render_unauthorized unless token

      payload = JwtService.decode(token)
      return render_unauthorized unless payload

      @current_patient_mrn = payload["sub"]
    rescue JWT::DecodeError
      render_unauthorized
    end

    def not_found(err)
      render json: { error: err.message }, status: :not_found
    end

    def unprocessable(err)
      render json: { error: err.message }, status: :unprocessable_entity
    end

    def bad_request(err)
      render json: { error: err.message }, status: :bad_request
    end

    def render_unauthorized
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end
end
