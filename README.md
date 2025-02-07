# Doctor Appointments

Doctor Appointments is a Rails-based API service for managing doctor appointments. This service allows users to create, update, and delete appointments, and provides information about doctors' availability and working hours.

## Prerequisites

- Docker
- Docker Compose

## Setup

### Clone the repository

   ```sh
   git clone git@github.com:dmferrari/doctor-appointments.git
   cd doctor-appointments
   ```

### Create environment variables file

Create a .env file in the root directory with the following content:

```env
POSTGRES_USER=your_postgres_user
POSTGRES_PASSWORD=your_postgres_password
POSTGRES_DB=doctor_appointments_development
REDIS_URL=redis://redis:6379/1
JWT_SECRET_KEY=your_jwt_secret_key
```

### Build and start the services

```sh
docker compose up --build
```

### **Set up the database:**

When the previous command finishes, open a new terminal window, go to the project directory and run the following commands:

```sh
docker compose run web bin/rails db:create db:migrate db:seed
```

## Usage

### Access the Rails console

```bash
docker compose run web bin/rails c
```

To test this, you can access the latest appointment created by running the following command:

```ruby
Appointment.last
```

This should return something like:

```ruby
  Appointment Load (0.5ms)  SELECT "appointments".* FROM "appointments" WHERE "appointments"."deleted_at" IS NULL ORDER BY "appointments"."id" DESC LIMIT $1  [["LIMIT", 1]]
=>
#<Appointment:0x00007f33c428aad8
 id: 73,
 doctor_id: 6,
 patient_id: 106,
 appointment_date: Thu, 23 May 2024 00:00:00.000000000 UTC +00:00,
 start_time: "14:00",
 end_time: "15:00",
 created_at: Mon, 20 May 2024 15:37:02.125789000 UTC +00:00,
 updated_at: Mon, 20 May 2024 15:37:02.125789000 UTC +00:00,
 deleted_at: nil>
```

### Access the Rails server

The application will be available at <http://localhost:3000>.

There is nothing to see here.

### Sidekiq dashboard

The Sidekiq dashboard can be accessed at <http://localhost:3000/sidekiq>.

## API Endpoints

### Authentication

Login:

```bash
POST /api/v1/users/login
```

Example:

```bash
curl -i --request POST \
  --url http://localhost:3000/api/v1/users/login \
  --header 'Content-Type: application/json' \
  --data '{
  "user": {
    "email": "user@example.com",
    "password": "password"
  }
}'
```

> [!NOTE] JWT Token
> In the header of the response you will receive the **token** that you will use to authenticate the other requests.

> [!NOTE] User and password
> The user and password for the default user are defined in the .env file.

Response (example):

```text
HTTP/1.1 200 OK
x-frame-options: SAMEORIGIN
x-xss-protection: 0
x-content-type-options: nosniff
x-permitted-cross-domain-policies: none
referrer-policy: strict-origin-when-cross-origin
content-type: application/json; charset=utf-8
vary: Accept
authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMTIiLCJzY3AiOiJ1c2VyIiwiYXVkIjpudWxsLCJpYXQiOjE3MTYyMDE3ODgsImV4cCI6MTcxNjI4ODE4OCwianRpIjoiN2QwOTJiZjYtNDgzMC00MGY0LWI0NTItNGM3YTU2NmFjMzgxIn0.ZhDivr5cDcQ4BqRRZjuJDIgl8ftRtp3zU5d_Eh-Xltw
cache-control: no-store, must-revalidate, private, max-age=0
x-request-id: 61760a27-4d82-463f-8173-8fcf9a7154bc
x-runtime: 0.219707
server-timing: start_processing.action_controller;dur=0.03, sql.active_record;dur=0.58, instantiation.active_record;dur=0.05, render.active_model_serializers;dur=0.18, process_action.action_controller;dur=214.51
x-miniprofiler-original-cache-control: max-age=0, private, must-revalidate
x-miniprofiler-ids: bcr60cgpyowrpxfuaf1x,dj8ga1yuj4o2yhdrqt9n,q9h7vakssnpplzk73bql,b1ctmtyr5r96galqg5bs,z1vslj92olb3s6hvb0jl,iem1rp4bsf9j8z116pnc,xw2dts24gpo23re1r3mh,7zb5isgdgv2nbqf41q24,2i03hy565et8vyptfy02,qefsm1zly2tn6f8w84ke,6gc75ud47ucasxlnbl9l,li1c9vtqjuka0mm4bdxa,ygy1gw8lrxhit3xrbogk,at0prj6s2p8vtmmifbp5,l0qy4gy46xg6off07oly,rbpc6j6odilry6t3yhm7,7cu67a080gicqe47o97l,6cc3gv0745cjr29u0gla,ruhw7a2aphhh293vljea,4byxhssg66h1rpofhd79
set-cookie: __profilin=p%3Dt; path=/; httponly; SameSite=Lax
Content-Length: 206

{"message":"logged in successfully","user":{"id":112,"full_name":"Willis Little","email":"user@example.com","created_at":"2024-05-20T10:03:50.432Z","updated_at":"2024-05-20T10:03:50.432Z","locale":"en"}}%
```

