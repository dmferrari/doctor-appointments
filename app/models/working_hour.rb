# frozen_string_literal: true

class WorkingHour < ApplicationRecord
  belongs_to :doctor, -> { with_role(:doctor) },
             class_name: 'User',
             foreign_key: 'doctor_id',
             inverse_of: :working_hours

  validate :doctor_role
  validates :working_date, :start_time, :end_time, presence: true
  validate :start_time_before_end_time

  def includes_hour?(hour_str)
    start_time <= hour_str && hour_str <= end_time
  end

  private

  def doctor_role
    errors.add(:doctor, 'must have the doctor role') unless doctor&.doctor?
  end

  def start_time_before_end_time
    return if start_time < end_time

    errors.add(:end_time, 'must be after start time')
  end
end
