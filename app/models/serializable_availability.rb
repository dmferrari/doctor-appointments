# frozen_string_literal: true

class SerializableAvailability
  include ActiveModel::Model
  include ActiveModel::Serialization

  attr_accessor :date, :start_time, :end_time

  def self.wrap(availabilities)
    availabilities.map do |availability|
      new(
        date: availability[:date],
        start_time: availability[:start_time],
        end_time: availability[:end_time]
      )
    end
  end
end
