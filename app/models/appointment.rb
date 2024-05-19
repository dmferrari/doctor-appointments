# frozen_string_literal: true

class Appointment < ApplicationRecord
  acts_as_paranoid

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

  validates :appointment_date, presence: true
  validates :start_time, presence: true
  validate :validate_start_time, unless: -> { errors[:start_time].any? }
  validates :start_time,
            format: { with: /\A\d{2}:\d{2}\z/, message: I18n.t('errors.messages.invalid_time_format') },
            unless: -> { errors[:start_time].any? }
  validates_with DoctorRoleValidator
  validates_with PatientRoleValidator
  validates_with AppointmentSlotValidator, unless: -> { errors[:appointment_date].any? || errors[:start_time].any? }
  validates_with AppointmentDateValidator, unless: -> { errors[:appointment_date].any? }
  validates_with WorkingHoursValidator, unless: lambda {
                                                  errors[:appointment_date].any? || errors[:doctor].any? || errors[:start_time].any?
                                                }
  validate :patient_and_doctor_cannot_be_the_same
  validate :validate_appointment_slot, unless: -> { new_record? }

  validates :appointment_date, uniqueness: {
    scope: %i[doctor_id patient_id appointment_date],
    message: I18n.t('errors.messages.taken_for_doctor_patient_date')
  }

  def update_appointment(new_date:, new_start_time:)
    transaction do
      self.appointment_date = new_date
      self.start_time = new_start_time

      save!
    end
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error(e.message)
    false
  end

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
    errors.add(:base, I18n.t('errors.messages.same_patient_and_doctor')) if doctor.id == patient.id
  end

  def validate_start_time
    return if string_to_time(start_time)

    errors.add(:start_time, I18n.t('errors.messages.invalid_time_format'))
  end

  def validate_appointment_slot
    return if same_day_time_change?
    return if available_slot?

    errors.add(:base, I18n.t('errors.messages.taken_for_doctor_patient_date'))
  end

  def same_day_time_change?
    persisted? && appointment_date == appointment_date_was && patient_id == patient_id_was && doctor_id == doctor_id_was
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
    @session_length_in_minutes ||= doctor.session_length.minutes
  end
end
