# UniConnect — Department Engagement & Career Platform (DECP)

> **CO528 Applied Software Architecture — Mini Project**
> Department of Computer Engineering, University of Peradeniya

## Overview

UniConnect is a department engagement platform designed for current students, alumni, and administrators, with academics/companies participating through platform-managed workflows. It enables users to connect, share posts, apply for jobs/internships, collaborate on research, and participate in events through both web and mobile clients.

The project focuses on **architectural design**, **modularity**, **integration**, **cloud deployment**, and **quality attribute justification** rather than full feature completeness.

## Documentation Index

| # | Document | Description | Diagram |
|---|----------|-------------|---------|
| 1 | [Project Overview](docs/01-project-overview.md) | Scope, objectives, team roles, and requirements | - |
| 2 | [Enterprise Architecture](docs/02-enterprise-architecture.md) | High-level layered architecture with actors, clients, gateway, services, and data | [Enterprise Architecture](diagrams/Enterprise%20Architecture%20Diagram.png) |
| 3 | [SOA Diagram & APIs](docs/03-soa-diagram.md) | Service interactions, sequence diagrams, and REST API contracts | [SOA](diagrams/SOA%20Diagram.png) |
| 4 | [Product Modularity](docs/04-product-modularity.md) | Core vs. optional modules, responsibilities, and design principles | [Product Modularity](diagrams/Product%20Modularity%20Diagram.png) |
| 5 | [Deployment Diagram](docs/05-deployment-diagram.md) | Cloud infrastructure, Kubernetes orchestration, and storage | [Deployment](diagrams/Deployment%20Diagram.png) |
| 6 | [Technology Stack](docs/06-technology-stack.md) | Languages, frameworks, databases, and tooling choices | [Tech Stack](diagrams/Technology%20Stack%20Diagram.png) |
| 7 | [API Specification](docs/07-api-specification.md) | Full REST endpoint reference per microservice | - |
| 8 | [Data Model](docs/08-data-model.md) | ER diagram and schema definitions for SQL and NoSQL stores | [ER Diagram](diagrams/ER%20Diagram.png) |
| 9 | [Use Case Diagram](docs/09-use-case-diagram.md) | Actor-use-case relationships for all core modules | [Use Case](diagrams/Use%20Case%20Diagram.png) |
| 10 | [Quality Attribute Justifications](docs/10-quality-attributes.md) | NFR analysis and architectural decision rationale | - |
| 11 | [Research Findings](docs/11-research-findings.md) | Analysis of LinkedIn, Facebook, and proposed improvements | - |
| 12 | [Cloud Deployment Details](docs/12-cloud-deployment.md) | Backend/database setup, scalability, and deployment steps | - |
| 13 | [Documentation Audit](docs/13-documentation-audit.md) | Change log of documentation consistency and naming fixes | - |

## Architecture at a Glance

- **Architecture Style**: Microservices / SOA
- **Core Services**: User Service, Feed Service, Career Service + API Gateway
- **Clients**: React (Web), React Native (Mobile)
- **Databases**: MySQL (structured data), MongoDB/Neo4j (feed & relationships)
- **Cloud**: AWS / GCP with Docker + Kubernetes
- **Auth**: JWT-based via centralized API Gateway

## Team Roles

| Role | Responsibility |
|------|----------------|
| Enterprise Architect | High-level system integration and stakeholder alignment |
| Solution Architect | End-to-end technical solution design |
| Application Architect | Microservice design, API contracts, and module structure |
| Security Architect | Authentication, authorization, and security policies |
| DevOps Architect | CI/CD, containerization, cloud deployment, and monitoring |

## License

This project is developed for academic purposes as part of CO528 — Applied Software Architecture.
