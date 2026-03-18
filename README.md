# Department Engagement & Career Platform (DECP)

A microservices-based social and career platform for students and alumni of the **Department of Computer Engineering, University of Peradeniya**.

**Course:** CO528 — Applied Software Architecture

---

## Project Overview

DECP facilitates networking, career opportunities, and academic collaboration through a modular, scalable microservices architecture. The platform enables students to connect with alumni, share posts, apply for jobs/internships, participate in department events, collaborate on research, exchange real-time messages, and find mentors.

### Features

| Feature            | Description                                                               |
| ------------------ | ------------------------------------------------------------------------- |
| **Authentication** | JWT-based login with role-based access control (STUDENT / ALUMNI / ADMIN) |
| **User Profiles**  | Registration, profile management, alumni directory                        |
| **Social Feed**    | Posts with likes, comments, and media attachments                         |
| **Job Portal**     | Job/internship listings with full application workflow                    |
| **Campus Events**  | Event creation, RSVP management, attendee tracking                        |
| **Research Hub**   | Academic papers with versioning, DOI linking, and citations               |
| **Messaging**      | Real-time 1-on-1 chat via WebSocket + STOMP                               |
| **Notifications**  | Centralized notification hub driven by RabbitMQ events                    |
| **Analytics**      | Platform-wide usage statistics (admin dashboard, CSV export)              |
| **Mentorship**     | AI-scored alumni–student mentor matching and relationship management      |

---

## Tech Stack

| Layer         | Technology                                                         |
| ------------- | ------------------------------------------------------------------ |
| **Backend**   | Java 17, Spring Boot 3.2.3, Spring Cloud Gateway                   |
| **Frontend**  | React 19 (TypeScript), Vite, TailwindCSS, Axios, React Router 7    |
| **Databases** | PostgreSQL 15 (relational), MongoDB 6 (documents), Redis 7 (cache) |
| **Messaging** | RabbitMQ 3 (async event-driven communication)                      |
| **Real-time** | WebSocket + STOMP (SockJS fallback)                                |
| **DevOps**    | Docker, Docker Compose, Taskfile                                   |

---

## Architecture

```
                        ┌─────────────────┐
                        │   Web Client    │
                        │ React/Vite 5173 │
                        └────────┬────────┘
                                 │
                        ┌────────▼────────┐
                        │  API Gateway    │
                        │  (8080) + JWT   │
                        └──┬──┬──┬──┬──┬──┘
         ┌─────────────────┤  │  │  │  ├─────────────────┐
         ▼          ▼      ▼  ▼  ▼  ▼      ▼            ▼
    ┌────────┐ ┌────────┐ ┌────┐┌────┐ ┌───────┐  ┌──────────┐
    │  Auth  │ │  User  │ │Post││Job │ │ Event │  │Research  │
    │  8081  │ │  8082  │ │8083││8084│ │ 8085  │  │  8086    │
    └────────┘ └────────┘ └────┘└────┘ └───────┘  └──────────┘
    ┌──────────┐ ┌──────────┐ ┌───────────┐ ┌────────────┐
    │Messaging │ │  Notif.  │ │ Analytics │ │ Mentorship │
    │   8087   │ │   8088   │ │   8089    │ │    8090    │
    └──────────┘ └──────────┘ └───────────┘ └────────────┘
         │            │             │              │
    ┌────▼────┐  ┌────▼────┐  ┌────▼────┐  ┌─────▼─────┐
    │ MongoDB │  │  Redis  │  │ Postgre │  │ RabbitMQ  │
    └─────────┘  └─────────┘  └─────────┘  └───────────┘
```

### Services

