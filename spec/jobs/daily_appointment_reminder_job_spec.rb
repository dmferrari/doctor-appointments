# frozen_string_literal: true

require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe DailyAppointmentReminderJob, type: :job do
  let(:doctor) { create(:user, :doctor) }
  let(:patient) { create(:user, :patient) }
  let!(:appointment) { create(:appointment, doctor:, patient:, appointment_date: Date.tomorrow) }

  before do
    Sidekiq::Testing.inline!
  end

  it 'sends reminder emails for appointments scheduled for the next day' do
    expect { described_class.perform_async }
      .to change { ActionMailer::Base.deliveries.count }.by(1)
  end
end
