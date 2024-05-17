# frozen_string_literal: true

class PatientRoleValidator < ActiveModel::Validator
  def validate(record)
    return if record.patient&.has_role?(:patient)

    record.errors.add(:patient, I18n.t('errors.messages.missing_patient_role'))
  end
end
