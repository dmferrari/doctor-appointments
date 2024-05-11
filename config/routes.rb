# frozen_string_literal: true

Rails.application.routes.draw do
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  # Secure Sidekiq web dashboard in production. Otherwise, keep it open
  if Rails.env.production?
    Sidekiq::Web.use Rack::Auth::Basic do |username, password|
      ActiveSupport::SecurityUtils.secure_compare(username, ENV.fetch('SIDEKIQ_USERNAME', nil)) &
        ActiveSupport::SecurityUtils.secure_compare(password, ENV.fetch('SIDEKIQ_PASSWORD', nil))
    end
  end

  devise_for :users, skip: %i[sessions registrations]

  get 'up' => 'rails/health#show', as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resources :doctors, only: [] do
        member do
          get 'availability'
          get 'working_hours'
        end
      end

      resources :appointments
    end
  end
end
