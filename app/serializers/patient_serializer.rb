# frozen_string_literal: true

class PatientSerializer < ActiveModel::Serializer
  attributes :id, :full_name, :email
end
