# frozen_string_literal: true

module Api
  module V1
    class DoctorsController < Api::V1::BaseController
      # before_action :ensure_doctor_role, only: %i[availability working_hours]
      # before_action :set_doctor, only: %i[availability working_hours]

      def availability
        render json: { available: true }, status: :ok
      end

      def working_hours
        render json: { hours: '12' }, status: :ok
      end

      private

      def set_doctor
        @doctor = Doctor.find(params[:id])
      end

      def ensure_doctor_role
        return if current_user.has_role?(:doctor)

        render json: { error: 'Unauthorized' }, status: :unauthorized
      end
    end
  end
end
