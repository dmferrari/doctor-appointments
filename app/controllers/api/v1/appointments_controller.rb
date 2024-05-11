# frozen_string_literal: true

module Api
  module V1
    class AppointmentsController < Api::V1::BaseController
      before_action :set_appointment, only: %i[show update destroy]

      def index
        render json: { message: 'Appointments list' }, status: :ok
      end

      def show
        render json: { message: 'Appointment details' }, status: :ok
      end

      def create
        render json: { message: 'Appointment created' }, status: :created
      end

      def update
        render json: { message: "Appointment #{params[:id]} updated" }, status: :ok
      end

      def destroy
        render json: { message: 'Appointment deleted' }, status: :ok
      end

      private

      def appointment_params
        params.require(:appointment).permit(:doctor_id, :patient_id, :date, :time)
      end

      def set_appointment
        # @appointment = Appointment.find(params[:id])
      end
    end
  end
end
