# frozen_string_literal: true

DEFAULT_PASSWORD = 'password'

def create_user(email:, roles:)
  created_user = User.find_or_create_by!(email:) do |user|
    user.full_name = Faker::Name.name
    user.password = DEFAULT_PASSWORD
    user.password_confirmation = DEFAULT_PASSWORD
  end
  roles.each { |role| created_user.add_role(role) }
end

# Create the admin user
create_user(email: 'admin@clinic.com', roles: %w[admin])

# Create some doctors
10.times do
  create_user(email: Faker::Internet.email, roles: %w[doctor patient])
end

# Create some patients
10.times do
  create_user(email: Faker::Internet.email, roles: %w[patient])
end
