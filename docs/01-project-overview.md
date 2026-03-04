# 01 — Project Overview

## 1. Introduction

**Project Name**: UniConnect — Department Engagement & Career Platform (DECP)
**Course**: CO528 Applied Software Architecture
**Institution**: Department of Computer Engineering, University of Peradeniya

UniConnect is a real-world-inspired department engagement platform that serves current students, alumni, and administrators, while also supporting external entities (academics/companies) through managed platform workflows. The platform allows users to connect, share posts, apply for jobs and internships, collaborate on research, and participate in events via web and mobile clients.

## 2. Objectives

- Design a modular, service-oriented architecture with clearly defined API contracts.
- Implement core services (User, Feed, Career) as independent microservices.
- Provide both web (React) and mobile (React Native) client applications consuming the same backend APIs.
- Deploy the backend and databases on a cloud provider (AWS/GCP) using containerization.
- Justify all architectural decisions against measurable quality attributes (NFRs).

## 3. Scope

### In Scope

| Area | Details |
|------|---------|
| User Management | Registration, login, profile editing, role assignment (Student, Alumni, Admin) |
| Feed & Media | Text posts, feed viewing, basic engagement (likes/comments) |
| Career & Opportunities | Job/internship posting, applications, status tracking |
| Architecture | SOA, Enterprise, Product Modularity, and Deployment diagrams |
| Clients | React web app + React Native mobile app |
| Cloud Deployment | Backend + database hosted on AWS/GCP with Docker & Kubernetes |

### Out of Scope (Optional / Extended)

These modules are documented in the architecture but are not required for the core deliverable:

- Event Management (RSVP, notifications)
- Research Collaboration (project creation, document sharing)
- Real-Time Communication (direct messaging via WebSocket)
- Analytics Dashboard (active users, post metrics)

## 4. Team Roles

| Role | Responsibility |
|------|----------------|
| Enterprise Architect | Defines high-level module integration, user roles, and departmental workflow |
| Solution Architect | Designs the end-to-end technical solution across all layers |
| Application Architect | Designs microservice boundaries, API contracts, and module communication |
| Security Architect | Designs JWT-based authentication, RBAC, and API Gateway security |
| DevOps Architect | Manages Docker, Kubernetes, CI/CD pipelines, and cloud deployment |

## 5. Project Requirements

### Functional Requirements

1. **User Management** — Register/login, edit profile, role-based access (Student, Alumni, Admin), authentication & authorization for web/mobile.
2. **Feed & Media Posts** — Post text updates, upload images/videos, like/comment/share functionality.
3. **Jobs & Internships** — Post jobs/internships, apply for opportunities via web/mobile clients.

### Non-Functional Requirements (Quality Attributes)

| Quality Attribute | Target |
|-------------------|--------|
| Scalability | Services scale independently via Kubernetes pod replicas |
| Security | Centralized JWT validation at API Gateway with RBAC |
| Performance | Polyglot persistence — SQL for structured data, graph DB for relationships |
| Interoperability | Unified RESTful API consumed by both web and mobile clients |
| Maintainability | Isolated microservices; changes in one service do not affect others |

## 6. Architecture Requirements

| Architecture Style | Description |
|--------------------|-------------|
| SOA | Each module is a separate service with well-defined APIs |
| Web Oriented Architecture | Web client consumes backend APIs |
| Mobile Architecture | Mobile client consumes the same backend APIs |
| Cloud Architecture | Backend + database deployed on AWS/GCP |
| Enterprise Architecture | High-level diagram showing module integration, user roles, and workflow |
| Product Architecture | Modular design with core + optional features and reusable components |

## 7. Deliverables

1. **Architecture Diagrams** — SOA, Enterprise, Product Modularity, Deployment
2. **Functional Web & Mobile Clients** — Working features for core modules
3. **Cloud Deployment** — Backend and database live on cloud
4. **Documentation** — Architecture decisions, deployment steps, research findings, quality justifications
5. **Additional** — Screenshots, demo links, README, GitHub repository with code

## 8. Evaluation Criteria

| Criterion | Focus Area |
|-----------|------------|
| Architecture Design | Correctness and clarity of SOA, Enterprise, and Product Modular diagrams including cloud deployment |
| Implementation & Functionality | Core services work; web and mobile clients are integrated; modules communicate properly |
| Cloud Deployment & Scalability | Live backend and database on cloud with scalability considerations |
| Documentation & Presentation | Clear explanations, deployment steps, and a professional 3-minute demo |
