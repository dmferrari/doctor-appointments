# frozen_string_literal: true

class DoctorProfileSerializer < ActiveModel::Serializer
  belongs_to :doctor, serializer: DoctorSerializer

  attributes :session_length, :specialty
end
