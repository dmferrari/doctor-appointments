# frozen_string_literal: true

class WorkingHour < ApplicationRecord
  belongs_to :doctor, -> { with_role(:doctor) },
             class_name: 'User',
             foreign_key: 'doctor_id',
             inverse_of: :working_hours

  validate :doctor_role
  validates :working_date, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :start_time,
            format: { with: /\A\d{2}:\d{2}\z/, message: I18n.t('errors.messages.invalid_time_format') },
            unless: -> { errors[:start_time].any? }
  validates :end_time,
            format: { with: /\A\d{2}:\d{2}\z/, message: I18n.t('errors.messages.invalid_time_format') },
            unless: -> { errors[:end_time].any? }
  validate :start_time_before_end_time, unless: -> { errors[:start_time].any? || errors[:end_time].any? }

  private

  def doctor_role
    errors.add(:doctor, I18n.t('errors.messages.missing_doctor_role')) unless doctor.has_role?(:doctor)
  end

  def start_time_before_end_time
    return if start_time < end_time

    errors.add(:end_time, I18n.t('errors.messages.end_time_before_start_time'))
  end
end