Logout:

```bash
DELETE /api/v1/users/logout
```

### Appointments

#### Get all appointments

```bash
GET /api/v1/appointments
```

Example:

```bash
curl --request GET \
  --url http://localhost:3000/api/v1/appointments/ \
  --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMTIiLCJzY3AiOiJ1c2VyIiwiYXVkIjpudWxsLCJpYXQiOjE3MTYyMDE3ODgsImV4cCI6MTcxNjI4ODE4OCwianRpIjoiN2QwOTJiZjYtNDgzMC00MGY0LWI0NTItNGM3YTU2NmFjMzgxIn0.ZhDivr5cDcQ4BqRRZjuJDIgl8ftRtp3zU5d_Eh-Xltw' \
  --header 'Content-Type: application/json'
```

Response:

```json
[
 {
  "id": 92,
  "appointment_date": "2024-05-25",
  "start_time": "14:00",
  "end_time": "14:30",
  "doctor": {
   "id": 5,
   "full_name": "Duane Fritsch DO",
   "email": "nu@oconnell.example",
   "specialty": "Neurology",
   "session_length": 30
  },
  "patient": {
   "id": 112,
   "full_name": "Willis Little",
   "email": "user@example.com"
  }
 },
 {
  "id": 93,
  "appointment_date": "2024-05-25",
  "start_time": "14:00",
  "end_time": "14:15",
  "doctor": {
   "id": 6,
   "full_name": "Dr. Russ Brown",
   "email": "esteban@willms.test",
   "specialty": "Gastroenterology",
   "session_length": 15
  },
  "patient": {
   "id": 112,
   "full_name": "Willis Little",
   "email": "user@example.com"
  }
 },
 {
  "id": 94,
  "appointment_date": "2024-05-23",
  "start_time": "14:00",
  "end_time": "15:00",
  "doctor": {
   "id": 7,
   "full_name": "Chadwick Rosenbaum",
   "email": "bertie_durgan@hills-huel.test",
   "specialty": "Radiology",
   "session_length": 60
  },
  "patient": {
   "id": 112,
   "full_name": "Willis Little",
   "email": "user@example.com"
  }
 }
]
```

#### Get a specific appointment

```bash
GET /api/v1/appointments/:id
```

Example:

```bash
curl --request GET \
  --url http://localhost:3000/api/v1/appointments/93 \
  --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMTIiLCJzY3AiOiJ1c2VyIiwiYXVkIjpudWxsLCJpYXQiOjE3MTYyMDE3ODgsImV4cCI6MTcxNjI4ODE4OCwianRpIjoiN2QwOTJiZjYtNDgzMC00MGY0LWI0NTItNGM3YTU2NmFjMzgxIn0.ZhDivr5cDcQ4BqRRZjuJDIgl8ftRtp3zU5d_Eh-Xltw' \
  --header 'Content-Type: application/json'
```

Response:

```json
{
 "id": 93,
 "appointment_date": "2024-05-25",
 "start_time": "14:00",
 "end_time": "14:15",
 "doctor": {
  "id": 6,
  "full_name": "Dr. Russ Brown",
  "email": "esteban@willms.test",
  "specialty": "Gastroenterology",
  "session_length": 15
 },
 "patient": {
  "id": 112,
  "full_name": "Willis Little",
  "email": "user@example.com"
 }
}
```

#### Create an appointment

```bash
POST /api/v1/appointments
```

Example:

