# frozen_string_literal: true

require 'rails_helper'
require 'spec_helper'

RSpec.describe DoctorProfile, type: :model do
  describe '#card_info' do
    it 'returns the doctor name and specialty' do
      doctor = create(:user, full_name: 'Dr. House')
      doctor_profile = create(:doctor_profile, doctor:, specialty: 'Diagnostic Medicine')

      expect(doctor_profile.card_info).to eq('Dr. House - Diagnostic Medicine')
    end
  end
end
