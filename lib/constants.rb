# frozen_string_literal: true

module Constants
  DEFAULT_PASSWORD = 'password'

  SESSION_START_TIMES = %w[08:00 09:00 10:00].freeze
  SESSION_END_TIMES = %w[16:00 17:00 18:00 19:00 20:00].freeze
  SESSION_LENGTHS = [15, 30, 45, 60].freeze

  APPOINTMENT_START_TIMES = %w[08:00 09:00 10:00 11:00 12:00 13:00 14:00 15:00].freeze

  DOCTOR_SPECIALTIES = %w[
    Cardiology
    Dermatology
    Endocrinology
    Gastroenterology
    Neurology
    Oncology
    Orthopedics
    Pediatrics
    Psychiatry
    Radiology
  ].freeze
end