```bash
curl --request POST \
  --url http://localhost:3000/api/v1/appointments \
  --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMTIiLCJzY3AiOiJ1c2VyIiwiYXVkIjpudWxsLCJpYXQiOjE3MTYyMDE3ODgsImV4cCI6MTcxNjI4ODE4OCwianRpIjoiN2QwOTJiZjYtNDgzMC00MGY0LWI0NTItNGM3YTU2NmFjMzgxIn0.ZhDivr5cDcQ4BqRRZjuJDIgl8ftRtp3zU5d_Eh-Xltw' \
  --header 'Content-Type: application/json' \
  --data '{
 "appointment": {
  "doctor_id": "5",
  "appointment_date": "2024-05-25",
  "start_time": "14:00"
 }
}'
```

Response:

```json
{
 "id": 92,
 "appointment_date": "2024-05-25",
 "start_time": "14:00",
 "end_time": "14:30",
 "doctor": {
  "id": 5,
  "full_name": "Duane Fritsch DO",
  "email": "nu@oconnell.example",
  "specialty": "Neurology",
  "session_length": 30
 },
 "patient": {
  "id": 112,
  "full_name": "Willis Little",
  "email": "user@example.com"
 }
}
```

#### Update an appointment

```bash
PUT /api/v1/appointments/:id
```

Example:

```bash
curl --request PUT \
  --url http://localhost:3000/api/v1/appointments/92 \
  --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMTIiLCJzY3AiOiJ1c2VyIiwiYXVkIjpudWxsLCJpYXQiOjE3MTYyMDE3ODgsImV4cCI6MTcxNjI4ODE4OCwianRpIjoiN2QwOTJiZjYtNDgzMC00MGY0LWI0NTItNGM3YTU2NmFjMzgxIn0.ZhDivr5cDcQ4BqRRZjuJDIgl8ftRtp3zU5d_Eh-Xltw' \
  --header 'Content-Type: application/json' \
  --data '{
 "appointment": {
  "appointment_date": "2024-5-23",
  "start_time": "12:05"
 }
}'
```

Response:

```json
{
 "id": 92,
 "appointment_date": "2024-05-23",
 "start_time": "12:05",
 "end_time": "12:35",
 "doctor": {
  "id": 5,
  "full_name": "Duane Fritsch DO",
  "email": "nu@oconnell.example",
  "specialty": "Neurology",
  "session_length": 30
 },
 "patient": {
  "id": 112,
  "full_name": "Willis Little",
  "email": "user@example.com"
 }
}
```

#### Delete an appointment

```bash
DELETE /api/v1/appointments/:id
```

Example:

```bash
curl --request DELETE \
  --url http://localhost:3000/api/v1/appointments/79 \
  --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMTIiLCJzY3AiOiJ1c2VyIiwiYXVkIjpudWxsLCJpYXQiOjE3MTYyMDE3ODgsImV4cCI6MTcxNjI4ODE4OCwianRpIjoiN2QwOTJiZjYtNDgzMC00MGY0LWI0NTItNGM3YTU2NmFjMzgxIn0.ZhDivr5cDcQ4BqRRZjuJDIgl8ftRtp3zU5d_Eh-Xltw'
```

Response:

```text
no content
```

### Doctors

#### Get doctor working hours for a specific date

```bash
GET /api/v1/doctors/:id/working_hours/:date
```

Example:

```bash
curl --request GET \
  --url http://localhost:3000/api/v1/doctors/2/working_hours/2024-05-25 \
  --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMTIiLCJzY3AiOiJ1c2VyIiwiYXVkIjpudWxsLCJpYXQiOjE3MTYyMDE3ODgsImV4cCI6MTcxNjI4ODE4OCwianRpIjoiN2QwOTJiZjYtNDgzMC00MGY0LWI0NTItNGM3YTU2NmFjMzgxIn0.ZhDivr5cDcQ4BqRRZjuJDIgl8ftRtp3zU5d_Eh-Xltw'
```

Response:

```json
[
 {
  "date": "2024-05-25",
  "start_time": "10:00",
  "end_time": "16:00"
 }
]
```

#### Get doctor working hours for the next 7 days

```bash
GET /api/v1/doctors/:id/working_hours
```

Example:

