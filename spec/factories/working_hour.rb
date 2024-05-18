# frozen_string_literal: true

SESSION_START_TIMES = %w[08:00 09:00 10:00].freeze
SESSION_END_TIMES = %w[16:00 17:00 18:00 19:00 20:00].freeze

FactoryBot.define do
  factory :working_hour do
    working_date { Faker::Date.forward(days: 5) }
    start_time { SESSION_START_TIMES.sample }
    end_time { SESSION_END_TIMES.sample }
  end
end
