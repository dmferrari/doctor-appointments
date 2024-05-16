# frozen_string_literal: true

module TimeParser
  def string_to_time(time_str)
    string_to_time!(time_str)
  rescue ArgumentError
    nil
  end

  def string_to_time!(time_str)
    Time.strptime(time_str, '%H:%M')
  rescue ArgumentError
    raise ArgumentError, 'Invalid time format'
  end
end
