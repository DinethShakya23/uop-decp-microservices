# 11 — Research Findings: Analysis of Real-World Platforms

## 1. Overview

This document summarizes the research analysis conducted on real-world platforms (LinkedIn, Facebook) to understand their architectures, identify gaps relevant to a departmental engagement context, and propose design decisions for the UniConnect platform.

## 2. Platform Analysis

### 2.1 LinkedIn (Professional Context)

| Aspect | Findings |
|--------|----------|
| **Strengths** | Excels in professional identity management and recruitment |
| **Architecture** | Relies heavily on microservices and graph databases to map complex professional relationships (the "Economic Graph") |
| **Limitation** | Broad scope makes it difficult to facilitate hyper-local, department-specific academic collaboration |

### 2.2 Facebook (Social Context)

| Aspect | Findings |
|--------|----------|
| **Strengths** | Optimized for high-throughput media sharing, community grouping, and event management |
| **Architecture** | Highly distributed service-oriented architecture tailored for real-time feed generation and messaging |
| **Limitation** | Casual nature is not conducive to professional recruitment or structured academic research sharing |

## 3. Identified Gaps

While both platforms are highly successful, they lack the specific focus required for a **closed-ecosystem departmental platform**:

### 3.1 Fragmented Academic-Professional Identity

Neither platform natively supports **verified academic milestones** (e.g., specific lab completions, final year project repositories) alongside professional internship applications. The user profile is either purely social (Facebook) or purely professional (LinkedIn) — never both in a departmental context.

### 3.2 Lack of Contextual Mentorship Mapping

Students struggle to find alumni based on highly specific departmental context. For example, finding an alumnus who completed the same "Applied Software Architecture" module and now works in cloud DevOps requires manual searching that neither platform efficiently supports.

### 3.3 Generic Content Feeds

Existing platforms mix casual updates with critical job announcements, leading to **information fatigue**. A departmental platform needs strict separation between social engagement and academic/career opportunities.

## 4. Proposed Design Decisions

Based on the research findings, the UniConnect architecture incorporates the following decisions to address the identified gaps:

### 4.1 Graph-Based Relationship Mapping

| Aspect | Detail |
|--------|--------|
| **Gap Addressed** | Contextual mentorship mapping |
| **Decision** | Use a graph database (Neo4j) rather than a purely relational model for user connections |
| **Benefit** | Efficiently query complex, multi-hop relationships |
| **Example Query** | `Student → completed → Project X → supervised by → Lecturer Y → who also supervised → Alumni Z` |

This allows the system to surface contextually relevant mentors and collaborators that traditional SQL JOINs cannot efficiently compute.

### 4.2 Domain-Driven Feed Separation

| Aspect | Detail |
|--------|--------|
| **Gap Addressed** | Generic content feeds causing information fatigue |
| **Decision** | Completely decouple the Feed Service from the Career/Announcements Service in the SOA |
| **Benefit** | Each has distinct API endpoints, allowing client applications to render them in **separate UI tabs** with different priority caching strategies |
| **Implementation** | Feed Service → `/api/posts/*`, Career Service → `/api/jobs/*` |

Critical academic announcements and job postings will never be buried under social media posts.

### 4.3 Unified Portfolio-Profile Integration

| Aspect | Detail |
|--------|--------|
| **Gap Addressed** | Fragmented academic-professional identity |
| **Decision** | Extend the user profile beyond standard demographics to include dedicated data schemas for "Research Interests" and "Course Projects" |
| **Benefit** | The platform acts as both a **social profile and a technical portfolio** for internship applications |
| **Schema Fields** | `researchInterests[]`, `courseProjects[]`, `graduationYear`, `department` |

This eliminates the fragmentation between a student's academic identity and their professional profile.

## 5. Comparative Summary

| Feature | LinkedIn | Facebook | UniConnect |
|---------|----------|----------|------------|
| Professional profiles | ✅ | ❌ | ✅ (with academic context) |
| Social feed | Limited | ✅ | ✅ (separated from career) |
| Job applications | ✅ | ❌ | ✅ (department-scoped) |
| Academic milestones | ❌ | ❌ | ✅ (research interests, projects) |
| Contextual mentorship | ❌ | ❌ | ✅ (graph-based mapping) |
| Department-scoped | ❌ | ❌ | ✅ |
| Feed/career separation | ❌ | ❌ | ✅ |
| Microservices architecture | ✅ | ✅ | ✅ |
| Graph database | ✅ (Economic Graph) | Partial | ✅ (Neo4j / MongoDB) |

## 6. Key Takeaways

1. **Neither LinkedIn nor Facebook** is designed for a closed, department-specific ecosystem that blends academic progress with professional networking.
2. **Graph-based data modeling** (inspired by LinkedIn's Economic Graph) is essential for contextual relationship queries.
3. **Strict service separation** (inspired by Facebook's SOA) prevents information overload by isolating social and career content.
4. **Unified profile design** addresses the gap between academic identity and professional portfolio that both platforms leave unfilled.
