require "sidekiq/web"

Rails.application.routes.draw do
  mount Sidekiq::Web => "/sidekiq"

  namespace :api do
    namespace :v1 do
      resources :patients, only: [:index, :show, :create, :update] do
        resources :vital_readings, only: [:index, :show, :create] do
          collection { get :chart_data }
        end
      end
    end
  end

  get "*path", to: "application#spa",
    constraints: ->(req) { !req.path.start_with?("/api", "/rails", "/sidekiq", "/assets") }
  root "application#spa"
end
