# frozen_string_literal: true

class Appointment < ApplicationRecord
  include DateTimeParser

  belongs_to :doctor, -> { with_role(:doctor) },
             class_name: 'User',
             foreign_key: 'doctor_id',
             inverse_of: :doctor_appointments

  belongs_to :patient, -> { with_role(:patient) },
             class_name: 'User',
             foreign_key: 'patient_id',
             inverse_of: :patient_appointments

  before_save :set_end_time, if: -> { start_time.present? }

  validates :appointment_date, :start_time, presence: true
  validates :start_time, format: { with: /\A\d{2}:\d{2}\z/, message: I18n.t('errors.messages.invalid_time_format') }
  validates_with DoctorRoleValidator
  validates_with PatientRoleValidator
  validates_with AppointmentSlotValidator, unless: -> { errors[:appointment_date].any? || errors[:start_time].any? }
  validates_with AppointmentDateValidator, unless: -> { errors[:appointment_date].any? }
  validates_with WorkingHoursValidator, unless: -> { errors[:appointment_date].any? || errors[:doctor].any? }
  validate :patient_and_doctor_cannot_be_the_same

  validates :appointment_date, uniqueness: {
    scope: %i[doctor_id patient_id appointment_date],
    message: I18n.t('errors.messages.taken_for_doctor_patient_date')
  }

  def available_slot?
    @available_slot ||= DoctorAvailabilityService.new(doctor:, date: appointment_date).available_at?(start_time:)
  end

  def within_working_hours?
    DoctorAvailabilityService.new(doctor:, date: appointment_date).appointment_within_working_hours?(
      start_time: start_time_to_string, end_time: end_time_to_string
    )
  end

  private

  def set_end_time
    self.end_time = formatted_end_time
  end

  def patient_and_doctor_cannot_be_the_same
    errors.add(I18n.t('errors.messages.same_patient_and_doctor')) if doctor.id == patient.id
  end

  def start_time_to_string
    @start_time_to_string ||= string_to_time(start_time)
  end

  def end_time_to_string
    @end_time_to_string ||= start_time_to_string + session_length_in_minutes
  end

  def formatted_end_time
    @formatted_end_time ||= end_time_to_string.strftime(I18n.t('time_format'))
  end

  def session_length_in_minutes
    @session_length_in_minutes ||= doctor.doctor_profile.session_length.minutes
  end
end
