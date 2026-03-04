# 07 — API Specification

## 1. Overview

This document provides the full REST API reference for all UniConnect microservices. All endpoints follow RESTful conventions, use JSON payloads, and require JWT authentication unless marked as **Public**.

**Base URL**: `https://<domain>/api`

**Authentication**: All protected endpoints require `Authorization: Bearer <JWT>` header.

---

## 2. User Service (Port 8081)

Base path: `/api/users`

### 2.1 Register

| Field | Value |
|-------|-------|
| **Method** | `POST` |
| **Path** | `/api/users/register` |
| **Auth** | Public |
| **Description** | Create a new user account |

**Request Body:**

```json
{
  "name": "string",
  "email": "string",
  "password": "string",
  "role": "STUDENT | ALUMNI | ADMIN"
}
```

**Response** `201 Created`:

```json
{
  "id": 1,
  "name": "string",
  "email": "string",
  "role": "STUDENT",
  "createdAt": "2026-03-02T00:00:00Z"
}
```

### 2.2 Login

| Field | Value |
|-------|-------|
| **Method** | `POST` |
| **Path** | `/api/users/login` |
| **Auth** | Public |
| **Description** | Authenticate and receive JWT |

**Request Body:**

```json
{
  "email": "string",
  "password": "string"
}
```

**Response** `200 OK`:

```json
{
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "expiresIn": 3600,
  "role": "STUDENT"
}
```

### 2.3 Get Profile

| Field | Value |
|-------|-------|
| **Method** | `GET` |
| **Path** | `/api/users/{id}/profile` |
| **Auth** | JWT |
| **Description** | Retrieve user profile details |

**Response** `200 OK`:

```json
{
  "id": 1,
  "name": "string",
  "email": "string",
  "role": "STUDENT",
  "bio": "string",
  "department": "Computer Engineering",
  "graduationYear": 2025,
  "researchInterests": ["string"],
  "courseProjects": ["string"],
  "createdAt": "2026-03-02T00:00:00Z"
}
```

### 2.4 Update Profile

| Field | Value |
|-------|-------|
| **Method** | `PUT` |
| **Path** | `/api/users/{id}/profile` |
| **Auth** | JWT (owner only) |
| **Description** | Update user profile information |

**Request Body:**

```json
{
  "name": "string",
  "bio": "string",
  "department": "string",
  "graduationYear": 2025,
  "researchInterests": ["string"],
  "courseProjects": ["string"]
}
```

**Response** `200 OK`: Updated profile object.

---

## 3. Feed Service (Port 8082)

Base path: `/api/posts`

### 3.1 Get Feed

| Field | Value |
|-------|-------|
| **Method** | `GET` |
| **Path** | `/api/posts/feed` |
| **Auth** | JWT |
| **Description** | Retrieve the authenticated user's timeline |

**Query Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `page` | int | 0 | Page number (0-indexed) |
| `size` | int | 20 | Items per page |

**Response** `200 OK`:

```json
{
  "content": [
    {
      "id": "string",
      "authorId": 1,
      "authorName": "string",
      "text": "string",
      "mediaUrl": "string | null",
      "likesCount": 5,
      "commentsCount": 2,
      "createdAt": "2026-03-02T10:30:00Z"
    }
  ],
  "page": 0,
  "size": 20,
  "totalElements": 100
}
```

### 3.2 Create Post

| Field | Value |
|-------|-------|
| **Method** | `POST` |
| **Path** | `/api/posts` |
| **Auth** | JWT |
| **Description** | Create a new text post |

**Request Body:**

```json
{
  "text": "string",
  "mediaUrl": "string | null"
}
```

**Response** `201 Created`:

```json
{
  "id": "string",
  "authorId": 1,
  "text": "string",
  "mediaUrl": null,
  "createdAt": "2026-03-02T10:30:00Z"
}
```

### 3.3 Get Single Post

| Field | Value |
|-------|-------|
| **Method** | `GET` |
| **Path** | `/api/posts/{id}` |
| **Auth** | JWT |
| **Description** | Retrieve a specific post by ID |

**Response** `200 OK`: Post object (same schema as feed items).

### 3.4 Delete Post

