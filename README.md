# Course & Tutor API

A Rails API-only application demonstrating a **Course → Tutors** relationship, built as part of an assignment.

## Overview

- A **Course** can have many **Tutors**.
- A **Tutor** belongs to exactly one **Course**.

This project exposes two REST endpoints:

1. `POST /api/courses` — Create a course along with its tutors in a single request.
2. `GET /api/courses` — List all courses along with their associated tutors.

## Tech Stack

- Ruby 3.0.2
- Rails 7.1 (API-only)
- PostgreSQL
- Jbuilder (for JSON view templates)
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

## Data Model & Validations

### Course
| Field      | Type   | Constraints                          |
|------------|--------|---------------------------------------|
| `name`     | string | required, unique, DB `NOT NULL` + unique index |
| `duration` | string | required, must match format like `"3 months"`, DB `NOT NULL` |

**Custom validations:**
- Must have at least one tutor when created.
- Duration must match the pattern `<number> <day(s)/week(s)/month(s)/year(s)>` (e.g. `"3 months"`, `"2 weeks"`).
- Tutors submitted together in the same request cannot share the same name.

### Tutor
| Field   | Type   | Constraints                                   |
|---------|--------|------------------------------------------------|
| `name`  | string | required, unique within the same course        |
| `email` | string | required, globally unique, valid email format, DB `NOT NULL` + unique index |
| `course`| belongs_to | required (`course_id` FK, `NOT NULL`)     |

## API Endpoints

### Create a Course with Tutors

`POST /api/courses`

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

**Success Response:** `201 Created`
```json
{
  "id": 1,
  "name": "Ruby on Rails",
  "duration": "3 months",
  "tutors": [
    { "id": 1, "name": "Alice", "email": "alice@example.com" },
    { "id": 2, "name": "Bob", "email": "bob@example.com" }
  ]
}
```

**Error Response (validation failure):** `422 Unprocessable Content`
```json
{
  "errors": [
    "Name can't be blank",
    "Course must have at least one tutor"
  ]
}
```

### List All Courses with Tutors

`GET /api/courses`

**Response:** `200 OK`
```json
[
  {
    "id": 1,
    "name": "Ruby on Rails",
    "duration": "3 months",
    "tutors": [
      { "id": 1, "name": "Alice", "email": "alice@example.com" }
    ]
  }
]
```

Returns `[]` if no courses exist.

## Running Tests

```bash
bundle exec rspec
```

Includes:
- **Model specs** — validations, associations, custom business rules (Course/Tutor)
- **Request specs** — full API behavior including success cases, validation failures, and edge cases (duplicate names/emails, missing fields, invalid duration format, courses without tutors)

Current status: **38 examples, 0 failures**