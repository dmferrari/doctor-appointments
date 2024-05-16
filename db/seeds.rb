# frozen_string_literal: true

# Of course, this is an hardcoded password just for the sake of the example
# This will allow you to login as any user just knowing their email and this
# password
DEFAULT_PASSWORD = 'password'

SESSION_START_TIMES = %w[08:00 09:00 10:00].freeze
SESSION_END_TIMES = %w[16:00 17:00 18:00 19:00 20:00].freeze
SESSION_LENGTHS = [15, 30, 45, 60].freeze

APPOINTMENT_START_TIMES = %w[08:00 09:00 10:00 11:00 12:00 13:00 14:00 15:00].freeze

DOCTOR_SPECIALTIES = %w[
  Cardiology
  Dermatology
  Endocrinology
  Gastroenterology
  Neurology
  Oncology
  Orthopedics
  Pediatrics
  Psychiatry
  Radiology
].freeze

def create_user(email:, roles:)
  created_user = User.find_or_create_by!(email:) do |user|
    user.full_name = Faker::Name.name
    user.password = DEFAULT_PASSWORD
    user.password_confirmation = DEFAULT_PASSWORD
  end
  roles.each { |role| created_user.add_role(role) }

  created_user
end

def define_working_hours(doctor)
  7.times do |i|
    doctor.working_hours.create!(
      working_date: Time.zone.today + i.days,
      start_time: SESSION_START_TIMES.sample,
      end_time: SESSION_END_TIMES.sample
    )
  end
end

# Create the admin user
create_user(email: 'admin@clinic.com', roles: %w[admin])

# Create some doctors
10.times do
  doctor = create_user(email: Faker::Internet.email, roles: %w[doctor patient])
  define_working_hours(doctor)
  DoctorProfile.create!(doctor:, specialty: DOCTOR_SPECIALTIES.sample, session_length: SESSION_LENGTHS.sample)
end

# Create some patients
100.times do
  create_user(email: Faker::Internet.email, roles: %w[patient])
end

# Create a few appointments
100.times do
  doctor = User.with_role(:doctor).sample
  patient = User.with_role(:patient).sample

  Appointment.create(
    doctor:,
    patient:,
    appointment_date: doctor.working_hours.sample.working_date,
    start_time: APPOINTMENT_START_TIMES.sample
  )
end
