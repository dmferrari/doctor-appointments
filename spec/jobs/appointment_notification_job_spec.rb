# frozen_string_literal: true

require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe AppointmentNotificationJob, type: :job do
  let(:doctor) { create(:user, :doctor) }
  let(:patient) { create(:user, :patient) }
  let(:appointment) { create(:appointment, doctor:, patient:) }

  before do
    Sidekiq::Testing.inline!
  end

  it 'sends an email when an appointment is created' do
    expect { described_class.perform_async(appointment.id, 'create') }
      .to change { ActionMailer::Base.deliveries.count }.by(1)
  end

  it 'sends an email when an appointment is updated' do
    expect { described_class.perform_async(appointment.id, 'update') }
      .to change { ActionMailer::Base.deliveries.count }.by(1)
  end

  it 'sends an email when an appointment is canceled' do
    expect { described_class.perform_async(appointment.id, 'destroy') }
      .to change { ActionMailer::Base.deliveries.count }.by(1)
  end
end
