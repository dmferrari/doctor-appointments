# frozen_string_literal: true

class WorkingHourSerializer < ActiveModel::Serializer
  attributes :date, :start_time, :end_time

  def date = object.working_date
end
