# frozen_string_literal: true

module Api
  module V1
    module Users
      class SessionsController < Devise::SessionsController
        respond_to :json

        private

        def respond_with(resource, _opts = {})
          if resource.persisted?
            render json: { message: I18n.t('logged_in_successfully'), user: resource }, status: :ok
          else
            render json: { error: I18n.t('errors.messages.invalid_email_or_password') }, status: :unauthorized
          end
        end

        def respond_to_on_destroy
          if current_user
            render json: { message: I18n.t('logged_out_successfully') }, status: :ok
          else
            render json: { message: I18n.t('errors.messages.logout_failed') }, status: :unauthorized
          end
        end
      end
    end
  end
end
