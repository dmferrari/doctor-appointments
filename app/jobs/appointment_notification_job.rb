# frozen_string_literal: true

class AppointmentNotificationJob
  include Sidekiq::Job

  sidekiq_options retry: 3

  def perform(appointment_id, action)
    appointment = Appointment.with_deleted.find(appointment_id)

    case action
    when 'create'
      AppointmentMailer.with(appointment:).created.deliver_now
    when 'update'
      AppointmentMailer.with(appointment:).updated.deliver_now
    when 'destroy'
      AppointmentMailer.with(appointment:).canceled.deliver_now
    end
  end
end
