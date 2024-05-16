# frozen_string_literal: true

module Api
  module V1
    class AppointmentsController < Api::V1::BaseController
      before_action :set_doctor, only: %i[create update]
      before_action :set_appointment, only: %i[show update destroy]

      def index
        render json: {
          appointments: current_user.doctor_appointments + current_user.patient_appointments
        }, status: :ok
      end

      def show
        if @appointment
          render json: { appointment: @appointment }, status: :ok
        else
          render json: { error: I18n.t('errors.messages.not_found', resource: I18n.t('appointment')) },
                 status: :not_found
        end
      end

      def create
        appointment = Appointment.new(appointment_params).tap do |appt|
          appt.patient = current_user
        end

        if appointment.save
          render json: { appointment: }, status: :created
        else
          render json: { error: appointment.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @appointment.update(appointment_params)
          render json: { appointment: @appointment }, status: :ok
        else
          render json: { error: @appointment.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        if @appointment.destroy
          render json: {}, status: :ok
        else
          render json: { error: I18n.t('errors.messages.deletion_failed') }, status: :unprocessable_entity
        end
      end

      private

      def set_appointment
        if current_user.has_role?(:patient)
          @appointment = Appointment.find_by!(id: params[:id], patient: current_user)
        elsif current_user.has_role?(:doctor)
          @appointment = Appointment.find_by!(id: params[:id], doctor: current_user)
        else
          render json: { error: I18n.t('errors.messages.unauthorized') }, status: :unauthorized
        end
      rescue ActiveRecord::RecordNotFound
        render json: { error: I18n.t('errors.messages.not_found') }, status: :not_found
      end

      def appointment_params
        params.require(:appointment).permit(:doctor_id, :date, :appointment_date, :start_time)
      end

      def set_doctor
        @doctor = User.doctors.find_by(id: appointment_params[:doctor_id])
        return unless @doctor.nil?

        render json: { error: I18n.t('errors.messages.not_found', resource: I18n.t('doctor')) }, status: :not_found
      end
    end
  end
end
