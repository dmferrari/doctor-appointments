# frozen_string_literal: true

module Api
  module V1
    class DoctorsController < Api::V1::BaseController
      include DateTimeParser

      before_action :set_doctor, only: %i[availability working_hours]
      before_action :set_requested_date, only: %i[availability working_hours]

      def working_hours
        working_hours = @doctor.working_hours(date: @requested_date)
        render json: working_hours, each_serializer: WorkingHourSerializer, status: :ok
      end

      def availability
        availability = @doctor.availability(date: @requested_date)
        serialized_availability = SerializableAvailability.wrap(availability)

        render json: serialized_availability, each_serializer: AvailabilitySerializer, status: :ok
      end

      private

      def set_doctor
        @doctor = User.doctors.find_by(id: params[:id])
        return unless @doctor.nil?

        render json: { error: I18n.t('errors.messages.not_found', resource: I18n.t('doctor')) }, status: :not_found
      end

      def set_requested_date
        if params[:date].present?
          @requested_date = string_to_date(params[:date])
          return unless @requested_date.nil?

          render json: { error: I18n.t('errors.messages.invalid_date_format') }, status: :unprocessable_entity
        else
          @requested_date = nil
        end
      end
    end
  end
end
