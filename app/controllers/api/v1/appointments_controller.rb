# frozen_string_literal: true

module Api
  module V1
    class AppointmentsController < Api::V1::BaseController
      before_action :set_appointment, only: %i[show update destroy]
      before_action :set_doctor, only: :create

      def index
        render json: current_user.doctor_appointments + current_user.patient_appointments, status: :ok
      end

      def show
        if @appointment
          render json: @appointment, status: :ok
        else
          render json: { error: I18n.t('errors.messages.not_found', resource: I18n.t('appointment')) },
                 status: :not_found
        end
      end

      def create
        appointment = Appointment.new(appointment_params)
        appointment.patient = current_user

        if appointment.save
          render json: appointment, status: :created
        else
          render json: { error: appointment.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @appointment.update_appointment(
          new_date: appointment_params[:appointment_date],
          new_start_time: appointment_params[:start_time]
        )
          render json: @appointment, status: :ok
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

      def appointment_params
        if action_name == 'update'
          params.require(:appointment).permit(:appointment_date, :start_time)
        else
          params.require(:appointment).permit(:doctor_id, :appointment_date, :start_time)
        end
      end

      def set_appointment # rubocop:disable Metrics/AbcSize
        if current_user.has_all_roles?(:patient, :doctor)
          @appointment = find_appointment_as_patient_or_doctor!
        elsif current_user.has_role?(:patient)
          @appointment = Appointment.find_by!(id: params[:id], patient: current_user)
        elsif current_user.has_role?(:doctor)
          @appointment = Appointment.find_by!(id: params[:id], doctor: current_user)
        end
      rescue ActiveRecord::RecordNotFound
        render json: { error: I18n.t('errors.messages.not_found', resource: I18n.t('appointment')) }, status: :not_found
      end

      def find_appointment_as_patient_or_doctor!
        appointment = Appointment.find_by(id: params[:id], patient: current_user) ||
                      Appointment.find_by(id: params[:id], doctor: current_user)
        raise ActiveRecord::RecordNotFound if appointment.nil?

        appointment
      end

      def set_doctor
        @doctor = User.doctors.find_by(id: appointment_params[:doctor_id])
        return unless @doctor.nil?

        render json: { error: I18n.t('errors.messages.not_found', resource: I18n.t('doctor')) }, status: :not_found
      end
    end
  end
end
