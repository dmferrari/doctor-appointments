# Notes

## Models

### User

| Field | Type | Description |
|-------|------|-------------|
| id | integer | The user id |
| first_name | string | The user first name |
| last_name | string | The user last name |
| email | string | The user email |
| password | string | The user password |
| role | string | The user role |

### Appointment

| Field | Type | Description |
|-------|------|-------------|
| id | integer | The appointment id |
| date | datetime | The appointment date |
| user_id | integer | The user id |
| doctor_id | integer | The doctor id |
| patient_id | integer | The patient id |

### Availability

| Field | Type | Description |
|-------|------|-------------|
| id | integer | The availability id |
| date | datetime | The availability date |
| doctor_id | integer | The doctor id |

### DoctorDetail

| Field | Type | Description |
|-------|------|-------------|
| id | integer | The doctor detail id |
| user_id | integer | The user id |
| specialty | string | The doctor specialty |
| session_length | integer | The doctor session length |

## Users

I will use `devise` to manage the users authentication. I'll use the `User` model to store the users data.

### Design

Designing authentication and role management in a Ruby on Rails application involves several considerations around flexibility, maintainability, and simplicity. Let's examine each option you've presented and then discuss which might be the best solution for your clinic scheduling system:

#### Option 1: Single User Model with Roles

##### Description

Utilize a single User model for authentication (with Devise), and differentiate roles (doctor, patient, admin) using a role management library like cancancan or rolify.
You can easily implement this with Devise for authentication and use either cancancan or rolify to manage roles:

- Devise Setup: Use Devise for handling common user authentication tasks.
- Role Management: Implement roles within the User model using an enum or a dedicated Role model, depending on the complexity of your access control requirements.

This approach supports scalability, as new roles or changes in the authentication logic only require adjustments in one place. It also keeps the initial setup straightforward, allowing you to expand or modify the role system as the needs of your application evolve.

##### Pros

- Simplicity: Managing all users in a single table simplifies the database schema.
- Flexibility: Easy to assign multiple roles to a user if needed, or change roles dynamically.
- Ease of Maintenance: All user-related functionality is centralized, making the code easier to maintain and update.

##### Cons

- Role Complexity: Depending on access control complexity, role checks can become cumbersome if many special cases or exceptions are needed.

### Roles

We three type of roles:

- Admin
- Doctor
- Patient

All of them are users, but with defined roles. So, I'll need to use `cancancan` to see what can anyone of them do.

| Role   | Users | Appointments |
|--------|-------|--------------|
| Admin  | CRUD  | CRUD         |
| Doctor | R     | CRUD         |
| Patient| R     | CRU          |

## Sidekiq

Use Sidekiq to send email confirmations everytime an appointment is created/updated/deleted.
