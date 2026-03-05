# DECP Microservices — Project Completion Plan

## Department Engagement & Career Platform (DECP)

**Course:** CO528 — Applied Software Architecture  
**University of Peradeniya — Department of Computer Engineering**

---

## 📊 Project Status Overview

### Development Approach: **Backend-First** ✨

**Strategy:** Build all backend services (Phases 2-7) and complete Phase 1 hardening first.
Frontend development (Phase 8) starts only after Phase 2 (Event Service) completion.
This ensures framework stability and reduces frontend rework.

### ✅ Completed

| Component           | Port | Status  | Notes                                             |
| ------------------- | ---- | ------- | ------------------------------------------------- |
| API Gateway         | 8080 | ✅ Done | JWT filter, routing, CORS                         |
| Auth Service        | 8081 | ✅ Done | Login, token validation                           |
| User Service        | 8082 | ✅ Done | Registration, profiles, alumni directory          |
| Post Service        | 8083 | ✅ Done | CRUD, likes, comments (MongoDB)                   |
| Job Service         | 8084 | ✅ Done | Jobs, applications, role-based access             |
| Docker Compose      | —    | ✅ Done | Dev + Production configs                          |
| Design Diagrams (5) | —    | ✅ Done | SOA, Enterprise, Deployment, Modularity, Research |
| Phase 1 (Hardening) | —    | 🔄 50%  | Security, infrastructure, docs (6/12 tasks)       |

### 🔨 To Be Implemented (Backend-First)

**Next Priority (Complete these first):**

| Component            | Port | Phase | Status                      |
| -------------------- | ---- | ----- | --------------------------- |
| Event Service        | 8085 | 2     | 📌 Next (Start immediately) |
| Notification Service | 8088 | 3     | ⏳ After Phase 2            |
| Messaging Service    | 8087 | 4     | ⏳ After Phase 3            |
| Research Service     | 8086 | 5     | ⏳ After Phase 4            |
| Analytics Service    | 8089 | 6     | ⏳ After Phase 5            |
| Mentorship Service   | 8090 | 7     | ⏳ After Phase 6            |

**Then, after Phase 2:**

| Component            | Port | Phase | Status                              |
| -------------------- | ---- | ----- | ----------------------------------- |
| Web Client (React)   | 3000 | 8     | ⏳ Starts after Event Service ready |
| Testing & Deployment | —    | 9     | ⏳ Final phase                      |

### 🔧 Phase 1 Hardening (In Progress)

| Item                                  | Priority | Status | Scope                     |
| ------------------------------------- | -------- | ------ | ------------------------- |
| ✅ Move JWT secret to env var         | Critical | Done   | Auth Service, API Gateway |
| ✅ Add .env file for docker-compose   | Critical | Done   | All services              |
| ✅ Environment variable support       | Critical | Done   | All services              |
| ✅ Update README with API docs        | High     | Done   | Documentation             |
| Add input validation (@Valid)         | High     | TODO   | All DTOs                  |
| Add global exception handler          | High     | TODO   | All services              |
| Standardize Dockerfiles (multi-stage) | High     | TODO   | All services              |
| Add OpenAPI/Swagger UI                | Medium   | TODO   | All services              |
| Add health check endpoints            | Medium   | TODO   | All services              |

---

## 🗓️ Implementation Phases

### Phase 1: Fix & Harden Existing Services ⚡

> Fix critical issues in already-implemented services before building new ones.

**Tasks:**

1. **Security Fixes**
   - [x] Move JWT secret to environment variable (application.yml + docker-compose)
   - [ ] Validate all user inputs (DTOs with `@Valid`, `@NotBlank`, etc.)
   - [ ] Add proper error handling (`@ControllerAdvice` + `GlobalExceptionHandler`)

2. **Infrastructure**
   - [x] Add environment variable support in all `application.yml`
   - [x] Add `.env` file for docker-compose
   - [ ] Standardize all Dockerfiles to multi-stage builds
   - [ ] Add health check endpoints (`/actuator/health`) to all services

3. **Documentation**
   - [ ] Add OpenAPI/Swagger UI to all services (SpringDoc already in dependencies)
   - [x] Update README with complete API documentation

