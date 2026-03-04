# 10 — Quality Attribute Justifications

## 1. Overview

This document outlines the **non-functional requirements (NFRs)** targeted by the UniConnect architecture and the specific design decisions implemented to achieve them. Each quality attribute is mapped to a concrete architectural decision with a clear justification.

## 2. Quality Attribute Summary

| Quality Attribute | Architectural Decision | Service/Layer Affected |
|-------------------|----------------------|----------------------|
| Scalability | Microservices + Kubernetes | All services |
| Security | API Gateway + JWT | Gateway, User Service |
| Performance | Polyglot Persistence | Feed Service, Career Service |
| Interoperability | Unified RESTful APIs | All services, clients |
| Maintainability | Modular SOA Design | All services |

## 3. Detailed Justifications

### 3.1 Scalability

| Aspect | Detail |
|--------|--------|
| **Decision** | Microservices Architecture (SOA) + Containerization & Cloud Orchestration |
| **Implementation** | Each module (User, Feed, Career) is a separate Spring Boot service, containerized with Docker and orchestrated via Kubernetes on AWS/GCP |
| **Justification** | Deploying backend services and databases in the cloud using Docker and Kubernetes allows services to **scale independently**. For example, during peak graduation seasons, the Career Service can be allocated more pod replicas without wasting cloud resources on the Feed Service. |
| **Metric** | Horizontal Pod Autoscaler (HPA) triggers scaling at 70% CPU utilization |

### 3.2 Security

| Aspect | Detail |
|--------|--------|
| **Decision** | API Gateway + JWT Authorization |
| **Implementation** | Spring Cloud Gateway acts as a centralized security checkpoint. JWTs are issued by the User Service and validated at the gateway before any internal microservice is exposed |
| **Justification** | Utilizing a centralized API Gateway ensures that **all web and mobile traffic passes through a single security checkpoint**. JWTs are validated here, ensuring strict role-based access control (Student, Alumni, Admin) before any internal microservice is exposed. |
| **Controls** | Password hashing (BCrypt), HTTPS-only communication, rate limiting at gateway, CORS policies |

### 3.3 Performance

| Aspect | Detail |
|--------|--------|
| **Decision** | Polyglot Persistence (MySQL + MongoDB/Neo4j) |
| **Implementation** | Relational databases (MySQL) handle structured user data; graph/document databases (MongoDB/Neo4j) handle feed and social relationship data |
| **Justification** | Relational databases handle structured user data effectively but struggle with highly connected social data. Utilizing a graph database like Neo4j for the Feed Service optimizes complex traversal queries (e.g., finding alumni connections), **preventing the latency bottlenecks** typical of heavy SQL JOIN operations. |
| **Example** | Feed retrieval with MongoDB: O(1) document lookup vs. multi-table SQL JOIN |

### 3.4 Interoperability

| Aspect | Detail |
|--------|--------|
| **Decision** | Unified RESTful API Contracts |
| **Implementation** | Both Web (React) and Mobile (React Native) clients consume the exact same backend REST APIs through the API Gateway |
| **Justification** | By designing Web Oriented and Mobile Architectures to consume the **exact same backend APIs**, the system ensures a single source of truth. This prevents business logic duplication and ensures seamless data synchronization between the React web frontend and React Native mobile application. |
| **Standard** | All APIs follow REST conventions with JSON payloads and standard HTTP status codes |

### 3.5 Maintainability & Modifiability

| Aspect | Detail |
|--------|--------|
| **Decision** | Modular SOA with isolated Spring Boot domains |
| **Implementation** | User, Feed, and Career modules are separate Spring Boot applications with independent codebases, databases, and deployment pipelines |
| **Justification** | By breaking the system into isolated Spring Boot domains (User, Feed, Career), the architecture ensures product modularity. **Code changes, bug fixes, or the addition of optional features in one service will not impact the compilation or execution** of the core platform. |
| **Benefit** | Teams can develop, test, and deploy services independently |

## 4. Quality Attribute Scenarios

### 4.1 Scalability Scenario

| Element | Description |
|---------|-------------|
| **Stimulus** | 500 concurrent job applications during graduation week |
| **Source** | Student users |
| **Environment** | Normal + peak load |
| **Artifact** | Career Service |
| **Response** | Kubernetes HPA scales Career Service pods from 2 → 6 |
| **Measure** | Response time remains < 500ms at p95 |

### 4.2 Security Scenario

| Element | Description |
|---------|-------------|
| **Stimulus** | Unauthorized API request without valid JWT |
| **Source** | External attacker |
| **Environment** | Runtime |
| **Artifact** | API Gateway |
| **Response** | Request rejected with HTTP 401 before reaching any microservice |
| **Measure** | 0% of unauthorized requests reach internal services |

### 4.3 Performance Scenario

| Element | Description |
|---------|-------------|
| **Stimulus** | User scrolls feed requesting 20 posts |
| **Source** | Authenticated user (web/mobile) |
| **Environment** | Normal load |
| **Artifact** | Feed Service + MongoDB |
| **Response** | Feed data retrieved from MongoDB with indexed query |
| **Measure** | Response time < 200ms at p95 |

## 5. Trade-off Analysis

| Trade-off | Decision | Rationale |
|-----------|----------|-----------|
| Consistency vs. Performance | Eventual consistency for feed data (MongoDB) | Feed posts do not require strict ACID; eventual consistency provides better read throughput |
| Complexity vs. Scalability | Microservices over monolith | Increased operational complexity is justified by independent scaling and deployment capabilities |
| Storage cost vs. Query speed | Denormalized author name in posts | Avoids cross-service calls for feed rendering; accepted data duplication for read performance |
