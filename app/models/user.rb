# frozen_string_literal: true

class User < ApplicationRecord
  rolify

  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
         :validatable, :jwt_authenticatable,
         jwt_revocation_strategy: JwtDenylist

  scope :doctors, -> { with_role(:doctor) }
  scope :patients, -> { with_role(:patient) }

  has_many :working_hours, inverse_of: :doctor, dependent: :destroy

  has_many :doctor_appointments, class_name: 'Appointment',
                                 foreign_key: 'doctor_id',
                                 inverse_of: :doctor,
                                 dependent: :destroy

  has_many :patient_appointments, class_name: 'Appointment',
                                  foreign_key: 'patient_id',
                                  inverse_of: :patient,
                                  dependent: :destroy

  include Doctorable

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :full_name, presence: true, length: { minimum: 3 }
  validates :password, presence: true, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }

  def has_all_roles?(*roles) # rubocop:disable Naming/PredicateName
    roles.all? { |role| has_role?(role) }
  end

  def locale
    self[:locale] || 'en'
  end
end
