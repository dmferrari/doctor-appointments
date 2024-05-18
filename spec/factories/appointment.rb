# frozen_string_literal: true

FactoryBot.define do
  factory :appointment do
    doctor { create(:user, :doctor) }
    patient { create(:user, :patient) }
    appointment_date { Faker::Date.forward(days: 5) }
    start_time { '10:00' }
  end
end
