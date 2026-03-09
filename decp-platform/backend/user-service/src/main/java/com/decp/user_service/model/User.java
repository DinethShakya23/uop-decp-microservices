package com.decp.user_service.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "users")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 100)
    private String name;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(name = "password_hash", nullable = false)
    private String passwordHash;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Role role;

    @Column(columnDefinition = "TEXT")
    private String bio;

    @Column(length = 100)
    private String department;

    @Column(name = "graduation_year")
    private Integer graduationYear;

    @Column(name = "research_interests", columnDefinition = "TEXT")
    private String researchInterests; 

    @Column(name = "course_projects", columnDefinition = "TEXT")
    private String courseProjects;

    @Column(columnDefinition = "VARCHAR(255) DEFAULT 'ACTIVE'")
    private String status = "ACTIVE";

    @Builder.Default
    @Column(name = "profile_views")
    private Long profileViews = 0L;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }
    
    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = LocalDateTime.now();
    }
}