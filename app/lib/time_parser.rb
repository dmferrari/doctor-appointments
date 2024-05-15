# frozen_string_literal: true

module TimeParser
  def parse_time(time_str)
    parse_time!(time_str)
  rescue ArgumentError
    nil
  end

  def parse_time!(time_str)
    Time.strptime(time_str, '%H:%M')
  rescue ArgumentError
    raise ArgumentError, 'Invalid time format'
  end
end