| Field | Value |
|-------|-------|
| **Method** | `DELETE` |
| **Path** | `/api/posts/{id}` |
| **Auth** | JWT (author only) |
| **Description** | Delete a post |

**Response** `204 No Content`

### 3.5 Toggle Like

| Field | Value |
|-------|-------|
| **Method** | `POST` |
| **Path** | `/api/posts/{id}/likes` |
| **Auth** | JWT |
| **Description** | Add or remove the authenticated user's like on a post |

**Response** `200 OK`:

```json
{
  "postId": "string",
  "liked": true,
  "likesCount": 6
}
```

### 3.6 Add Comment

| Field | Value |
|-------|-------|
| **Method** | `POST` |
| **Path** | `/api/posts/{id}/comments` |
| **Auth** | JWT |
| **Description** | Add a comment to a post |

**Request Body:**

```json
{
  "text": "Great work!"
}
```

**Response** `201 Created`:

```json
{
  "commentId": "string",
  "postId": "string",
  "userId": 1,
  "text": "Great work!",
  "createdAt": "2026-03-02T12:00:00Z"
}
```

---

## 4. Career Service (Port 8083)

Base path: `/api/jobs`

### 4.1 List Jobs

| Field | Value |
|-------|-------|
| **Method** | `GET` |
| **Path** | `/api/jobs` |
| **Auth** | JWT |
| **Description** | List available jobs and internships |

**Query Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `page` | int | 0 | Page number |
| `size` | int | 20 | Items per page |
| `type` | string | all | Filter: `JOB`, `INTERNSHIP`, or `all` |

**Response** `200 OK`:

```json
{
  "content": [
    {
      "id": 1,
      "title": "string",
      "company": "string",
      "type": "JOB | INTERNSHIP",
      "description": "string",
      "postedBy": 1,
      "deadline": "2026-04-01",
      "createdAt": "2026-03-02T00:00:00Z"
    }
  ],
  "page": 0,
  "size": 20,
  "totalElements": 50
}
```

### 4.2 Create Job

| Field | Value |
|-------|-------|
| **Method** | `POST` |
| **Path** | `/api/jobs` |
| **Auth** | JWT (Alumni / Admin only) |
| **Description** | Post a new job or internship |

**Request Body:**

```json
{
  "title": "string",
  "company": "string",
  "type": "JOB | INTERNSHIP",
  "description": "string",
  "deadline": "2026-04-01"
}
```

**Response** `201 Created`: Job object.

### 4.3 Get Job Details

| Field | Value |
|-------|-------|
| **Method** | `GET` |
| **Path** | `/api/jobs/{id}` |
| **Auth** | JWT |
| **Description** | Fetch details of a specific job posting |

**Response** `200 OK`: Job object.

### 4.4 Apply for Job

| Field | Value |
|-------|-------|
| **Method** | `POST` |
| **Path** | `/api/jobs/{id}/apply` |
| **Auth** | JWT (Student only) |
| **Description** | Submit an application for a job/internship |

**Request Body:**

```json
{
  "coverLetter": "string",
  "resumeUrl": "string"
}
```

**Response** `201 Created`:

```json
{
  "applicationId": 1,
  "jobId": 1,
  "applicantId": 1,
  "status": "SUBMITTED",
  "submittedAt": "2026-03-02T12:00:00Z"
}
```

---

## 5. Error Response Format

All services return errors in a consistent format:

```json
{
  "timestamp": "2026-03-02T12:00:00Z",
  "status": 400,
  "error": "Bad Request",
  "message": "Validation failed: email is required",
  "path": "/api/users/register"
}
```

| HTTP Status | Meaning |
|-------------|---------|
| `400` | Bad Request — validation errors |
| `401` | Unauthorized — missing or invalid JWT |
| `403` | Forbidden — insufficient role |
| `404` | Not Found — resource does not exist |
| `500` | Internal Server Error |

---

## 6. API Gateway Routing Rules

| Path Pattern | Target Service |
|--------------|----------------|
| `/api/users/**` | User Service (:8081) |
| `/api/posts/**` | Feed Service (:8082) |
| `/api/jobs/**` | Career Service (:8083) |
| `/**` (fallback) | React Web App (static assets) |
