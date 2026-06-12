Rails.application.routes.draw do
  mount Sidekiq::Web => "/sidekiq"

  namespace :api do
    namespace :v1 do
      resources :patients, only: [:index, :show, :create, :update] do
        resources :vital_readings, only: [:index, :show, :create] do
          collection do
            get :chart_data
          end
        end
      end
    end
  end

  # React app catches all non-API routes
  get "*path", to: "application#spa", constraints: ->(req) { !req.path.start_with?("/api", "/rails", "/sidekiq") }
  root "application#spa"
end
