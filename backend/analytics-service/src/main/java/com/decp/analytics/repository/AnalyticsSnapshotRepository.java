package com.decp.analytics.repository;

import com.decp.analytics.model.AnalyticsSnapshot;
import com.decp.analytics.model.MetricType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface AnalyticsSnapshotRepository extends JpaRepository<AnalyticsSnapshot, Long> {

    Optional<AnalyticsSnapshot> findByMetricTypeAndSnapshotDate(MetricType metricType, LocalDate snapshotDate);

    @Query("SELECT a FROM AnalyticsSnapshot a WHERE a.metricType = :type ORDER BY a.snapshotDate DESC LIMIT 1")
    Optional<AnalyticsSnapshot> findLatestByMetricType(@Param("type") MetricType metricType);

    List<AnalyticsSnapshot> findBySnapshotDateBetweenOrderBySnapshotDateAsc(LocalDate from, LocalDate to);

    List<AnalyticsSnapshot> findByMetricTypeAndSnapshotDateBetweenOrderBySnapshotDateAsc(
            MetricType metricType, LocalDate from, LocalDate to);

    @Query("SELECT a FROM AnalyticsSnapshot a WHERE a.snapshotDate < :cutoff")
    List<AnalyticsSnapshot> findOlderThan(@Param("cutoff") LocalDate cutoff);
}
