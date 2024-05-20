# frozen_string_literal: true

include Constants

FactoryBot.define do
  factory :doctor_profile do
    association :doctor, factory: :user, strategy: :build
    specialty { DOCTOR_SPECIALTIES.sample }
    session_length { SESSION_LENGTHS.sample }
  end
end
