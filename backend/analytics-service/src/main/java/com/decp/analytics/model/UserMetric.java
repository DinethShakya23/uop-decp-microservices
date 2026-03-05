package com.decp.analytics.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "user_metrics")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserMetric {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private Long userId;

    private String userName;

    @Enumerated(EnumType.STRING)
    private UserRole role;

    @Builder.Default
    private Long postsCreated = 0L;

    @Builder.Default
    private Long eventsAttended = 0L;

    @Builder.Default
    private Long jobsApplied = 0L;

    @Builder.Default
    private Long researchUploaded = 0L;

    @Builder.Default
    private Long messagesCount = 0L;

    private LocalDateTime lastActiveAt;

    @Builder.Default
    private Long loginCount = 0L;

    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
