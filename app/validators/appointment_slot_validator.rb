class AppointmentSlotValidator < ActiveModel::Validator
  def validate(record)
    return if record.available_slot?

    record.errors.add(:appointment, I18n.t('errors.messages.appointment_slot_not_available'))
  end
end
