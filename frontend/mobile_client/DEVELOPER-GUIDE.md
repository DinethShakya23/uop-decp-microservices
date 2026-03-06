# DECP Mobile App — Architecture & Developer Reference

Department Engagement & Career Platform (DECP) mobile application built with Flutter.

This document covers the architecture, project structure, and conventions used in the mobile app.

---

## Overview

The DECP mobile app is a Flutter client that communicates with the DECP microservices backend through a REST API gateway and WebSocket endpoints.

**Primary responsibilities of the mobile app:**

- Authentication and session management
- Social feed (posts)
- Job listings and applications
- Events and RSVPs
- Notifications
- Real-time messaging
- Research publications
- Mentorship matching and relationships
- Role-based UI (Student, Alumni, Admin)

The app is designed for scalability using a feature-based Clean Architecture approach.

---

## Tech Stack

| Technology | Purpose |
|---|---|
| Flutter SDK | Cross-platform mobile framework |
| Dart | Programming language |
| Riverpod | State management |
| Dio | HTTP networking |
| GoRouter | Navigation |
| Freezed / Json Serializable | Models |
| Flutter Secure Storage | JWT storage |
| STOMP Dart Client | WebSocket messaging |

---

## Architecture

The mobile app follows a variation of Clean Architecture with three primary layers:

- **Presentation Layer** – Handles UI widgets, screens, and state management.
- **Domain Layer** – Contains business logic and abstract repository interfaces.
- **Data Layer** – Responsible for networking, DTOs, and repository implementations.

**Architecture flow:**

```
UI → Provider / Controller → Use Case → Repository → API Client
```

---

## Project Structure

```
lib/
│
├── core/
│   ├── constants/
│   ├── network/
│   ├── errors/
│   ├── utils/
│   └── storage/
│
├── features/
│   ├── auth/
│   ├── profile/
│   ├── posts/
│   ├── jobs/
│   ├── events/
│   ├── notifications/
│   ├── messaging/
│   ├── research/
│   ├── mentorship/
│   └── admin/
│
├── shared/
│   ├── widgets/
│   └── themes/
│
└── main.dart
```

Each feature module contains:

```
feature_name/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
│
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
│
└── presentation/
    ├── providers/
    ├── screens/
    └── widgets/
```

---

## Core Modules

### Network

The app uses **Dio** as the HTTP client.

Responsibilities:
- Base API configuration
- Request interceptors
- JWT authentication headers
- Error handling

### Authentication Flow

1. User logs in using username and password
2. API returns a JWT token
3. Token is stored securely using Flutter Secure Storage
4. Token is attached to every request using a Dio interceptor
5. If a request returns `401`, user is redirected to login

### State Management

Riverpod is used for managing application state.

Types used:
- `StateNotifierProvider`
- `FutureProvider`
- `StreamProvider`

Feature controllers handle interaction between UI and domain use cases.

### Navigation

Routing is handled with **GoRouter**.

Routes are grouped by feature:

```
/login
/home
/posts
/jobs
/events
/chat
/profile
```

Guards protect authenticated routes.

---

## API Communication

The mobile app communicates only with the API Gateway.

All services are accessed through gateway routes:

```
/api/auth
/api/users
/api/posts
/api/jobs
/api/events
/api/notifications
/api/conversations
/api/research
/api/mentorship
```

---

## Messaging (WebSocket)

Messaging uses **STOMP over WebSocket**.

Features:
- Real-time messages
- Typing indicators
- Read receipts
- Online status

**Subscriptions:**

```
/topic/messages/{conversationId}
/topic/typing/{conversationId}
/topic/read/{conversationId}
```

---

## Role-Based UI

Users have one of three roles:

### Student
- Apply to jobs
- Request mentorship
- Participate in events

### Alumni
- Create jobs
- Host events
- Upload research
- Accept mentorship requests

### Admin
- Access analytics
- Platform moderation

---

## Security

- JWT stored in encrypted storage
- No tokens stored in plain preferences
- All API calls require authorization
- Logout clears stored credentials

---

## Error Handling

All API errors follow a unified response format. The app maps API errors into domain exceptions.

| Error Type | Description |
|---|---|
| Network error | No connectivity or timeout |
| Authentication error | Invalid or expired token |
| Validation error | Bad request input |
| Server error | Internal backend failure |

UI should display friendly messages while logging detailed errors for debugging.

---

## Testing Strategy

**Types of tests used:**
- Unit Tests
- Widget Tests
- Integration Tests

**Focus areas:**
- Repository logic
- Use cases
- State management controllers

---

## Code Conventions

**Guidelines:**
- Follow Dart formatting standards
- Keep widgets small and reusable
- Avoid business logic inside UI widgets
- Prefer immutable models
- Use dependency injection for repositories

**Naming conventions:**

| Convention | Usage |
|---|---|
| `snake_case` | Files |
| `PascalCase` | Classes |
| `camelCase` | Variables and methods |

---

## Future Improvements

- Offline caching
- Push notifications
- File uploads (images, documents)
- Background sync
- Better pagination support
