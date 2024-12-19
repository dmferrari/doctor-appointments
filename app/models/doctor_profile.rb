# frozen_string_literal: true

class DoctorProfile < ApplicationRecord
  belongs_to :doctor, class_name: 'User', inverse_of: :doctor_profile

  validates :session_length, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :specialty, presence: true

  def card_info
    "#{doctor.full_name} - #{specialty}"
  end
end
