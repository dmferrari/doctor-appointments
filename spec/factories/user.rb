# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    full_name { Faker::Name.name }
    email { Faker::Internet.email }
    password { 'password123' }
    password_confirmation { 'password123' }

    trait :doctor do
      after(:create) do |user|
        user.add_role(:doctor)
        create(:doctor_profile, doctor: user)
      end
    end

    trait :patient do
      after(:create) { |user| user.add_role(:patient) }
    end

    trait :doctor_and_patient do
      after(:create) do |user|
        user.add_role(:doctor)
        user.add_role(:patient)
      end
    end
  end
end
