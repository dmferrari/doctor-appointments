# frozen_string_literal: true

class DailyAppointmentReminderJob
  include Sidekiq::Job

  sidekiq_options retry: 3

  def perform
    appointments = Appointment.where(appointment_date: Date.tomorrow)

    appointments.each do |appointment|
      AppointmentMailer.with(appointment:).reminder.deliver_now
    end
  end
end
