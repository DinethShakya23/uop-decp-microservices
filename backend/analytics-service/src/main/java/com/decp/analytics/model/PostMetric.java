package com.decp.analytics.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "post_metrics")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PostMetric {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String postId;

    private Long createdByUserId;

    @Builder.Default
    private Long likes = 0L;

    @Builder.Default
    private Long comments = 0L;

    @Builder.Default
    private Long shares = 0L;

    @Builder.Default
    private Long views = 0L;

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
