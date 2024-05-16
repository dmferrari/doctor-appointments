# frozen_string_literal: true

class DoctorAvailabilityService
  include TimeParser

  attr_reader :doctor, :date

  def initialize(doctor:, date: nil)
    @doctor = doctor
    @date = date
  end

  def working_hours
    @working_hours ||= fetch_working_hours(@date)
  end

  def availability
    @availability ||= calculate_availability(@date)
  end

  def available_at?(start_time:)
    end_time = string_to_time(start_time) + doctor.doctor_profile.session_length.minutes
    availability.any? do |slot|
      string_to_time(slot[:start_time]) <= string_to_time(start_time) &&
        end_time <= string_to_time(slot[:end_time])
    end
  end

  private

  # Normalizes the given date by returning it if not nil, or a range from today
  # to one week from now if nil.
  #
  # @param date [Date, nil] The date to be normalized.
  # @return [Range] The normalized date range.
  def normalize_date(date)
    date || (Time.zone.today..1.week.from_now)
  end

  def fetch_working_hours(date)
    normalized_date = normalize_date(date)
    WorkingHour.where(doctor_id: @doctor.id, working_date: normalized_date)
  end

  def calculate_availability(date)
    normalized_date = normalize_date(date)
    if normalized_date.is_a?(Range)
      normalized_date.flat_map { |d| availability_on_date(d) }
    else
      availability_on_date(normalized_date)
    end
  end

  def availability_on_date(date)
    working_hours = fetch_working_hours(date).first
    return [] unless working_hours

    appointments = Appointment.where(doctor_id: @doctor.id, appointment_date: date).order(:start_time)
    calculate_free_intervals(date, working_hours, appointments)
  end

  # Calculates the free intervals within a given date, working hours, and
  # appointments.
  #
  # @param date [Date] The date for which to calculate the free intervals.
  # @param working_hours [WorkingHours] The working hours during which the
  #   intervals should be calculated.
  # @param appointments [Array<Appointment>] The list of appointments to
  #   consider when calculating the intervals.
  # @return [Array<Interval>] An array of intervals representing the free time
  #   slots.
  def calculate_free_intervals(date, working_hours, appointments)
    free_intervals = []
    current_time = working_hours.start_time

    # Add the free interval before and between each appointment
    appointments.each do |appointment|
      if current_time < appointment.start_time
        free_intervals << { date:, start_time: current_time, end_time: appointment.start_time }
      end
      current_time = appointment.end_time if current_time < appointment.end_time
    end

    # Add the last free interval if available
    if current_time < working_hours.end_time
      free_intervals << { date:, start_time: current_time, end_time: working_hours.end_time }
    end

    free_intervals
  end
end
