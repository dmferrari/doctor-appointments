# frozen_string_literal: true

class DoctorAvailabilityService
  include ActiveModel::Validations
  include DateTimeParser

  class DateRangeNotAllowedError < StandardError; end

  validates :date, presence: true
  validates :doctor, presence: true

  attr_reader :doctor, :date

  def initialize(doctor:, date: nil)
    @doctor = doctor
    @date = resolve_date(date)
  end

  def working_hours
    @working_hours ||= fetch_working_hours(@date)
  end

  def availability
    @availability ||= calculate_availability
  end

  def available_at?(start_time:)
    ensure_date_is_not_a_range
    end_time = calculate_end_time(start_time)
    availability.any? { |slot| within_time_range?(slot[:start_time], slot[:end_time], start_time, end_time) }
  end

  def appointed_at?(start_time:)
    ensure_date_is_not_a_range
    end_time = calculate_end_time(start_time)
    availability.any? { |slot| within_time_range?(slot[:start_time], slot[:end_time], start_time, end_time) }
  end

  def appointment_within_working_hours?(start_time:, end_time:)
    ensure_date_is_not_a_range
    working_hour = fetch_working_hours(@date).first
    return false unless working_hour

    within_time_range?(working_hour.start_time, working_hour.end_time, start_time, end_time)
  end

  private

  def ensure_date_is_not_a_range
    raise DateRangeNotAllowedError, I18n.t('errors.messages.date_range_not_allowed') if @date.is_a?(Range)
  end

  def resolve_date(date)
    date || (Time.zone.today..1.week.from_now)
  end

  def fetch_working_hours(date)
    WorkingHour.where(doctor: @doctor).where(working_date: date)
  end

  def calculate_availability
    dates = @date.is_a?(Range) ? @date : [@date]
    dates.flat_map { |date| daily_availability(date) }
  end

  def daily_availability(date)
    day_working_hours = fetch_working_hours(date).first
    return [] unless day_working_hours

    appointments = @doctor.doctor_appointments.where(appointment_date: date).order(:start_time)
    calculate_free_intervals(date, day_working_hours, appointments)
  end

  def calculate_free_intervals(date, day_working_hours, appointments)
    free_intervals = []
    current_time = day_working_hours.start_time

    appointments.each do |appt|
      add_free_interval_if_valid(free_intervals, date, current_time, appt.start_time) if current_time < appt.start_time
      current_time = [current_time, appt.end_time].max
    end

    if current_time < day_working_hours.end_time
      add_free_interval_if_valid(free_intervals, date, current_time, day_working_hours.end_time)
    end

    free_intervals
  end

  def add_free_interval_if_valid(free_intervals, date, start_time, end_time)
    free_interval = { date:, start_time:, end_time: }
    free_intervals << free_interval if interval_meets_minimum_session_length?(free_interval)
  end

  def interval_meets_minimum_session_length?(interval)
    interval_in_minutes = ((string_to_time(interval[:end_time]) - string_to_time(interval[:start_time])) / 60).minutes
    interval_in_minutes >= doctor.session_length.minutes
  end

  def calculate_end_time(start_time)
    string_to_time(start_time) + doctor.session_length.minutes
  end

  def within_time_range?(range_start, range_end, start_time, end_time)
    range_start <= start_time && end_time <= range_end
  end
end
