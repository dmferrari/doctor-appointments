# frozen_string_literal: true

include Constants

FactoryBot.define do
  factory :working_hour do
    working_date { Faker::Date.forward(days: 5) }
    start_time { SESSION_START_TIMES.sample }
    end_time { SESSION_END_TIMES.sample }
  end
end
