# DECP Mobile App — Backend API Reference

> **Department Engagement & Career Platform**
> Complete API documentation for mobile application development.

## Table of Contents

- [Architecture Overview](#architecture-overview)
- [Base URL & Connection](#base-url--connection)
- [Authentication](#authentication)
- [API Endpoints](#api-endpoints)
  - [Auth Service](#1-auth-service)
  - [User Service](#2-user-service)
  - [Post Service](#3-post-service)
  - [Job Service](#4-job-service)
  - [Event Service](#5-event-service)
  - [Notification Service](#6-notification-service)
  - [Messaging Service (REST + WebSocket)](#7-messaging-service)
  - [Research Service](#8-research-service)
  - [Analytics Service (Admin only)](#9-analytics-service)
  - [Mentorship Service](#10-mentorship-service)
- [WebSocket Integration](#websocket-integration)
- [Enums Reference](#enums-reference)
- [Error Handling](#error-handling)
- [Running the Backend Locally](#running-the-backend-locally)

---

## Architecture Overview

```
┌──────────────┐         ┌──────────────────────┐
│  Mobile App  │ ──────► │  API Gateway (:8080)  │
└──────────────┘         └──────────┬───────────┘
                                    │ routes by path prefix
          ┌─────────────────────────┼─────────────────────────┐
          │           │             │             │            │
     Auth(8081)  User(8082)   Post(8083)    Job(8084)   Event(8085)
          │           │             │             │            │
   Research(8086) Messaging(8087) Notif(8088) Analytics(8089) Mentorship(8090)
```

**All traffic goes through the API Gateway on port 8080.** The gateway:

1. Routes requests to the correct microservice based on the URL path
2. Validates JWT tokens on protected routes
3. Injects user identity headers (`X-User-Name`, `X-User-Id`, `X-User-Role`) into downstream requests

---

## Base URL & Connection

| Environment           | Base URL                      |
| --------------------- | ----------------------------- |
| **Local development** | `http://localhost:8080`       |
| **WebSocket (chat)**  | `ws://localhost:8080/ws/chat` |

All REST endpoints below are relative to the base URL.

### Content Type

All requests and responses use `application/json` unless stated otherwise.

### Date/Time Formats

| Type            | Format   | Example               |
| --------------- | -------- | --------------------- |
| `LocalDateTime` | ISO 8601 | `2026-03-06T14:30:00` |
| `LocalDate`     | ISO 8601 | `2026-03-06`          |
| `LocalTime`     | ISO 8601 | `14:30:00`            |

---

## Authentication

### How It Works

1. User logs in via `POST /api/auth/login` → receives a **JWT token**
2. Include the token in the `Authorization` header for all subsequent requests
3. The API Gateway validates the token and injects identity headers before forwarding

### Auth Header Format

```
Authorization: Bearer <jwt_token>
```

### JWT Token Details

| Property       | Value                                             |
| -------------- | ------------------------------------------------- |
| Algorithm      | HS256                                             |
| Expiry         | 24 hours (86400000 ms)                            |
| Payload claims | `sub` (username), `role` (UserRole), `iat`, `exp` |

### Public Endpoints (no token required)

| Method | Path                           | Description          |
| ------ | ------------------------------ | -------------------- |
| POST   | `/api/auth/login`              | Login                |
| GET    | `/api/auth/test`               | Health check         |
| GET    | `/api/auth/validate?token=...` | Validate a token     |
| POST   | `/api/users/register`          | Register new account |

**All other endpoints require the `Authorization: Bearer <token>` header.**

---

## API Endpoints

### 1. Auth Service

**Base path:** `/api/auth`

#### POST `/api/auth/login`

Login and receive a JWT token.

**Request:**

```json
{
  "username": "john_doe",
  "password": "SecurePass123"
}
```

**Response (200):**

```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "user": {
    "id": 1,
    "username": "john_doe",
    "email": "john@example.com",
    "fullName": "John Doe",
    "bio": "Computer Science student",
    "profilePictureUrl": null,
    "role": "STUDENT"
  }
}
```

**Error (401):** Invalid credentials.

#### GET `/api/auth/validate?token=<jwt>`

Returns `"Valid"` or `"Invalid"` as plain text.

#### GET `/api/auth/test`

Health check. Returns `"Auth service is running"`.

---

### 2. User Service

**Base path:** `/api/users`

#### POST `/api/users/register` — Public

**Request:**

```json
{
  "username": "jane_smith",
  "email": "jane@example.com",
  "password": "MyPassword123",
  "fullName": "Jane Smith",
  "role": "STUDENT"
}
```

**Response (200):**

```json
{
  "id": 2,
  "username": "jane_smith",
  "email": "jane@example.com",
  "fullName": "Jane Smith",
  "bio": null,
  "profilePictureUrl": null,
  "role": "STUDENT"
}
```

#### GET `/api/users/{id}` — Auth required

Get user profile by ID.

**Response:**

```json
{
  "id": 1,
  "username": "john_doe",
  "email": "john@example.com",
  "fullName": "John Doe",
  "bio": "CS student at University of Peradeniya",
  "profilePictureUrl": "https://...",
  "role": "STUDENT"
}
```

#### GET `/api/users/search?username=john_doe` — Auth required

Find user by username.

#### GET `/api/users/alumni` — Auth required

Returns `List<UserDTO>` — all users with role `ALUMNI`.

---

### 3. Post Service

**Base path:** `/api/posts`

> **Note:** The gateway rewrites `/api/posts/**` → `/posts/**` (StripPrefix=1) before reaching the Post Service.

#### POST `/api/posts` — Auth required

Create a new post.

**Request:**

```json
{
  "userId": 1,
  "fullName": "John Doe",
  "content": "Excited to share my final year project!",
  "mediaUrls": ["https://example.com/image.png"]
}
```

**Response (200):**

```json
{
  "id": "65f1a2b3c4d5e6f7a8b9c0d1",
  "userId": 1,
  "username": "john_doe",
  "fullName": "John Doe",
  "content": "Excited to share my final year project!",
  "mediaUrls": ["https://example.com/image.png"],
  "likedBy": [],
  "comments": [],
  "createdAt": "2026-03-06T10:00:00",
  "updatedAt": "2026-03-06T10:00:00"
}
```

#### GET `/api/posts` — Auth required

Get all posts.

**Response:** `List<Post>` ordered by newest first.

#### POST `/api/posts/{postId}/like` — Auth required

Like/unlike a post (toggle).

**Request:**

```json
{
  "userId": 1
}
```

#### POST `/api/posts/{postId}/comment` — Auth required

Add a comment.

**Request:**

```json
{
  "userId": 1,
  "username": "john_doe",
  "text": "Great work!"
}
```

---

### 4. Job Service

**Base path:** `/api/jobs`

#### POST `/api/jobs` — Auth required (ALUMNI/ADMIN only)

Create a job listing.

**Request:**

```json
{
  "title": "Software Engineer Intern",
  "description": "Join our team for a 6-month internship...",
  "company": "TechCorp",
  "location": "Colombo, Sri Lanka",
  "type": "Internship",
  "postedBy": 5,
  "posterName": "Dr. Silva"
}
```

**Response:** `Job` object with auto-generated `id`, `createdAt`, `updatedAt`.

#### GET `/api/jobs` — Auth required

List all jobs.

#### GET `/api/jobs/{id}` — Auth required

Get job details by ID.

#### POST `/api/jobs/{id}/apply` — Auth required (STUDENT only)

Apply to a job.

**Request:**

```json
{
  "jobId": 1,
  "userId": 2,
  "applicantName": "Jane Smith",
  "coverLetter": "I am very interested in this position because...",
  "resumeUrl": "https://example.com/resume.pdf",
  "status": "PENDING"
}
```

#### GET `/api/jobs/{id}/applications` — Auth required

Get all applications for a specific job.

#### GET `/api/jobs/user/{userId}/applications` — Auth required

Get all applications by a specific user.

---

### 5. Event Service

**Base path:** `/api/events`

#### POST `/api/events` — Auth required (ALUMNI/ADMIN only)

**Request:**

```json
{
  "title": "AI Workshop 2026",
  "description": "Hands-on workshop on machine learning",
  "location": "Room A101, Faculty of Engineering",
  "eventDate": "2026-04-15",
  "startTime": "09:00:00",
  "endTime": "17:00:00",
  "category": "WORKSHOP",
  "maxAttendees": 50
}
```

**Response:**

```json
{
  "id": 1,
  "title": "AI Workshop 2026",
  "description": "Hands-on workshop on machine learning",
  "location": "Room A101, Faculty of Engineering",
  "eventDate": "2026-04-15",
  "startTime": "09:00:00",
  "endTime": "17:00:00",
  "organizer": 5,
  "organizerName": "Dr. Perera",
  "category": "WORKSHOP",
  "maxAttendees": 50,
  "createdAt": "2026-03-06T10:00:00",
  "attendeeCount": 0
}
```

#### GET `/api/events` — Auth required

List all events.

#### GET `/api/events/upcoming` — Auth required

List future events only.

#### GET `/api/events/{id}` — Auth required

Get event details.

#### PUT `/api/events/{id}` — Auth required

Update event (body same as create).

#### DELETE `/api/events/{id}` — Auth required

Delete event (organizer or ADMIN only).

#### POST `/api/events/{id}/rsvp` — Auth required

RSVP to an event.

**Request:**

```json
{
  "status": "GOING"
}
```

**Response:**

```json
{
  "id": 1,
  "eventId": 1,
  "userId": 2,
  "userName": "jane_smith",
  "status": "GOING",
  "respondedAt": "2026-03-06T11:00:00"
}
```

#### GET `/api/events/{id}/attendees` — Auth required

Returns `List<RsvpResponse>`.

---

### 6. Notification Service

**Base path:** `/api/notifications`

Notifications are auto-created by backend services via RabbitMQ when events happen (new job, post liked, RSVP, etc). The mobile app only **reads** them.

#### GET `/api/notifications` — Auth required

Get all notifications for the logged-in user.

**Response:**

```json
[
  {
    "id": "65f1a2b3c4d5e6f7a8b9c0d2",
    "userId": "john_doe",
    "type": "POST_LIKED",
    "title": "Post Liked",
    "message": "jane_smith liked your post",
    "referenceId": "65f1a2b3c4d5e6f7a8b9c0d1",
    "referenceType": "POST",
    "read": false,
    "createdAt": "2026-03-06T12:00:00"
  }
]
```

#### PUT `/api/notifications/{id}/read` — Auth required

Mark a single notification as read.

#### PUT `/api/notifications/read-all` — Auth required

Mark all notifications as read.

#### GET `/api/notifications/unread-count` — Auth required

**Response:**

```json
{
  "count": 5
}
```

#### DELETE `/api/notifications/{id}` — Auth required

Delete a notification.

---

### 7. Messaging Service

#### REST Endpoints

**Base path:** `/api/conversations`

##### POST `/api/conversations` — Auth required

Start a new conversation.

**Request:**

```json
{
  "participantIds": [1, 2],
  "participantNames": ["john_doe", "jane_smith"],
  "initialMessage": "Hey!"
}
```

**Response:**

```json
{
  "id": "65f1a2b3c4d5e6f7a8b9c0d3",
  "participants": [1, 2],
  "participantNames": ["john_doe", "jane_smith"],
  "lastMessage": "Hey!",
  "lastMessageAt": "2026-03-06T14:00:00",
  "createdAt": "2026-03-06T14:00:00",
  "unreadCount": 0
}
```

##### GET `/api/conversations` — Auth required

List user's conversations (ordered by last message).

##### GET `/api/conversations/{id}` — Auth required

Get conversation details.

##### GET `/api/conversations/{id}/messages?page=0&size=20` — Auth required

Get paginated messages for a conversation.

**Response (Page):**

```json
{
  "content": [
    {
      "id": "65f1a2b3c4d5e6f7a8b9c0d4",
      "conversationId": "65f1a2b3c4d5e6f7a8b9c0d3",
      "senderId": 1,
      "senderName": "john_doe",
      "content": "Hey!",
      "readBy": [1],
      "createdAt": "2026-03-06T14:00:00"
    }
  ],
  "totalPages": 1,
  "totalElements": 1,
  "number": 0,
  "size": 20
}
```

##### PUT `/api/conversations/{id}/read` — Auth required

Mark all messages in conversation as read.

##### DELETE `/api/conversations/{id}` — Auth required

Delete conversation.

##### GET `/api/conversations/online?userIds=1,2,3` — Auth required

Get which users from the list are currently online.

**Response:** `[1, 3]` (set of online user IDs)

#### WebSocket (Real-time Chat)

See [WebSocket Integration](#websocket-integration) section below.

---

### 8. Research Service

**Base path:** `/api/research`

#### POST `/api/research` — Auth required (ALUMNI/ADMIN only)

Upload research.

**Request:**

```json
{
  "title": "Deep Learning for NLP",
  "researchAbstract": "This paper explores transformer architectures...",
  "authors": ["Dr. Perera", "Dr. Silva"],
  "tags": ["DEEP_LEARNING", "NLP"],
  "documentUrl": "https://example.com/paper.pdf",
  "doi": "10.1234/dl-nlp-2026",
  "category": "PAPER"
}
```

#### GET `/api/research` — Auth required

List all research. Optional query params: `category`, `search`.

```
GET /api/research?category=PAPER&search=machine+learning
```

#### GET `/api/research/{id}` — Auth required

Get research details.

#### PUT `/api/research/{id}` — Auth required

Update research (author only).

#### DELETE `/api/research/{id}` — Auth required

Delete research (author or ADMIN).

#### GET `/api/research/user/{userId}` — Auth required

Get research by a specific author.

#### GET `/api/research/tag/{tag}` — Auth required

Get research by tag (e.g., `/api/research/tag/MACHINE_LEARNING`).

#### POST `/api/research/{id}/version` — Auth required

Add a new version.

**Request:**

```json
{
  "documentUrl": "https://example.com/paper-v2.pdf",
  "changelog": "Updated methodology section"
}
```

#### GET `/api/research/{id}/versions` — Auth required

Get version history.

#### POST `/api/research/{id}/cite` — Auth required

Get citation in multiple formats.

**Response:**

```json
{
  "researchId": 1,
  "title": "Deep Learning for NLP",
  "authors": "Dr. Perera, Dr. Silva",
  "doi": "10.1234/dl-nlp-2026",
  "year": "2026",
  "category": "PAPER",
  "bibtex": "@article{dl-nlp-2026, title={Deep Learning for NLP}, ...}",
  "apa": "Perera & Silva (2026). Deep Learning for NLP. ..."
}
```

#### POST `/api/research/{id}/download` — Auth required

Track a download and return updated research (increments `downloads` counter).

---

### 9. Analytics Service

**Base path:** `/api/analytics`

> **Access:** ADMIN role only. Returns 403 for non-admin users.

| Method | Path                                                    | Description                                                               |
| ------ | ------------------------------------------------------- | ------------------------------------------------------------------------- |
| GET    | `/api/analytics/overview`                               | Platform-wide overview (user counts, engagement trends, top posts/events) |
| GET    | `/api/analytics/users`                                  | User metrics (breakdown by role, retention, most active)                  |
| GET    | `/api/analytics/posts`                                  | Post engagement metrics (likes, comments, trends)                         |
| GET    | `/api/analytics/jobs`                                   | Job market metrics (applications, open positions)                         |
| GET    | `/api/analytics/events`                                 | Event metrics (RSVPs, attendance trends)                                  |
| GET    | `/api/analytics/research`                               | Research metrics (downloads, citations, uploads)                          |
| GET    | `/api/analytics/messages`                               | Messaging metrics (daily/weekly/monthly counts)                           |
| GET    | `/api/analytics/timeline?from=2026-01-01&to=2026-03-06` | Historical metrics timeline                                               |
| GET    | `/api/analytics/export?format=csv&type=users`           | Export data as CSV                                                        |

---

### 10. Mentorship Service

**Base path:** `/api/mentorship`

#### Profiles

| Method | Path                               | Description                      |
| ------ | ---------------------------------- | -------------------------------- |
| POST   | `/api/mentorship/profile`          | Create/update mentorship profile |
| GET    | `/api/mentorship/profile`          | Get own profile                  |
| GET    | `/api/mentorship/profile/{userId}` | Get another user's profile       |

**Create Profile Request:**

```json
{
  "role": "MENTEE",
  "department": "Computer Science",
  "yearsOfExperience": 0,
  "expertise": ["Java", "React"],
  "interests": ["Machine Learning", "Web Development"],
  "bio": "Final year CS student looking for guidance",
  "availability": "AVAILABLE",
  "timezone": "Asia/Colombo",
  "linkedInUrl": "https://linkedin.com/in/janesmith"
}
```

#### Matching

| Method | Path                                                                                   | Description                              |
| ------ | -------------------------------------------------------------------------------------- | ---------------------------------------- |
| GET    | `/api/mentorship/matches`                                                              | Get AI-recommended mentor/mentee matches |
| GET    | `/api/mentorship/matches/advanced?expertise=Java&availability=AVAILABLE&department=CS` | Filtered matches                         |

**Match Response:**

```json
[
  {
    "userId": 5,
    "userName": "dr_perera",
    "profile": { ... },
    "compatibilityScore": 0.87,
    "commonInterests": ["Machine Learning", "Java"],
    "distanceScore": 0.15
  }
]
```

#### Requests

| Method | Path                           | Description                               |
| ------ | ------------------------------ | ----------------------------------------- |
| POST   | `/api/mentorship/request`      | Send mentorship request (STUDENT only)    |
| PUT    | `/api/mentorship/request/{id}` | Accept/reject request (ALUMNI/ADMIN only) |
| GET    | `/api/mentorship/request/{id}` | Get request details                       |
| GET    | `/api/mentorship/requests`     | List all your requests                    |

**Send Request:**

```json
{
  "mentorId": 5,
  "message": "I'd love to learn about ML from you",
  "topics": ["Machine Learning", "Career Guidance"],
  "proposedDuration": "THREE_MONTHS"
}
```

**Accept/Reject:**

```json
{
  "status": "ACCEPTED",
  "rejectionReason": null
}
```

#### Relationships

| Method | Path                                 | Description               |
| ------ | ------------------------------------ | ------------------------- |
| GET    | `/api/mentorship/relationships`      | List active relationships |
| GET    | `/api/mentorship/relationships/{id}` | Get relationship details  |
| PUT    | `/api/mentorship/relationships/{id}` | Update relationship       |
| DELETE | `/api/mentorship/relationships/{id}` | End relationship          |

**Update Relationship:**

```json
{
  "goals": "Learn fundamentals of ML and complete a project",
  "frequency": "BIWEEKLY",
  "preferredChannel": "VIDEO_CALL",
  "status": "ACTIVE"
}
```

#### Feedback

| Method | Path                                          | Description     |
| ------ | --------------------------------------------- | --------------- |
| POST   | `/api/mentorship/relationships/{id}/feedback` | Submit feedback |
| GET    | `/api/mentorship/relationships/{id}/feedback` | View feedback   |

**Submit Feedback:**

```json
{
  "rating": 5,
  "comment": "Excellent mentorship session, very helpful!"
}
```

---

## WebSocket Integration

The messaging service uses **STOMP over WebSocket** with SockJS fallback for real-time chat.

### Connection

**Endpoint:** `ws://localhost:8080/ws/chat` (via Gateway) or `ws://localhost:8087/ws/chat` (direct)

#### Android (OkHttp + StompProtocolAndroid)

```kotlin
// Using krossbow or StompProtocolAndroid library
val client = StompClient(OkHttpWebSocketClient())
val session = client.connect("ws://10.0.2.2:8080/ws/chat")
```

#### iOS (StompClientLib)

```swift
let url = URL(string: "ws://localhost:8080/ws/chat/websocket")!
socketClient.openSocketWithURLRequest(
    URLRequest(url: url),
    delegate: self
)
```

#### React Native (using @stomp/stompjs)

```javascript
import { Client } from "@stomp/stompjs";

const client = new Client({
  brokerURL: "ws://localhost:8080/ws/chat/websocket",
  onConnect: () => {
    console.log("Connected");
  },
});
client.activate();
```

### Subscribe to Messages

```
SUBSCRIBE /topic/messages/{conversationId}
```

Payload received on new message:

```json
{
  "id": "65f1a2b3...",
  "conversationId": "65f1a2b3...",
  "senderId": 1,
  "senderName": "john_doe",
  "content": "Hello!",
  "readBy": [1],
  "createdAt": "2026-03-06T14:30:00"
}
```

### Subscribe to Typing Indicators

```
SUBSCRIBE /topic/typing/{conversationId}
```

Payload:

```json
{
  "conversationId": "65f1a2b3...",
  "userId": 2,
  "userName": "jane_smith",
  "typing": true
}
```

### Subscribe to Read Receipts

```
SUBSCRIBE /topic/read/{conversationId}
```

### Send a Message

```
SEND /app/chat/send
Headers: X-User-Id: 1, X-User-Name: john_doe

{
  "conversationId": "65f1a2b3...",
  "content": "Hello!"
}
```

### Send Typing Indicator

```
SEND /app/chat/typing

{
  "conversationId": "65f1a2b3...",
  "userId": 1,
  "userName": "john_doe",
  "typing": true
}
```

### Online/Offline Status

```
SEND /app/chat/online
Headers: X-User-Id: 1

SEND /app/chat/offline
Headers: X-User-Id: 1
```

---

## Enums Reference

### UserRole

| Value     | Description            |
| --------- | ---------------------- |
| `STUDENT` | Current student        |
| `ALUMNI`  | Graduated alumni       |
| `ADMIN`   | Platform administrator |

### EventCategory

| Value         |
| ------------- |
| `WORKSHOP`    |
| `SEMINAR`     |
| `SOCIAL`      |
| `CAREER_FAIR` |
| `OTHER`       |

### RsvpStatus

| Value       |
| ----------- |
| `GOING`     |
| `MAYBE`     |
| `NOT_GOING` |

### NotificationType

| Value             |
| ----------------- |
| `JOB_APPLICATION` |
| `JOB_CREATED`     |
| `NEW_POST`        |
| `POST_LIKED`      |
| `POST_COMMENTED`  |
| `EVENT_CREATED`   |
| `EVENT_RSVP`      |
| `USER_REGISTERED` |
| `SYSTEM`          |

### ReferenceType (Notification)

| Value   |
| ------- |
| `JOB`   |
| `POST`  |
| `EVENT` |
| `USER`  |

### ResearchCategory

| Value        |
| ------------ |
| `PAPER`      |
| `THESIS`     |
| `PROJECT`    |
| `ARTICLE`    |
| `CONFERENCE` |
| `WORKSHOP`   |

### ResearchTag

| Value                 |
| --------------------- |
| `MACHINE_LEARNING`    |
| `DEEP_LEARNING`       |
| `NLP`                 |
| `COMPUTER_VISION`     |
| `CYBERSECURITY`       |
| `CLOUD_COMPUTING`     |
| `BLOCKCHAIN`          |
| `IOT`                 |
| `WEB_DEVELOPMENT`     |
| `MOBILE_DEVELOPMENT`  |
| `DATABASES`           |
| `SYSTEMS_PROGRAMMING` |
| `ALGORITHMS`          |
| `DATA_SCIENCE`        |
| `BIOINFORMATICS`      |
| `QUANTUM_COMPUTING`   |
| `OTHER`               |

### MentorshipRole

| Value    |
| -------- |
| `MENTOR` |
| `MENTEE` |
| `BOTH`   |

### Availability

| Value              |
| ------------------ |
| `HIGHLY_AVAILABLE` |
| `AVAILABLE`        |
| `LIMITED`          |
| `NOT_AVAILABLE`    |

### RequestStatus (Mentorship)

| Value       |
| ----------- |
| `PENDING`   |
| `ACCEPTED`  |
| `REJECTED`  |
| `CANCELLED` |

### RelationshipStatus

| Value       |
| ----------- |
| `ACTIVE`    |
| `PAUSED`    |
| `COMPLETED` |

### MeetingFrequency

| Value      |
| ---------- |
| `WEEKLY`   |
| `BIWEEKLY` |
| `MONTHLY`  |

### PreferredChannel

| Value        |
| ------------ |
| `EMAIL`      |
| `PHONE`      |
| `VIDEO_CALL` |
| `IN_PERSON`  |
| `MESSAGING`  |

### ProposedDuration (Mentorship)

| Value          |
| -------------- |
| `ONE_MONTH`    |
| `THREE_MONTHS` |
| `SIX_MONTHS`   |
| `ONE_YEAR`     |

### Application Status (Job)

| Value      |
| ---------- |
| `PENDING`  |
| `REVIEWED` |
| `ACCEPTED` |
| `REJECTED` |

---

## Error Handling

### Common HTTP Status Codes

| Code  | Meaning                                 |
| ----- | --------------------------------------- |
| `200` | Success                                 |
| `201` | Created                                 |
| `400` | Bad request (validation error)          |
| `401` | Unauthorized (missing or invalid token) |
| `403` | Forbidden (insufficient role)           |
| `404` | Not found                               |
| `409` | Conflict (duplicate resource)           |
| `500` | Internal server error                   |

### Error Response Format

```json
{
  "timestamp": "2026-03-06T14:30:00",
  "status": 400,
  "error": "Bad Request",
  "message": "Username already exists",
  "path": "/api/users/register"
}
```

### Token Expired

When the JWT expires (after 24 hours), the gateway returns `401`. The mobile app should redirect to the login screen and ask the user to log in again.

---

## Running the Backend Locally

### Prerequisites

- Java JDK 17
- Docker Desktop (for databases)
- [Task](https://taskfile.dev/installation/) (optional, for convenience commands)

### Option A: Using Task (recommended)

```bash
git clone https://github.com/DinethShakya23/uop-decp-microservices.git
cd uop-decp-microservices
cp .env.example .env
task start
```

This starts all infrastructure, builds all services, and launches everything.

### Option B: Manual

```bash
# 1. Start databases
docker compose up -d

# 2. Build backend
cd backend
mvnw.cmd clean package -DskipTests

# 3. Run each service (each in a separate terminal)
cd auth-service && java -jar target/*.jar
cd user-service && java -jar target/*.jar
# ... repeat for all services
```

### Verify Running

```bash
task health
# or manually:
curl http://localhost:8080/api/auth/test
```

### Quick Test Flow

```bash
# 1. Register
curl -X POST http://localhost:8080/api/users/register \
  -H "Content-Type: application/json" \
  -d '{"username":"mobile_dev","email":"dev@test.com","password":"Test123","fullName":"Mobile Dev","role":"STUDENT"}'

# 2. Login
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"mobile_dev","password":"Test123"}'

# 3. Use the returned token
curl http://localhost:8080/api/posts \
  -H "Authorization: Bearer <token_from_step_2>"
```

---

## Notes for Mobile Development

1. **Android emulator:** Use `10.0.2.2` instead of `localhost` to reach the host machine.
2. **iOS simulator:** Use `localhost` or `127.0.0.1` directly.
3. **Token storage:** Store the JWT securely (Android Keystore / iOS Keychain). Do not use SharedPreferences or UserDefaults for tokens.
4. **Token refresh:** There is no refresh token endpoint. On 401, redirect to login.
5. **Image uploads:** The backend accepts `mediaUrls` and `documentUrl` as plain URL strings. You need a separate file upload solution (e.g., Firebase Storage, S3, Cloudinary) and pass the resulting URL to the API.
6. **Pagination:** The messaging endpoint returns Spring `Page` objects. Use `page` (0-indexed) and `size` query params.
7. **Role-based UI:** Use the `role` field from the login response to show/hide features:
   - `STUDENT` — Can apply to jobs, send mentorship requests, view posts/events
   - `ALUMNI` — Can create jobs, events, research, accept mentorship requests
   - `ADMIN` — Full access including analytics dashboard
