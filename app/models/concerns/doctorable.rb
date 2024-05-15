# frozen_string_literal: true

module Doctorable
  extend ActiveSupport::Concern

  included do
    has_one :doctor_profile, dependent: :destroy,
                             foreign_key: 'doctor_id',
                             inverse_of: :doctor

    def working_hours(date: nil)
      ::DoctorAvailabilityService.new(doctor: self, date:).working_hours
    end

    def availability(date: nil)
      ::DoctorAvailabilityService.new(doctor: self, date:).availability
    end

    def session_length
      doctor_profile&.session_length
    end
  end
end
