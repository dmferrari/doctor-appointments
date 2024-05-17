# frozen_string_literal: true

class DoctorRoleValidator < ActiveModel::Validator
  def validate(record)
    return if record.doctor&.has_role?(:doctor)

    record.errors.add(:doctor, I18n.t('errors.messages.missing_doctor_role'))
  end
end