| Service                  | Port | Database           | Description                                    |
| ------------------------ | ---- | ------------------ | ---------------------------------------------- |
| **API Gateway**          | 8080 | —                  | Routes, JWT validation, CORS, header injection |
| **Auth Service**         | 8081 | —                  | Login, JWT generation/validation               |
| **User Service**         | 8082 | PostgreSQL         | Registration, profiles, alumni directory       |
| **Post Service**         | 8083 | MongoDB            | Social feed, likes, comments                   |
| **Job Service**          | 8084 | PostgreSQL         | Job listings, applications                     |
| **Event Service**        | 8085 | PostgreSQL         | Campus events, RSVP                            |
| **Research Service**     | 8086 | PostgreSQL         | Papers, versioning, DOI, citations             |
| **Messaging Service**    | 8087 | MongoDB            | Real-time chat (WebSocket/STOMP)               |
| **Notification Service** | 8088 | MongoDB + Redis    | Event-driven notifications                     |
| **Analytics Service**    | 8089 | PostgreSQL + Redis | Admin metrics, export                          |
| **Mentorship Service**   | 8090 | PostgreSQL         | Mentor matching, relationships, feedback       |

### Infrastructure

| Component     | Port         | Purpose                                                                |
| ------------- | ------------ | ---------------------------------------------------------------------- |
| PostgreSQL 15 | 5433         | Relational data (users, jobs, events, research, analytics, mentorship) |
| MongoDB 6     | 27018        | Document data (posts, messages, notifications)                         |
| Redis 7       | 6379         | Caching (notifications, analytics)                                     |
| RabbitMQ 3    | 5672 / 15672 | Async event bus / Management UI                                        |

---

## Quick Start

### Prerequisites

