# frozen_string_literal: true

class WorkingHour < ApplicationRecord
  belongs_to :doctor, -> { with_role(:doctor) },
             class_name: 'User',
             foreign_key: 'doctor_id',
             inverse_of: :working_hours

  validate :doctor_role
  validates :working_date, :start_time, :end_time, presence: true
  validate :start_time_before_end_time

  private

  def doctor_role
    errors.add(:doctor, I18n.t('errors.messages.missing_doctor_role')) unless doctor.has_role?(:doctor)
  end

  def start_time_before_end_time
    return if start_time < end_time

    errors.add(:end_time, I18n.t('errors.messages.end_time_before_start_time'))
  end
end
