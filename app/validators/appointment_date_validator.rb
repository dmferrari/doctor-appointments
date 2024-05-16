class AppointmentDateValidator < ActiveModel::Validator
  def validate(record)
    return unless record.appointment_date < Date.current

    record.errors.add(:appointment_date, I18n.t('errors.messages.date_cannot_be_in_past'))
  end
end