- **Java JDK 17**
- **Node.js 18+**
- **Docker Desktop**
- **[Task](https://taskfile.dev/installation/)** — install with `winget install Task.Task` or `brew install go-task`

### One-command startup

```bash
git clone https://github.com/DinethShakya23/uop-decp-microservices.git
cd uop-decp-microservices
cp .env.example .env
task install:frontend
task start
```

This will:

1. Start infrastructure containers (PostgreSQL, MongoDB, Redis, RabbitMQ)
2. Build all 11 backend services
3. Launch everything in parallel (backend + frontend)

Open **http://localhost:5173** in your browser.

### Verify everything is running

```bash
task health
```

### Stop everything

```bash
task stop
```

### Deploy On AWS EC2 (Docker Compose)

Use a single Ubuntu EC2 instance (recommended: t3.large) for a budget-friendly deployment.

1. Open EC2 Security Group inbound ports: `22`, `80`, `8080`
2. SSH into EC2 and run:

```bash
git clone https://github.com/DinethShakya23/uop-decp-microservices.git
cd uop-decp-microservices
bash scripts/setup-ec2.sh
newgrp docker
cp .env.aws.example .env.aws
```

3. Edit `.env.aws` with strong passwords and your EC2 public URL/domain.
4. Deploy:

```bash
bash scripts/deploy-ec2.sh
```

This uses:
- `docker-compose.aws.yml` for full stack
- `docker-compose.ec2.yml` to expose only `80` (web) and `8080` (gateway)

> See [GETTING_STARTED.md](GETTING_STARTED.md) for the full developer setup guide with all available Task commands.

---

## Project Structure

```
├── backend/
│   ├── pom.xml                 # Parent POM (all 11 modules)
│   ├── mvnw.cmd                # Maven wrapper
│   ├── api-gateway/            # Spring Cloud Gateway + JWT filter
│   ├── auth-service/           # Authentication + JWT generation
│   ├── user-service/           # User profiles + registration
│   ├── post-service/           # Social feed + posts (MongoDB)
│   ├── job-service/            # Job listings + applications
│   ├── event-service/          # Campus events + RSVP
│   ├── research-service/       # Academic research hub
│   ├── messaging-service/      # Real-time chat (WebSocket)
│   ├── notification-service/   # Notification center (RabbitMQ)
│   ├── analytics-service/      # Platform analytics (admin)
│   └── mentorship-service/     # Mentor matching + feedback
├── frontend/
│   └── web-client/             # React + TypeScript + Vite + TailwindCSS
├── designs/                    # Architecture diagrams (JSX)
├── docker-compose.yml          # Dev infrastructure
├── docker-compose.prod.yml     # Full production stack
├── Taskfile.yml                # Task runner (single-command startup)
├── .env.example                # Environment variable template
├── GETTING_STARTED.md          # Developer setup guide
├── MOBILE_API_REFERENCE.md     # Mobile developer API docs
└── PROJECT_PLAN.md             # Implementation plan
```

---

## Security & Roles

| Role        | Capabilities                                                                          |
| ----------- | ------------------------------------------------------------------------------------- |
| **STUDENT** | View content, create posts, apply for jobs, RSVP events, request mentors              |
| **ALUMNI**  | All student capabilities + post jobs, create events, upload research, mentor students |
| **ADMIN**   | All capabilities + analytics dashboard, content moderation                            |

### Authentication Flow

1. Client sends `POST /api/auth/login` with `{username, password}`
2. Auth Service validates credentials against User Service
3. JWT token returned with `{sub: username, role: UserRole}` claims (24h expiry)
4. Client includes `Authorization: Bearer <token>` on all subsequent requests
5. API Gateway validates the JWT and injects `X-User-Name`, `X-User-Id`, `X-User-Role` headers for downstream services

### Public Endpoints (no token required)

| Method | Path                        | Description       |
| ------ | --------------------------- | ----------------- |
| POST   | `/api/auth/login`           | Login             |
| GET    | `/api/auth/test`            | Health check      |
| GET    | `/api/auth/validate?token=` | Token validation  |
| POST   | `/api/users/register`       | Register new user |

All other endpoints require a valid JWT token.

---

## API Endpoints

> For complete request/response schemas, see [MOBILE_API_REFERENCE.md](MOBILE_API_REFERENCE.md).

### Auth Service — `/api/auth`

| Method | Path                        | Auth   | Description       |
| ------ | --------------------------- | ------ | ----------------- |
| POST   | `/api/auth/login`           | Public | Login → JWT token |
| GET    | `/api/auth/validate?token=` | Public | Validate token    |
| GET    | `/api/auth/test`            | Public | Health check      |

### User Service — `/api/users`

| Method | Path                          | Auth     | Description           |
| ------ | ----------------------------- | -------- | --------------------- |
| POST   | `/api/users/register`         | Public   | Register new user     |
| GET    | `/api/users/{id}`             | Required | Get user profile      |
| GET    | `/api/users/search?username=` | Required | Find user by username |
| GET    | `/api/users/alumni`           | Required | Alumni directory      |

### Post Service — `/api/posts`

| Method | Path                      | Auth     | Description      |
| ------ | ------------------------- | -------- | ---------------- |
| POST   | `/api/posts`              | Required | Create post      |
| GET    | `/api/posts`              | Required | Get all posts    |
| POST   | `/api/posts/{id}/like`    | Required | Like/unlike post |
| POST   | `/api/posts/{id}/comment` | Required | Add comment      |

### Job Service — `/api/jobs`

| Method | Path                                   | Auth         | Description         |
| ------ | -------------------------------------- | ------------ | ------------------- |
| POST   | `/api/jobs`                            | ALUMNI/ADMIN | Create job listing  |
| GET    | `/api/jobs`                            | Required     | List all jobs       |
| GET    | `/api/jobs/{id}`                       | Required     | Get job details     |
| POST   | `/api/jobs/{id}/apply`                 | STUDENT      | Apply for job       |
| GET    | `/api/jobs/{id}/applications`          | Required     | Job applications    |
| GET    | `/api/jobs/user/{userId}/applications` | Required     | User's applications |

### Event Service — `/api/events`

| Method | Path                         | Auth         | Description     |
| ------ | ---------------------------- | ------------ | --------------- |
| POST   | `/api/events`                | ALUMNI/ADMIN | Create event    |
| GET    | `/api/events`                | Required     | List events     |
| GET    | `/api/events/upcoming`       | Required     | Upcoming events |
| GET    | `/api/events/{id}`           | Required     | Event details   |
| PUT    | `/api/events/{id}`           | Required     | Update event    |
| DELETE | `/api/events/{id}`           | Required     | Delete event    |
| POST   | `/api/events/{id}/rsvp`      | Required     | RSVP to event   |
| GET    | `/api/events/{id}/attendees` | Required     | Attendee list   |

### Research Service — `/api/research`

| Method | Path                          | Auth         | Description                         |
| ------ | ----------------------------- | ------------ | ----------------------------------- |
| POST   | `/api/research`               | ALUMNI/ADMIN | Upload research                     |
| GET    | `/api/research`               | Required     | List (filter: `category`, `search`) |
| GET    | `/api/research/{id}`          | Required     | Details                             |
| PUT    | `/api/research/{id}`          | Required     | Update                              |
| DELETE | `/api/research/{id}`          | Required     | Delete                              |
| GET    | `/api/research/user/{userId}` | Required     | By author                           |
| GET    | `/api/research/tag/{tag}`     | Required     | By tag                              |
| POST   | `/api/research/{id}/version`  | Required     | Add version                         |
| GET    | `/api/research/{id}/versions` | Required     | Version history                     |
| POST   | `/api/research/{id}/cite`     | Required     | Get citations (BibTeX, APA)         |
| POST   | `/api/research/{id}/download` | Required     | Track download                      |

### Messaging Service — `/api/conversations`

| Method | Path                                 | Auth     | Description          |
| ------ | ------------------------------------ | -------- | -------------------- |
| POST   | `/api/conversations`                 | Required | Start conversation   |
| GET    | `/api/conversations`                 | Required | List conversations   |
| GET    | `/api/conversations/{id}`            | Required | Conversation details |
| GET    | `/api/conversations/{id}/messages`   | Required | Paginated messages   |
| PUT    | `/api/conversations/{id}/read`       | Required | Mark read            |
| DELETE | `/api/conversations/{id}`            | Required | Delete conversation  |
| GET    | `/api/conversations/online?userIds=` | Required | Online status        |

**WebSocket:** `ws://localhost:8080/ws/chat` — STOMP over WebSocket with SockJS fallback.

| STOMP Destination                  | Purpose               |
| ---------------------------------- | --------------------- |
| `/app/chat/send`                   | Send message          |
| `/app/chat/typing`                 | Typing indicator      |
| `/topic/messages/{conversationId}` | Subscribe to messages |
| `/topic/typing/{conversationId}`   | Subscribe to typing   |

### Notification Service — `/api/notifications`

| Method | Path                              | Auth     | Description        |
| ------ | --------------------------------- | -------- | ------------------ |
| GET    | `/api/notifications`              | Required | User notifications |
| PUT    | `/api/notifications/{id}/read`    | Required | Mark as read       |
| PUT    | `/api/notifications/read-all`     | Required | Mark all read      |
| GET    | `/api/notifications/unread-count` | Required | Unread count       |
| DELETE | `/api/notifications/{id}`         | Required | Delete             |

### Analytics Service — `/api/analytics` (ADMIN only)

| Method | Path                                     | Description         |
| ------ | ---------------------------------------- | ------------------- |
| GET    | `/api/analytics/overview`                | Platform overview   |
| GET    | `/api/analytics/users`                   | User metrics        |
| GET    | `/api/analytics/posts`                   | Post engagement     |
| GET    | `/api/analytics/jobs`                    | Job market metrics  |
| GET    | `/api/analytics/events`                  | Event metrics       |
| GET    | `/api/analytics/research`                | Research metrics    |
| GET    | `/api/analytics/messages`                | Messaging metrics   |
| GET    | `/api/analytics/timeline?from=&to=`      | Historical timeline |
| GET    | `/api/analytics/export?format=csv&type=` | CSV export          |

### Mentorship Service — `/api/mentorship`

| Method | Path                                          | Auth         | Description           |
| ------ | --------------------------------------------- | ------------ | --------------------- |
| POST   | `/api/mentorship/profile`                     | Required     | Create/update profile |
| GET    | `/api/mentorship/profile`                     | Required     | Own profile           |
| GET    | `/api/mentorship/profile/{userId}`            | Required     | User's profile        |
| GET    | `/api/mentorship/matches`                     | Required     | AI-scored matches     |
| GET    | `/api/mentorship/matches/advanced`            | Required     | Filtered matches      |
| POST   | `/api/mentorship/request`                     | STUDENT      | Send request          |
| PUT    | `/api/mentorship/request/{id}`                | ALUMNI/ADMIN | Accept/reject         |
| GET    | `/api/mentorship/requests`                    | Required     | List requests         |
| GET    | `/api/mentorship/relationships`               | Required     | Active relationships  |
| PUT    | `/api/mentorship/relationships/{id}`          | Required     | Update relationship   |
| DELETE | `/api/mentorship/relationships/{id}`          | Required     | End relationship      |
| POST   | `/api/mentorship/relationships/{id}/feedback` | Required     | Submit feedback       |
| GET    | `/api/mentorship/relationships/{id}/feedback` | Required     | View feedback         |

---

## Event-Driven Communication

Services communicate asynchronously via RabbitMQ:

| Event               | Published By     | Consumed By          |
| ------------------- | ---------------- | -------------------- |
| `user.registered`   | User Service     | Notification Service |
| `post.created`      | Post Service     | Notification Service |
| `post.liked`        | Post Service     | Notification Service |
| `post.commented`    | Post Service     | Notification Service |
| `job.created`       | Job Service      | Notification Service |
| `job.applied`       | Job Service      | Notification Service |
| `event.created`     | Event Service    | Notification Service |
| `event.rsvp`        | Event Service    | Notification Service |
| `research.uploaded` | Research Service | Notification Service |

---

## Task Commands

| Command              | Description                                |
| -------------------- | ------------------------------------------ |
| `task start`         | Start everything (infra → build → run all) |
| `task stop`          | Stop infrastructure containers             |
| `task infra`         | Start only databases and RabbitMQ          |
| `task build:backend` | Build all backend JARs                     |
| `task run:all`       | Run all services + frontend in parallel    |
| `task run:backend`   | Run only backend services                  |
| `task run:frontend`  | Run frontend dev server                    |
| `task health`        | Check health of all services               |
| `task docker:up`     | Production mode (Docker)                   |
| `task clean`         | Remove all build artifacts                 |

See [GETTING_STARTED.md](GETTING_STARTED.md) for the complete list.

---

## Design Diagrams

Interactive architecture diagrams built as React components (in `designs/`):

1. **SOA Diagram** — Service-Oriented Architecture with all services, endpoints, and RabbitMQ events
2. **Enterprise Architecture** — Full layered architecture from client to cloud infrastructure
3. **Deployment Diagram** — AWS cloud deployment with ECS Fargate, RDS, DocumentDB
4. **Product Modularity** — Module breakdown with shared components and dependencies
5. **Platform Research** — LinkedIn vs Facebook vs DECP feature comparison

---

## Containerization

```bash
# Build and run everything in Docker (production)
task docker:build
task docker:up

# Or manually
docker compose -f docker-compose.prod.yml up --build -d
```

---

## Documentation

| Document                                 | Description                                  |
| ---------------------------------------- | -------------------------------------------- | --- |
| [GETTING_STARTED.md](GETTING_STARTED.md) | Developer setup guide with all Task commands |     |

---

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-feature`)
3. Commit changes (`git commit -m "Add my feature"`)
4. Push to the branch (`git push origin feature/my-feature`)
5. Open a Pull Request
