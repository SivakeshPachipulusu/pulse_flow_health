class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  def spa
    render file: Rails.root.join("public/index.html"), layout: false
  end
end
