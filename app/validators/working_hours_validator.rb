# frozen_string_literal: true

class WorkingHoursValidator < ActiveModel::Validator
  def validate(record)
    return if record.within_working_hours?

    record.errors.add(:appointment, I18n.t('errors.messages.outside_working_hours'))
  end
end
