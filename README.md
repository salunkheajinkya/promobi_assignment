# README

This README would normally document whatever steps are necessary to get the
application up and running.

# Course & Tutor API

A Rails API-only application demonstrating a **Course → Tutors** relationship, built as part of an assignment.

## Overview

- A **Course** can have many **Tutors**.
- A **Tutor** belongs to exactly one **Course**.

This project exposes two REST endpoints:

1. `POST /api/v1/courses` — Create a course along with its tutors in a single request.
2. `GET /api/v1/courses` — List all courses along with their associated tutors.

## Tech Stack

- Ruby 3.0.2
- Rails 7.1 (API-only)
- PostgreSQL
- RSpec, FactoryBot, Faker, Shoulda Matchers (for testing)

## Setup

```bash
git clone https://github.com/<your-username>/promobi_assignment.git
cd promobi_assignment
bundle install
rails db:create
rails db:migrate
```

## Running the server

```bash
rails server
```

API will be available at `http://localhost:3000`.

## API Endpoints

### Create a Course with Tutors

`POST /api/v1/courses`

**Request body:**
```json
{
  "course": {
    "name": "Ruby on Rails",
    "duration": "3 months",
    "tutors_attributes": [
      { "name": "Alice", "email": "alice@example.com" },
      { "name": "Bob", "email": "bob@example.com" }
    ]
  }
}
```

**Response:** `201 Created`
```json
{
  "id": 1,
  "name": "Ruby on Rails",
  "duration": "3 months",
  "tutors": [
    { "id": 1, "name": "Alice", "email": "alice@example.com", "course_id": 1 },
    { "id": 2, "name": "Bob", "email": "bob@example.com", "course_id": 1 }
  ]
}
```

### List All Courses with Tutors

`GET /api/v1/courses`

**Response:** `200 OK`
```json
[
  {
    "id": 1,
    "name": "Ruby on Rails",
    "duration": "3 months",
    "tutors": [
      { "id": 1, "name": "Alice", "email": "alice@example.com", "course_id": 1 }
    ]
  }
]
```

## Running Tests

```bash
bundle exec rspec
```

Includes model specs (validations, associations) and request specs (API behavior, edge cases, error handling).
