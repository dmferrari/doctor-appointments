# frozen_string_literal: true

class AppointmentMailer < ApplicationMailer
  default from: 'notifications@example.com'

  def created
    @appointment = params[:appointment]
    I18n.with_locale(@appointment.patient.locale) do
      mail(
        to: @appointment.patient.email,
        subject: I18n.t('appointment_mailer.subjects.appointment_created'),
        template_path: "appointment_mailer/#{I18n.locale}"
      )
    end
  end

  def updated
    @appointment = params[:appointment]
    I18n.with_locale(@appointment.patient.locale) do
      mail(
        to: @appointment.patient.email,
        subject: I18n.t('appointment_mailer.subjects.appointment_updated'),
        template_path: "appointment_mailer/#{I18n.locale}"
      )
    end
  end

  def canceled
    @appointment = params[:appointment]
    I18n.with_locale(@appointment.patient.locale) do
      mail(
        to: @appointment.patient.email,
        subject: I18n.t('appointment_mailer.subjects.appointment_canceled'),
        template_path: "appointment_mailer/#{I18n.locale}"
      )
    end
  end

  def reminder
    @appointment = params[:appointment]
    I18n.with_locale(@appointment.patient.locale) do
      mail(
        to: @appointment.patient.email,
        subject: I18n.t('appointment_mailer.subjects.appointment_reminder'),
        template_path: "appointment_mailer/#{I18n.locale}"
      )
    end
  end
end