4. **Verification**
   - [x] All 5 backend services build & run successfully
   - [x] All 5 services verified with end-to-end API tests
   - [x] JWT authentication flow working through API Gateway

**Status:** 6/12 tasks completed. Ready to proceed to Phase 2 (Event Service).

---

### Phase 2: Event Service (Port 8085) 📅

> Campus events, department activities, RSVP management.

**Database:** PostgreSQL (shared `decp_db`)  
**Chat:** Create separate chat for implementation

**Endpoints:**
| Method | Path | Description | Access |
|--------|------|-------------|--------|
| POST | `/api/events` | Create event | ALUMNI, ADMIN |
| GET | `/api/events` | List all events | All authenticated |
| GET | `/api/events/{id}` | Get event details | All authenticated |
| PUT | `/api/events/{id}` | Update event | Creator only |
| DELETE | `/api/events/{id}` | Delete event | Creator, ADMIN |
| POST | `/api/events/{id}/rsvp` | RSVP to event | All authenticated |
| GET | `/api/events/{id}/attendees` | Get attendees | All authenticated |
| GET | `/api/events/upcoming` | Upcoming events | All authenticated |

**Models:**

- `Event`: id, title, description, location, eventDate, startTime, endTime, organizer (userId), organizerName, category (WORKSHOP, SEMINAR, SOCIAL, CAREER_FAIR, OTHER), maxAttendees, createdAt
- `RSVP`: id, eventId, userId, userName, status (GOING, MAYBE, NOT_GOING), respondedAt

**Events (RabbitMQ):**

- Publish: `event.created`, `event.rsvp`

---

### Phase 3: Notification Service (Port 8088) 🔔

> Central notification hub that subscribes to events from all services.

**Database:** MongoDB (notifications collection)  
**Cache:** Redis (batching queue)  
**Chat:** Create separate chat for implementation

**Endpoints:**
| Method | Path | Description | Access |
|--------|------|-------------|--------|
| GET | `/api/notifications` | Get user notifications | Authenticated user |
| PUT | `/api/notifications/{id}/read` | Mark as read | Owner |
| PUT | `/api/notifications/read-all` | Mark all as read | Owner |
| GET | `/api/notifications/unread-count` | Unread count | Owner |

**RabbitMQ Subscriptions:**

- `user.registered` → Welcome notification
- `post.created` → Notify followers
- `job.applied` → Notify job poster
- `event.created` → Notify all users
- `event.rsvp` → Notify event organizer

**Models:**

- `Notification`: id, userId, type (JOB_APPLICATION, NEW_POST, EVENT_REMINDER, WELCOME, etc.), title, message, referenceId, read, createdAt

---

### Phase 4: Messaging Service (Port 8087) 💬

> Real-time messaging between users using WebSocket + STOMP.

**Database:** MongoDB (messages collection)  
**Chat:** Create separate chat for implementation

**Endpoints:**
| Method | Path | Description | Access |
|--------|------|-------------|--------|
| GET | `/api/messages/conversations` | List conversations | Authenticated |
| GET | `/api/messages/conversations/{id}` | Get messages in conversation | Participants |
| POST | `/api/messages/send` | Send message (REST fallback) | Authenticated |
| WebSocket | `/ws/chat` | Real-time messaging | Authenticated |

**Models:**

- `Conversation`: id, participants[], lastMessage, lastMessageAt, createdAt
- `Message`: id, conversationId, senderId, senderName, content, readBy[], createdAt

---

### Phase 5: Research Service (Port 8086) 📚

> Academic research collaboration hub.

**Database:** MongoDB (research collection)  
**Chat:** Create separate chat for implementation

**Endpoints:**
| Method | Path | Description | Access |
|--------|------|-------------|--------|
| POST | `/api/research` | Upload research | ALUMNI, ADMIN |
| GET | `/api/research` | List all research | All authenticated |
| GET | `/api/research/{id}` | Get research details | All authenticated |
| PUT | `/api/research/{id}` | Update research | Author |
| GET | `/api/research/user/{userId}` | Get user's research | All authenticated |
| POST | `/api/research/{id}/version` | Add new version | Author |

**Models:**

- `Research`: id, title, abstract, authors[], tags[], documentUrl, doi, versions[], category (PAPER, THESIS, PROJECT, ARTICLE), createdAt, updatedAt
- `Version`: versionNumber, documentUrl, changelog, uploadedAt

