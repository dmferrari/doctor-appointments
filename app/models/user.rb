# frozen_string_literal: true

class User < ApplicationRecord
  rolify

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  has_many :working_hours, inverse_of: :doctor, dependent: :destroy

  has_many :doctor_appointments, class_name: 'Appointment', foreign_key: 'doctor_id', inverse_of: :doctor,
                                 dependent: :destroy
  has_many :patient_appointments, class_name: 'Appointment', foreign_key: 'patient_id', inverse_of: :patient,
                                  dependent: :destroy

end
