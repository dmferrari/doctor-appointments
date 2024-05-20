# frozen_string_literal: true

require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe DailyAppointmentReminderJob, type: :job do
  let(:doctor1) { create(:user, :doctor) }
  let(:doctor2) { create(:user, :doctor) }

  let(:patient1) { create(:user, :patient) }
  let(:patient2) { create(:user, :patient) }
  let(:patient3) { create(:user, :patient) }

  before do
    Sidekiq::Testing.inline!

    create(:working_hour, doctor: doctor1, working_date: Time.zone.today, start_time: '09:00', end_time: '18:00')
    create(:working_hour, doctor: doctor1, working_date: Time.zone.tomorrow, start_time: '09:00', end_time: '18:00')
    create(:working_hour, doctor: doctor2, working_date: Time.zone.today, start_time: '09:00', end_time: '18:00')
    create(:working_hour, doctor: doctor2, working_date: Time.zone.tomorrow, start_time: '09:00', end_time: '18:00')

    Appointment.destroy_all

    # Create appointments for tomorrow. Must be included in the reminder emails
    create(:appointment, doctor: doctor1, patient: patient1, appointment_date: Time.zone.tomorrow, start_time: '09:00')
    create(:appointment, doctor: doctor1, patient: patient2, appointment_date: Time.zone.tomorrow, start_time: '11:00')
    create(:appointment, doctor: doctor2, patient: patient3, appointment_date: Time.zone.tomorrow, start_time: '09:00')

    # Create appointments for today. These should not be included in the reminder emails
    create(:appointment, doctor: doctor1, patient: patient3, appointment_date: Time.zone.today, start_time: '09:00')
    create(:appointment, doctor: doctor2, patient: patient2, appointment_date: Time.zone.today, start_time: '14:00')
  end

  after do
    ActionMailer::Base.deliveries.clear
    Appointment.destroy_all
  end

  it 'sends reminder emails for appointments scheduled for the next day' do
    appointments_for_tomorrow = Appointment.where(appointment_date: Time.zone.tomorrow)

    expect do
      described_class.new.perform
    end.to change { ActionMailer::Base.deliveries.count }.by(appointments_for_tomorrow.count)

    delivered_emails = ActionMailer::Base.deliveries
    expect(delivered_emails.map(&:to).flatten).to match_array(
      appointments_for_tomorrow.map { |appt| appt.patient.email }
    )
  end
end
