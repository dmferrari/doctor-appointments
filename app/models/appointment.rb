# frozen_string_literal: true

class Appointment < ApplicationRecord
  include TimeParser

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
  validates :start_time, format: { with: /\A\d{2}:\d{2}\z/, message: 'format must be HH:MM' }
  validate :validate_start_time, unless: -> { errors[:start_time].any? }
  validate :validate_doctor_role
  validate :validate_patient_role
  validate :validate_appointment_date_cannot_be_in_the_past, unless: -> { errors[:appointment_date].any? }
  validates :appointment_date, uniqueness: {
    scope: %i[doctor_id patient_id appointment_date],
    message: 'has already been taken for this doctor and patient on this date'
  }
  validate :validate_appointment_within_doctor_working_hours,
           unless: -> { errors[:appointment_date].any? || errors[:doctor].any? }
  validate :available_slot?

  private

  def set_end_time
    self.end_time = formatted_end_time
  end

  def validate_doctor_role
    errors.add(:doctor, 'must have the doctor role') unless doctor&.has_role?(:doctor)
  end

  def validate_patient_role
    errors.add(:patient, 'must have the patient role') unless patient&.has_role?(:patient)
  end

  def validate_start_time
    errors.add(:start_time, 'is not a valid time') unless start_time_to_string
  end

  def validate_appointment_date_cannot_be_in_the_past
    return if appointment_date >= Date.current

    errors.add(:appointment_date, 'cannot be in the past')
  end

  def validate_appointment_within_doctor_working_hours
    return if within_working_hours?

    errors.add(:appointment, 'is not within doctor working hours')
  end

  def within_working_hours?
    start_time >= working_hours.start_time && formatted_end_time <= working_hours.end_time
  end

  def available_slot?
    slot_available = DoctorAvailabilityService.new(doctor:, date: appointment_date).available_at?(start_time:)

    errors.add(:appointment, 'slot is not available') unless slot_available
  end

  def start_time_to_string
    @start_time_to_string ||= string_to_time(start_time)
  end

  def end_time_to_string
    @end_time_to_string ||= start_time_to_string + session_length_in_minutes
  end

  def formatted_end_time
    @formatted_end_time ||= end_time_to_string.strftime('%H:%M')
  end

  def session_length_in_minutes
    @session_length_in_minutes ||= doctor.doctor_profile.session_length.minutes
  end

  def working_hours
    @working_hours ||= DoctorAvailabilityService.new(doctor:, date: appointment_date).working_hours.first
  end
end
