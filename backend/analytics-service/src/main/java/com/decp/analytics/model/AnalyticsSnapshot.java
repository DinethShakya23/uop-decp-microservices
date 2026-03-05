package com.decp.analytics.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "analytics_snapshots", uniqueConstraints = {
    @UniqueConstraint(columnNames = {"snapshot_date", "metric_type"})
})
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AnalyticsSnapshot {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "snapshot_date", nullable = false)
    private LocalDate snapshotDate;

    @Enumerated(EnumType.STRING)
    @Column(name = "metric_type", nullable = false)
    private MetricType metricType;

    @Builder.Default
    private Long totalCount = 0L;

    @Builder.Default
    private Long newCount = 0L;

    @Builder.Default
    private Long activeCount = 0L;

    @Builder.Default
    private Double engagementScore = 0.0;

    @Builder.Default
    private Double averageEngagement = 0.0;

    private String topItemId;

    private String topItemTitle;

    @Builder.Default
    private Long topItemEngagement = 0L;

    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}
