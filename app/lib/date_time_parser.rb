# frozen_string_literal: true

module DateTimeParser
  def string_to_time(time_str)
    string_to_time!(time_str)
  rescue ArgumentError
    nil
  end

  def string_to_time!(time_str)
    Time.strptime(time_str, I18n.t('time_format'))
  rescue ArgumentError
    raise ArgumentError, I18n.t('errors.messages.invalid_time_format')
  end

  def string_to_date(date_str)
    string_to_date!(date_str)
  rescue ArgumentError
    nil
  end

  def string_to_date!(date_str)
    Date.parse(date_str)
  rescue ArgumentError
    raise ArgumentError, I18n.t('errors.messages.invalid_date_format')
  end

  def date_to_string(date)
    date.strftime(I18n.t('date_format'))
  end
end
