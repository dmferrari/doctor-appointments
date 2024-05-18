# frozen_string_literal: true

class DoctorSerializer < ActiveModel::Serializer
  attributes :id, :full_name, :email, :specialty, :session_length

  def specialty
    object&.doctor_profile&.specialty
  end

  def session_length
    object&.doctor_profile&.session_length
  end
end
