# frozen_string_literal: true

module Api
  module V1
    module Users
      class SessionsController < Devise::SessionsController
        respond_to :json

        private

        def respond_with(resource, _opts = {})
          if resource.persisted?
            render json: { message: 'Logged in successfully', user: resource }, status: :ok
          else
            render json: { error: 'Invalid email or password' }, status: :unauthorized
          end
        end

        def respond_to_on_destroy
          if current_user
            render json: { message: 'Logged out successfully' }, status: :ok
          else
            render json: { message: 'Logged out failure' }, status: :unauthorized
          end
        end
      end
    end
  end
end