```bash
curl --request GET \
  --url http://localhost:3000/api/v1/doctors/5/working_hours \
  --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMTIiLCJzY3AiOiJ1c2VyIiwiYXVkIjpudWxsLCJpYXQiOjE3MTYyMDE3ODgsImV4cCI6MTcxNjI4ODE4OCwianRpIjoiN2QwOTJiZjYtNDgzMC00MGY0LWI0NTItNGM3YTU2NmFjMzgxIn0.ZhDivr5cDcQ4BqRRZjuJDIgl8ftRtp3zU5d_Eh-Xltw'
```

Response:

```json
[
 {
  "date": "2024-05-20",
  "start_time": "09:00",
  "end_time": "18:00"
 },
 {
  "date": "2024-05-21",
  "start_time": "09:00",
  "end_time": "16:00"
 },
 {
  "date": "2024-05-22",
  "start_time": "09:00",
  "end_time": "18:00"
 },
 {
  "date": "2024-05-23",
  "start_time": "10:00",
  "end_time": "17:00"
 },
 {
  "date": "2024-05-24",
  "start_time": "10:00",
  "end_time": "16:00"
 },
 {
  "date": "2024-05-25",
  "start_time": "10:00",
  "end_time": "17:00"
 },
 {
  "date": "2024-05-26",
  "start_time": "08:00",
  "end_time": "19:00"
 }
]
```

#### Get doctor availability for a specific date

```bash
GET /api/v1/doctors/:id/availability/:date
```

Example:

```bash
curl --request GET \
  --url http://localhost:3000/api/v1/doctors/5/availability/2024-05-25 \
  --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMTIiLCJzY3AiOiJ1c2VyIiwiYXVkIjpudWxsLCJpYXQiOjE3MTYyMDE3ODgsImV4cCI6MTcxNjI4ODE4OCwianRpIjoiN2QwOTJiZjYtNDgzMC00MGY0LWI0NTItNGM3YTU2NmFjMzgxIn0.ZhDivr5cDcQ4BqRRZjuJDIgl8ftRtp3zU5d_Eh-Xltw'
```

Response:

```json
[
 {
  "date": "2024-05-25",
  "start_time": "10:30",
  "end_time": "11:00"
 },
 {
  "date": "2024-05-25",
  "start_time": "11:30",
  "end_time": "12:00"
 },
 {
  "date": "2024-05-25",
  "start_time": "12:30",
  "end_time": "17:00"
 }
]
```

#### Get doctor availability for the next 7 days

```bash
GET /api/v1/doctors/:id/availability
```

Example:

```bash
curl --request GET \
  --url http://localhost:3000/api/v1/doctors/5/availability \
  --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMTIiLCJzY3AiOiJ1c2VyIiwiYXVkIjpudWxsLCJpYXQiOjE3MTYyMDE3ODgsImV4cCI6MTcxNjI4ODE4OCwianRpIjoiN2QwOTJiZjYtNDgzMC00MGY0LWI0NTItNGM3YTU2NmFjMzgxIn0.ZhDivr5cDcQ4BqRRZjuJDIgl8ftRtp3zU5d_Eh-Xltw'
```

Response:

```json
[
 {
  "date": "2024-05-20",
  "start_time": "09:30",
  "end_time": "18:00"
 },
 {
  "date": "2024-05-21",
  "start_time": "09:00",
  "end_time": "14:00"
 },
 {
  "date": "2024-05-21",
  "start_time": "14:30",
  "end_time": "15:00"
 },
 {
  "date": "2024-05-21",
  "start_time": "15:30",
  "end_time": "16:00"
 },
 {
  "date": "2024-05-22",
  "start_time": "09:00",
  "end_time": "18:00"
 },
 {
  "date": "2024-05-23",
  "start_time": "10:00",
  "end_time": "17:00"
 },
 {
  "date": "2024-05-24",
  "start_time": "10:00",
  "end_time": "12:00"
 },
 {
  "date": "2024-05-24",
  "start_time": "12:30",
  "end_time": "16:00"
 },
 {
  "date": "2024-05-25",
  "start_time": "10:30",
  "end_time": "11:00"
 },
 {
  "date": "2024-05-25",
  "start_time": "11:30",
  "end_time": "12:00"
 },
 {
  "date": "2024-05-25",
  "start_time": "12:30",
  "end_time": "17:00"
 },
 {
  "date": "2024-05-26",
  "start_time": "08:00",
  "end_time": "19:00"
 }
]
```

## Running Tests

To run the test suite, execute:

```sh
docker compose run web rspec
```
