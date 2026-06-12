class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  def spa
    render layout: "application"
  end
end
