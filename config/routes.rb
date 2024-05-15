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

  devise_scope :user do
    post 'api/v1/users/login', to: 'api/v1/users/sessions#create', as: :user_login
    delete 'api/v1/users/logout', to: 'api/v1/users/sessions#destroy', as: :user_logout
  end

  get 'up' => 'rails/health#show', as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resources :doctors, only: [] do
        member do
          get 'availability(/:date)', to: 'doctors#availability', as: 'availability'
          get 'working_hours(/:date)', to: 'doctors#working_hours', as: 'working_hours'
        end
      end

      resources :appointments
    end
  end
end
