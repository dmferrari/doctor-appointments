# frozen_string_literal: true

module Api
  module V1
    module Users
      class SessionsController < Devise::SessionsController
        before_action :configure_sign_in_params, only: [:create]

        # POST /api/v1/users/sign_in
        def create
          super do |user|
            render json: { jwt: current_token, user: }, status: :created and return if user
          end
        end

        # DELETE /api/v1/users/sign_out
        def destroy
          super do
            head :no_content
          end
        end

        private

        def configure_sign_in_params
          devise_parameter_sanitizer.permit(:sign_in, keys: %i[email password])
        end

        def respond_with(resource, _opts = {})
          render json: resource
        end

        def respond_to_on_destroy
          head :no_content
        end
      end
    end
  end
end
