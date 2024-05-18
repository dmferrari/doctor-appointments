# frozen_string_literal: true

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

FactoryBot.define do
  factory :doctor_profile do
    association :doctor, factory: :user, strategy: :build
    specialty { DOCTOR_SPECIALTIES.sample }
    session_length { %w[15 30 45 60].sample }
  end
end
