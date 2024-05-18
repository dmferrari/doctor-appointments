# frozen_string_literal: true

class AppointmentSerializer < ActiveModel::Serializer
  include DateTimeParser

  belongs_to :doctor, serializer: DoctorSerializer
  belongs_to :patient, serializer: PatientSerializer

  attributes :id, :appointment_date, :start_time, :end_time, :doctor, :patient

  def appointment_date
    date_to_string(object.appointment_date)
  end
end
