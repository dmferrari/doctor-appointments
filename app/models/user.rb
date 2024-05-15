# frozen_string_literal: true

class User < ApplicationRecord
  rolify

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  scope :doctors, -> { with_role(:doctor) }
  scope :patients, -> { with_role(:patient) }

  has_many :working_hours, inverse_of: :doctor, dependent: :destroy

  has_many :doctor_appointments, class_name: 'Appointment', foreign_key: 'doctor_id', inverse_of: :doctor,
                                 dependent: :destroy
  has_many :patient_appointments, class_name: 'Appointment', foreign_key: 'patient_id', inverse_of: :patient,
                                  dependent: :destroy

  include Doctorable # if respond_to?(:doctor?)

  def doctor?
    has_role?(:doctor)
  end

  def patient?
    has_role?(:patient)
  end
end