---

### Phase 6: Analytics Service (Port 8089) 📈

> Platform usage statistics and insights (admin dashboard).

**Database:** PostgreSQL  
**Chat:** Create separate chat for implementation

**Endpoints:**
| Method | Path | Description | Access |
|--------|------|-------------|--------|
| GET | `/api/analytics/overview` | Platform stats | ADMIN |
| GET | `/api/analytics/users` | User statistics | ADMIN |
| GET | `/api/analytics/posts` | Post engagement stats | ADMIN |
| GET | `/api/analytics/jobs` | Job market stats | ADMIN |
| GET | `/api/analytics/events` | Event participation | ADMIN |

**RabbitMQ Subscriptions:**

- Subscribe to all exchanges → aggregate metrics
- Store daily snapshots

---

### Phase 7: Mentorship Service (Port 8090) 🤝

> Alumni-student mentorship matching platform.

**Database:** PostgreSQL  
**Chat:** Create separate chat for implementation

**Endpoints:**
| Method | Path | Description | Access |
|--------|------|-------------|--------|
| POST | `/api/mentorship/profile` | Create mentor/mentee profile | All authenticated |
| GET | `/api/mentorship/matches` | Get suggested matches | All authenticated |
| POST | `/api/mentorship/request` | Send mentorship request | STUDENT |
| PUT | `/api/mentorship/request/{id}` | Accept/reject request | ALUMNI |
| GET | `/api/mentorship/relationships` | Active mentorships | Authenticated |

**Models:**

- `MentorshipProfile`: id, userId, role (MENTOR/MENTEE), skills[], interests[], bio, availability
- `MentorshipRequest`: id, menteeId, mentorId, message, status (PENDING, ACCEPTED, REJECTED), createdAt
- `MentorshipRelationship`: id, mentorId, menteeId, startDate, status (ACTIVE, COMPLETED, PAUSED)

---

### Phase 8: Frontend Development 🎨 — **START AFTER PHASE 2 COMPLETION**

> Build the React web UI for DECP platform.
>
> ⚠️ **IMPORTANT:** Start frontend **ONLY AFTER Event Service (Phase 2)** is completed.
> This ensures a stable backend API contract for the frontend to consume.
>
> **Recommendation:** Backend team completes Phase 2-7 in parallel with frontend development,
> then frontend integrates new services incrementally (Event pages when Phase 2 done, Chat when Phase 4 done, etc.)

**Stack:** React 19, TypeScript, React Router 7, Axios, TailwindCSS

**Core Pages:**

- [ ] LoginPage (`/login`) — Login/Register with JWT
- [ ] DashboardPage (`/dashboard`) — Home feed (posts + upcoming events)
- [ ] JobsPage (`/jobs`) — Job listings, job applications
- [ ] EventsPage (`/events`) — Event listing, RSVP, attendees
- [ ] ProfilePage (`/profile/:id`) — User bio, connections
- [ ] NotificationsPage (`/notifications`) — Real-time notification list
- [ ] ChatPage (`/messages`) — Messaging with users (WebSocket)
- [ ] SettingsPage (`/settings`) — Privacy, account settings

**Frontend Improvements (Phase 1 parallel):**

- [ ] AuthGuard HOC for protected routes
- [ ] JWT token management (localStorage + refresh)
- [ ] Global error handling & toast notifications
- [ ] Loading skeleton screens
- [ ] Real-time WebSocket integration (notifications, chat)
- [ ] Responsive design (mobile-first)
- [ ] Search functionality across posts/jobs/events
- [ ] User avatar upload & profile images
- [ ] Role-based UI visibility (STUDENT/ALUMNI/ADMIN)
- [ ] Post interaction (like, comment) UI
- [ ] Job application form

**Chat:** Create separate chat for frontend implementation when Phase 2 (Event Service) is complete

---

### Phase 9: Testing, Polish & Deployment 🚀

> End-to-end testing, final hardening, and production deployment.

**Backend:**

