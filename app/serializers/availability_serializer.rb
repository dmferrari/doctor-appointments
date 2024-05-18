# frozen_string_literal: true

class AvailabilitySerializer < ActiveModel::Serializer
  attributes :date, :start_time, :end_time
end
