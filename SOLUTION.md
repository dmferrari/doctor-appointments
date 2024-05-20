# Solution Document

## Thought Process

The main goal of the Clinic Challenge project is to create a robust, secure, and scalable API service for managing doctor appointments. Here is a summary of the key considerations and decisions made during the development process:

### Dockerization

- Why?: To ensure consistent development environments and ease of deployment.
- How?: Using a multi-stage Dockerfile to keep the final image lightweight and leveraging Docker Compose to orchestrate services (web, database, Redis, and Sidekiq).

### Gemfile Selection

- Why?: To include necessary gems for authentication (Devise and JWT), authorization (Rolify), background job processing (Sidekiq), and performance monitoring (Bullet and rack-mini-profiler).
- How?: Carefully selected versions to ensure compatibility and added version constraints to avoid breaking changes.

### API Structure

- Why?: To follow RESTful principles and provide a clear and intuitive API structure.
- How?: Created namespaced controllers (e.g., `Api::V1::AppointmentsController`) and defined routes accordingly.

### Background Jobs

- Why?: To handle time-consuming tasks like sending email notifications without blocking the main thread.
- How?: Used Sidekiq for background job processing and created jobs for appointment notifications and daily reminders.

## Data Models