- [ ] Unit tests for all services (JUnit 5 + Mockito)
- [ ] Integration tests for all endpoints
- [ ] E2E testing for critical flows (register → login → post → job apply → event rsvp)
- [ ] API documentation &amp; Swagger UI setup
- [ ] Performance testing with realistic data volumes
- [ ] Security audit (OWASP checklist, input validation, SQL injection)
- [ ] Load testing &amp; database optimization

**Frontend:**

- [ ] Component unit tests (React Testing Library)
- [ ] E2E tests (Playwright/Cypress)
- [ ] Accessibility (a11y) testing
- [ ] Cross-browser testing
- [ ] Performance profiling &amp; optimization

**Deployment:**

- [ ] Docker multi-stage Dockerfiles for all services
- [ ] Docker Compose for production
- [ ] Kubernetes manifests (optional, for cloud deployment)
- [ ] CI/CD pipeline (GitHub Actions)
- [ ] Environment-based configuration (dev/staging/prod)
- [ ] Database backup &amp; migration scripts

---

## 🏗️ Architecture Summary

```
┌─────────────────────────────────────────────────────────────────┐
│                        CLIENT LAYER                             │
│  ┌──────────────┐  ┌──────────────────┐                        │
│  │  Web Client  │  │  Mobile Client   │                        │
│  │  (React.js)  │  │  (React Native)  │                        │
│  │  Port: 3000  │  │   (Future)       │                        │
│  └──────┬───────┘  └────────┬─────────┘                        │
└─────────┼───────────────────┼──────────────────────────────────┘
          │                   │
          ▼                   ▼
┌─────────────────────────────────────────────────────────────────┐
│                      API GATEWAY (8080)                         │
│            Spring Cloud Gateway + JWT Filter + CORS             │
└──┬──────┬──────┬──────┬──────┬──────┬──────┬──────┬──────┬─────┘
   │      │      │      │      │      │      │      │      │
   ▼      ▼      ▼      ▼      ▼      ▼      ▼      ▼      ▼
┌──────┐┌─────┐┌─────┐┌─────┐┌─────┐┌──────┐┌─────┐┌──────┐┌─────┐
│ Auth ││User ││Post ││ Job ││Event││Notif.││ Msg ││Rsrch.││Analy│
│ 8081 ││8082 ││8083 ││8084 ││8085 ││ 8088 ││8087 ││ 8086 ││8089 │
└──┬───┘└──┬──┘└──┬──┘└──┬──┘└──┬──┘└──┬───┘└──┬──┘└──┬───┘└──┬──┘
   │       │      │      │      │      │       │      │       │
   │       ▼      ▼      │      ▼      │       ▼      ▼       │
   │    ┌─────────────┐  │   ┌──────┐  │    ┌─────────────┐   │
   │    │ PostgreSQL  │◄─┘   │Redis │  │    │   MongoDB   │   │
   │    │ Users,Jobs, │      │Cache │  │    │ Posts,Msgs, │   │
   │    │ Events,Auth │      │      │  │    │ Research    │   │
   │    └─────────────┘      └──────┘  │    └─────────────┘   │
   │                                   │                       │
   └──────────────────┬────────────────┘───────────────────────┘
                      ▼
              ┌──────────────┐
              │   RabbitMQ   │
              │  (Event Bus) │
              └──────────────┘
```

---

## 📁 Service Directory Map

```
backend/
├── pom.xml                    # Parent POM (all modules)
├── api-gateway/               # Spring Cloud Gateway (8080)
├── auth-service/              # Authentication + JWT (8081)
├── user-service/              # User profiles + registration (8082)
├── post-service/              # Social feed + posts (8083)
├── job-service/               # Job listings + applications (8084)
├── event-service/             # 🔨 Campus events + RSVP (8085)
├── research-service/          # 🔨 Academic research hub (8086)
├── messaging-service/         # 🔨 Real-time chat (8087)
├── notification-service/      # 🔨 Notification center (8088)
├── analytics-service/         # 🔨 Platform analytics (8089)
└── mentorship-service/        # 🔨 Mentor matching (8090)

frontend/
└── web-client/                # React TypeScript SPA

designs/                       # Architecture diagrams (JSX)
```

---

## 💻 Chat-Based Implementation Strategy

Since each service will be implemented in a **separate chat**, here's how to approach each:

### Chat Template for Each Service:

