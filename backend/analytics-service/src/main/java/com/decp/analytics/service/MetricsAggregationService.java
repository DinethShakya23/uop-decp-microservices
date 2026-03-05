package com.decp.analytics.service;

import com.decp.analytics.cache.MetricsCache;
import com.decp.analytics.model.AnalyticsSnapshot;
import com.decp.analytics.model.MetricType;
import com.decp.analytics.repository.AnalyticsSnapshotRepository;
import com.decp.analytics.repository.PostMetricRepository;
import com.decp.analytics.repository.UserMetricRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
@Slf4j
public class MetricsAggregationService {

    private final AnalyticsSnapshotRepository snapshotRepository;
    private final UserMetricRepository userMetricRepository;
    private final PostMetricRepository postMetricRepository;
    private final MetricsCache metricsCache;

    /**
     * Runs daily at 2 AM to aggregate yesterday's metrics into daily snapshots.
     */
    @Scheduled(cron = "0 0 2 * * *")
    @Transactional
    public void aggregateDailyMetrics() {
        log.info("Starting daily metrics aggregation...");
        LocalDate yesterday = LocalDate.now().minusDays(1);

        aggregateUserMetrics(yesterday);
        aggregatePostMetrics(yesterday);
        aggregateJobMetrics(yesterday);
        aggregateEventMetrics(yesterday);
        aggregateResearchMetrics(yesterday);
        aggregateMessageMetrics(yesterday);

        // Reset daily Redis counters
        metricsCache.resetDailyCounters();

        log.info("Daily metrics aggregation completed for {}", yesterday);
    }

    /**
     * Clean up old raw data, keep only last 90 days of snapshots.
     */
    @Scheduled(cron = "0 30 2 * * *")
    @Transactional
    public void cleanupOldData() {
        log.info("Starting old data cleanup...");
        LocalDate cutoff = LocalDate.now().minusDays(90);
        var oldSnapshots = snapshotRepository.findOlderThan(cutoff);
        if (!oldSnapshots.isEmpty()) {
            snapshotRepository.deleteAll(oldSnapshots);
            log.info("Deleted {} old snapshots before {}", oldSnapshots.size(), cutoff);
        }
    }

    private void aggregateUserMetrics(LocalDate date) {
        try {
            Long totalUsers = userMetricRepository.count();
            Long newUsers = metricsCache.getCounter("users:new:today");
            Long activeToday = userMetricRepository.countByLastActiveAtAfter(
                    date.atStartOfDay());

            double engagement = calculateEngagementScore(activeToday, totalUsers);

            saveSnapshot(date, MetricType.USERS, totalUsers, newUsers, activeToday, engagement);

            // Update Redis total
            metricsCache.setCounter("users:total", totalUsers);
        } catch (Exception e) {
            log.error("Error aggregating user metrics: {}", e.getMessage(), e);
        }
    }

    private void aggregatePostMetrics(LocalDate date) {
        try {
            Long totalPosts = postMetricRepository.count();
            Long newPosts = metricsCache.getCounter("posts:new:today");

            Double avgLikes = postMetricRepository.findAverageLikes();
            Double avgComments = postMetricRepository.findAverageComments();
            double engagement = (avgLikes != null ? avgLikes : 0) + (avgComments != null ? avgComments : 0);

            saveSnapshot(date, MetricType.POSTS, totalPosts, newPosts, 0L, engagement);

            metricsCache.setCounter("posts:total", totalPosts);
        } catch (Exception e) {
            log.error("Error aggregating post metrics: {}", e.getMessage(), e);
        }
    }

    private void aggregateJobMetrics(LocalDate date) {
        try {
            Long totalJobs = metricsCache.getCounter("jobs:total");
            Long newJobs = metricsCache.getCounter("jobs:new:today");
            Long totalApps = metricsCache.getCounter("jobs:applications:total");

            saveSnapshot(date, MetricType.JOBS, totalJobs, newJobs, 0L,
                    totalJobs > 0 ? (double) totalApps / totalJobs : 0.0);
        } catch (Exception e) {
            log.error("Error aggregating job metrics: {}", e.getMessage(), e);
        }
    }

    private void aggregateEventMetrics(LocalDate date) {
        try {
            Long totalEvents = metricsCache.getCounter("events:total");
            Long newEvents = metricsCache.getCounter("events:new:today");
            Long totalRsvps = metricsCache.getCounter("events:rsvps:total");

            saveSnapshot(date, MetricType.EVENTS, totalEvents, newEvents, 0L,
                    totalEvents > 0 ? (double) totalRsvps / totalEvents : 0.0);
        } catch (Exception e) {
            log.error("Error aggregating event metrics: {}", e.getMessage(), e);
        }
    }

    private void aggregateResearchMetrics(LocalDate date) {
        try {
            Long total = metricsCache.getCounter("research:total");
            Long newResearch = metricsCache.getCounter("research:new:today");

            saveSnapshot(date, MetricType.RESEARCH, total, newResearch, 0L, 0.0);
        } catch (Exception e) {
            log.error("Error aggregating research metrics: {}", e.getMessage(), e);
        }
    }

    private void aggregateMessageMetrics(LocalDate date) {
        try {
            Long total = metricsCache.getCounter("messages:total");
            Long newMessages = metricsCache.getCounter("messages:today");

            saveSnapshot(date, MetricType.MESSAGES, total, newMessages, 0L, 0.0);
        } catch (Exception e) {
            log.error("Error aggregating message metrics: {}", e.getMessage(), e);
        }
    }

    private void saveSnapshot(LocalDate date, MetricType type, Long total, Long newCount,
                              Long activeCount, double engagementScore) {
        AnalyticsSnapshot snapshot = snapshotRepository
                .findByMetricTypeAndSnapshotDate(type, date)
                .orElse(AnalyticsSnapshot.builder()
                        .snapshotDate(date)
                        .metricType(type)
                        .build());

        snapshot.setTotalCount(total);
        snapshot.setNewCount(newCount);
        snapshot.setActiveCount(activeCount);
        snapshot.setEngagementScore(engagementScore);
        snapshot.setAverageEngagement(total > 0 ? engagementScore / total : 0.0);

        snapshotRepository.save(snapshot);
    }

    private double calculateEngagementScore(Long active, Long total) {
        if (total == null || total == 0) return 0.0;
        return (active != null ? active : 0) * 100.0 / total;
    }
}
