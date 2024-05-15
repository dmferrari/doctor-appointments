# frozen_string_literal: true

module Api
  module V1
    class DoctorsController < Api::V1::BaseController
      before_action :ensure_doctor_role, only: %i[availability working_hours]
      before_action :set_doctor, only: %i[availability working_hours]
      before_action :set_requested_date, only: %i[availability working_hours]

      def working_hours
        render json: @doctor.working_hours(date: @requested_date), status: :ok
      end

      def availability
        render json: @doctor.availability(date: @requested_date), status: :ok
      end

      private

      def set_doctor
        @doctor = User.doctors.find_by(id: params[:id])
        return unless @doctor.nil?

        render json: { error: 'Doctor not found' }, status: :not_found
      end

      def ensure_doctor_role
        return if current_user.has_role?(:doctor)

        render json: { error: 'Unauthorized' }, status: :unauthorized
      end

      def set_requested_date
        if params[:date].present?
          @requested_date = parse_date(params[:date])
          return unless @requested_date.nil?

          render json: { error: 'Invalid date format' }, status: :unprocessable_entity
        else
          @requested_date = nil
        end
      end

      def parse_date(date_str)
        Date.parse(date_str)
      rescue ArgumentError
        Rails.logger.info("[#{self.class.name}] Invalid date format: #{date_str}")
        nil
      end
    end
  end
end
