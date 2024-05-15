# frozen_string_literal: true

module Api
  module V1
    class AppointmentsController < Api::V1::BaseController
      # before_action :set_patient,
      # before_action :set_doctor
      before_action :ensure_user_role, only: %i[index show create update destroy]
      before_action :set_appointment, only: %i[show update destroy]

      def index
        if current_user.has_role?(:doctor)
          render json: { appointments: current_user.doctor_appointments }, status: :ok
        elsif current_user.has_role?(:patient)
          render json: { appointments: current_user.patient_appointments }, status: :ok
        else
          render json: { error: 'Unauthorized' }, status: :unauthorized
        end
      end

      def show
        if @appointment
          render json: { appointment: @appointment }, status: :ok
        else
          render json: { error: 'Appointment not found' }, status: :not_found
        end
      end

      def create
        appointment = Appointment.new(appointment_params).tap do |appt|
          appt.patient = @patient
        end

        if appointment.save
          render json: { message: 'Appointment created' }, status: :created
        else
          render json: { error: appointment.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        render json: { message: "Appointment #{params[:id]} updated" }, status: :ok
      end

      def destroy
        render json: { message: 'Appointment deleted' }, status: :ok
      end

      private

      def set_appointment
        # @appointment = Appointment.find(params[:id])
      end

      def set_doctor
        @doctor = User.doctors.find_by(id: appointment_params[:doctor_id])
        return unless @doctor.nil?

        render json: { error: 'Doctor not found' }, status: :not_found
      end

      def set_patient
        @patient = User.patients.find_by(id: appointment_params[:patient_id])
        return unless @patient.nil?

        render json: { error: 'Patient not found' }, status: :not_found
      end

      def current_user
        @current_user ||= User.patients.last
      end

      def appointment_params
        params.require(:appointment).permit(:doctor_id, :patient_id, :appointment_date, :start_time)
      end

      def ensure_user_role
        return if current_user.has_role?(:doctor) || current_user.has_role?(:patient)

        render json: { error: 'Unauthorized' }, status: :unauthorized
      end
    end
  end
end