```
"I'm building the [SERVICE_NAME] for the DECP microservices project.
Here's the context:
- Project: Department Engagement & Career Platform
- Stack: Spring Boot 3.2.3, Java 17, [PostgreSQL/MongoDB], RabbitMQ
- Parent POM: com.decp:decp-backend:1.0.0-SNAPSHOT
- The service runs on port [PORT]
- Refer to PROJECT_PLAN.md for the complete API spec

Please implement the complete service with:
1. Application entry point
2. Models/Entities
3. Repository layer
4. Service layer
5. Controller with all endpoints
6. DTOs (request/response)
7. RabbitMQ configuration (publisher/subscriber)
8. application.yml
9. pom.xml
10. Dockerfile
"
```

### Recommended Implementation Order:

1. **Event Service** → straightforward CRUD + RSVP, similar to Job Service
2. **Notification Service** → depends on RabbitMQ events from other services
3. **Research Service** → independent MongoDB service
4. **Messaging Service** → WebSocket complexity, do after simpler services
5. **Analytics Service** → subscribes to all events, implement after publishers exist
6. **Mentorship Service** → matching algorithm, most complex business logic

---

## 🔐 Security Architecture

### JWT Flow

```
1. User sends credentials → Auth Service
2. Auth Service validates via User Service (internal call)
3. Auth Service generates JWT with claims: {username, role}
4. JWT returned to client, stored in localStorage
5. All subsequent requests include: Authorization: Bearer <token>
6. API Gateway validates JWT, extracts username/role into headers
7. Downstream services read X-User-Name, X-User-Role headers
```

### Role-Based Access Control

| Role    | Capabilities                                                         |
| ------- | -------------------------------------------------------------------- |
| STUDENT | View all content, apply for jobs, RSVP events, request mentors       |
| ALUMNI  | All student capabilities + post jobs, create events, mentor students |
| ADMIN   | All capabilities + analytics dashboard, manage users, delete content |

---

## 🐳 Running the Project

### Development (infrastructure only)

```bash
docker-compose up -d
# Then run each service individually via IDE or:
cd backend && ./mvnw spring-boot:run -pl auth-service
cd frontend/web-client && npm start
```

### Production (all containers)

```bash
docker-compose -f docker-compose.prod.yml up --build
```

### Service URLs

| Service     | URL                                     |
| ----------- | --------------------------------------- |
| Web Client  | http://localhost:3000                   |
| API Gateway | http://localhost:8080                   |
| RabbitMQ UI | http://localhost:15672 (guest/guest)    |
| Swagger UI  | http://localhost:{port}/swagger-ui.html |

---

## 📋 Deliverables Checklist

- [ ] **Architecture Diagrams** (5 diagrams — ✅ Done)
  - [x] SOA Diagram
  - [x] Enterprise Architecture Diagram
  - [x] Deployment Diagram
  - [x] Product Modularity Diagram
  - [x] Platform Research Comparison
- [ ] **Core Services** (5 services — ✅ Done)
  - [x] API Gateway
  - [x] Auth Service
  - [x] User Service
  - [x] Post Service
  - [x] Job Service
- [ ] **Extended Services** (6 services — 🔨 In Progress)
  - [ ] Event Service
  - [ ] Research Service
  - [ ] Messaging Service
  - [ ] Notification Service
  - [ ] Analytics Service
  - [ ] Mentorship Service
- [ ] **Frontend Pages**
  - [x] Login Page
  - [x] Dashboard (Feed)
  - [x] Jobs Page
  - [ ] Registration Page
  - [ ] Profile Page
  - [ ] Events Page
  - [ ] Messages Page
  - [ ] Research Page
  - [ ] Admin Dashboard
  - [ ] Mentorship Page
- [ ] **Infrastructure**
  - [x] Docker Compose (dev)
  - [x] Docker Compose (prod)
  - [ ] CI/CD Pipeline (GitHub Actions)
  - [ ] Environment configuration (.env)
- [ ] **Quality**
  - [ ] Unit Tests
  - [ ] Integration Tests
  - [ ] API Documentation (Swagger)
  - [ ] Security hardening
- [ ] **Documentation**
  - [x] README.md
  - [x] PROJECT_PLAN.md
  - [ ] API_DOCUMENTATION.md
  - [ ] CONTRIBUTING.md a
