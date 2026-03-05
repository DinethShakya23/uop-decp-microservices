package com.decp.analytics.service;

import com.decp.analytics.cache.MetricsCache;
import com.decp.analytics.dto.*;
import com.decp.analytics.model.*;
import com.decp.analytics.repository.AnalyticsSnapshotRepository;
import com.decp.analytics.repository.PostMetricRepository;
import com.decp.analytics.repository.UserMetricRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AnalyticsService {

    private final AnalyticsSnapshotRepository snapshotRepository;
    private final UserMetricRepository userMetricRepository;
    private final PostMetricRepository postMetricRepository;
    private final MetricsCache metricsCache;

    public AnalyticsOverviewResponse getOverview() {
        Long totalUsers = fallbackToDb(metricsCache.getCounter("users:total"), MetricType.USERS);
        Long totalPosts = fallbackToDb(metricsCache.getCounter("posts:total"), MetricType.POSTS);
        Long totalJobs = fallbackToDb(metricsCache.getCounter("jobs:total"), MetricType.JOBS);
        Long totalEvents = fallbackToDb(metricsCache.getCounter("events:total"), MetricType.EVENTS);
        Long totalResearch = fallbackToDb(metricsCache.getCounter("research:total"), MetricType.RESEARCH);

        LocalDateTime now = LocalDateTime.now();
        Long activeToday = userMetricRepository.countByLastActiveAtAfter(now.toLocalDate().atStartOfDay());
        Long activeThisWeek = userMetricRepository.countByLastActiveAtAfter(now.minusDays(7));
        Long activeThisMonth = userMetricRepository.countByLastActiveAtAfter(now.minusDays(30));

        // Engagement trend: last 7 days from snapshots
        LocalDate today = LocalDate.now();
        List<AnalyticsSnapshot> weekSnapshots = snapshotRepository
                .findBySnapshotDateBetweenOrderBySnapshotDateAsc(today.minusDays(7), today);

        List<Double> engagementTrend = new ArrayList<>();
        for (int i = 6; i >= 0; i--) {
            LocalDate day = today.minusDays(i);
            double avg = weekSnapshots.stream()
                    .filter(s -> s.getSnapshotDate().equals(day))
                    .mapToDouble(AnalyticsSnapshot::getEngagementScore)
                    .average()
                    .orElse(0.0);
            engagementTrend.add(avg);
        }

        // Top posts this week
        List<PostSummaryDTO> topPosts = postMetricRepository.findTopPostsByEngagement().stream()
                .limit(5)
                .map(p -> PostSummaryDTO.builder()
                        .postId(p.getPostId())
                        .likes(p.getLikes())
                        .comments(p.getComments())
                        .views(p.getViews())
                        .totalEngagement(p.getLikes() + p.getComments() + p.getViews())
                        .build())
                .toList();

        // Top events from Redis leaderboard
        List<EventSummaryDTO> topEvents = metricsCache.getTopEvents(5).stream()
                .map(m -> EventSummaryDTO.builder()
                        .eventId((String) m.get("eventId"))
                        .title((String) m.get("title"))
                        .rsvpCount((Long) m.get("rsvpCount"))
                        .build())
                .toList();

        return AnalyticsOverviewResponse.builder()
                .totalUsers(totalUsers)
                .totalPosts(totalPosts)
                .totalJobs(totalJobs)
                .totalEvents(totalEvents)
                .totalResearch(totalResearch)
                .activeUsersToday(activeToday)
                .activeUsersThisWeek(activeThisWeek)
                .activeUsersThisMonth(activeThisMonth)
                .engagementTrendLastWeek(engagementTrend)
                .topPostsThisWeek(topPosts)
                .topEventsThisWeek(topEvents)
                .build();
    }

    public UserMetricsResponse getUserMetrics() {
        Long total = userMetricRepository.count();
        LocalDateTime now = LocalDateTime.now();
        Long thisMonth = userMetricRepository.countByCreatedAtAfter(now.minusDays(30));
        Long students = userMetricRepository.countByRole(UserRole.STUDENT);
        Long alumni = userMetricRepository.countByRole(UserRole.ALUMNI);
        Long admins = userMetricRepository.countByRole(UserRole.ADMIN);
        Long newThisWeek = userMetricRepository.countByCreatedAtAfter(now.minusDays(7));

        List<UserSummaryDTO> mostActive = userMetricRepository.findMostActiveUsers().stream()
                .map(u -> UserSummaryDTO.builder()
                        .userId(u.getUserId())
                        .userName(u.getUserName())
                        .role(u.getRole() != null ? u.getRole().name() : null)
                        .totalActivity(u.getPostsCreated() + u.getEventsAttended() +
                                u.getJobsApplied() + u.getResearchUploaded() + u.getMessagesCount())
                        .build())
                .toList();

        // Retention rate: % of users active this week who were also active last week
        Long activeThisWeek = userMetricRepository.countByLastActiveAtAfter(now.minusDays(7));
        Long returning = userMetricRepository.countReturningUsersSince(now.minusDays(7));
        Double retention = activeThisWeek > 0 ? (returning * 100.0) / activeThisWeek : 0.0;

        return UserMetricsResponse.builder()
                .totalUsers(total)
                .usersThisMonth(thisMonth)
                .studentCount(students)
                .alumniCount(alumni)
                .adminCount(admins)
                .mostActiveUsers(mostActive)
                .newUsersThisWeek(newThisWeek)
                .userRetentionRate(Math.round(retention * 100.0) / 100.0)
                .build();
    }

    public PostMetricsResponse getPostMetrics() {
        Long total = postMetricRepository.count();
        Long thisMonth = postMetricRepository.countByCreatedAtAfter(LocalDateTime.now().minusDays(30));

        Double avgLikes = postMetricRepository.findAverageLikes();
        Double avgComments = postMetricRepository.findAverageComments();
        Double avgViews = postMetricRepository.findAverageViews();

        List<PostSummaryDTO> topPosts = postMetricRepository.findTopPostsByEngagement().stream()
                .map(p -> PostSummaryDTO.builder()
                        .postId(p.getPostId())
                        .likes(p.getLikes())
                        .comments(p.getComments())
                        .views(p.getViews())
                        .totalEngagement(p.getLikes() + p.getComments() + p.getViews())
                        .build())
                .toList();

        // Engagement trend from snapshots
        LocalDate today = LocalDate.now();
        List<AnalyticsSnapshot> snapshots = snapshotRepository
                .findByMetricTypeAndSnapshotDateBetweenOrderBySnapshotDateAsc(
                        MetricType.POSTS, today.minusDays(30), today);

        Map<LocalDate, Double> trend = snapshots.stream()
                .collect(Collectors.toMap(
                        AnalyticsSnapshot::getSnapshotDate,
                        AnalyticsSnapshot::getEngagementScore,
                        (a, b) -> b,
                        LinkedHashMap::new));

        return PostMetricsResponse.builder()
                .totalPosts(total)
                .postsThisMonth(thisMonth)
                .averageLikesPerPost(Math.round(avgLikes * 100.0) / 100.0)
                .averageCommentsPerPost(Math.round(avgComments * 100.0) / 100.0)
                .averageViewsPerPost(Math.round(avgViews * 100.0) / 100.0)
                .topPostsAllTime(topPosts)
                .engagementTrend(trend)
                .build();
    }

    public JobMetricsResponse getJobMetrics() {
        Long totalJobs = metricsCache.getCounter("jobs:total");
        Long openJobs = metricsCache.getCounter("jobs:open");
        Long jobsThisMonth = metricsCache.getCounter("jobs:new:today"); // simplified
        Long totalApps = metricsCache.getCounter("jobs:applications:total");
        Long appsThisMonth = metricsCache.getCounter("jobs:applications:today"); // simplified

        Double avgApps = totalJobs > 0 ? (double) totalApps / totalJobs : 0.0;

        List<JobSummaryDTO> topJobs = metricsCache.getTopJobs(10).stream()
                .map(m -> JobSummaryDTO.builder()
                        .jobId((String) m.get("jobId"))
                        .title((String) m.get("title"))
                        .applications((Long) m.get("applications"))
                        .build())
                .toList();

        // Application trend from snapshots
        LocalDate today = LocalDate.now();
        List<AnalyticsSnapshot> snapshots = snapshotRepository
                .findByMetricTypeAndSnapshotDateBetweenOrderBySnapshotDateAsc(
                        MetricType.JOBS, today.minusDays(30), today);

        Map<LocalDate, Long> trend = snapshots.stream()
                .collect(Collectors.toMap(
                        AnalyticsSnapshot::getSnapshotDate,
                        AnalyticsSnapshot::getNewCount,
                        (a, b) -> b,
                        LinkedHashMap::new));

        return JobMetricsResponse.builder()
                .totalJobs(totalJobs)
                .openJobs(openJobs)
                .jobsThisMonth(jobsThisMonth)
                .totalApplications(totalApps)
                .applicationsThisMonth(appsThisMonth)
                .averageApplicationsPerJob(Math.round(avgApps * 100.0) / 100.0)
                .topJobsByApplications(topJobs)
                .applicationTrendLastMonth(trend)
                .build();
    }

    public EventMetricsResponse getEventMetrics() {
        Long totalEvents = metricsCache.getCounter("events:total");
        Long eventsThisMonth = metricsCache.getCounter("events:new:today");
        Long totalRsvps = metricsCache.getCounter("events:rsvps:total");
        Long rsvpsThisMonth = metricsCache.getCounter("events:rsvps:today");

        Double avgRsvps = totalEvents > 0 ? (double) totalRsvps / totalEvents : 0.0;

        List<EventSummaryDTO> topEvents = metricsCache.getTopEvents(10).stream()
                .map(m -> EventSummaryDTO.builder()
                        .eventId((String) m.get("eventId"))
                        .title((String) m.get("title"))
                        .rsvpCount((Long) m.get("rsvpCount"))
                        .build())
                .toList();

        LocalDate today = LocalDate.now();
        List<AnalyticsSnapshot> snapshots = snapshotRepository
                .findByMetricTypeAndSnapshotDateBetweenOrderBySnapshotDateAsc(
                        MetricType.EVENTS, today.minusDays(30), today);

        Map<LocalDate, Long> trend = snapshots.stream()
                .collect(Collectors.toMap(
                        AnalyticsSnapshot::getSnapshotDate,
                        AnalyticsSnapshot::getNewCount,
                        (a, b) -> b,
                        LinkedHashMap::new));

        return EventMetricsResponse.builder()
                .totalEvents(totalEvents)
                .eventsThisMonth(eventsThisMonth)
                .totalRsvps(totalRsvps)
                .rsvpsThisMonth(rsvpsThisMonth)
                .averageRsvpsPerEvent(Math.round(avgRsvps * 100.0) / 100.0)
                .topEventsByRsvps(topEvents)
                .eventTrendLastMonth(trend)
                .build();
    }

    public ResearchMetricsResponse getResearchMetrics() {
        Long total = metricsCache.getCounter("research:total");
        Long thisMonth = metricsCache.getCounter("research:new:today");
        Long totalDownloads = metricsCache.getCounter("research:downloads:total");
        Long totalCitations = metricsCache.getCounter("research:citations:today");

        Double avgViews = total > 0 ? (double) metricsCache.getCounter("research:views:total") / total : 0.0;

        LocalDate today = LocalDate.now();
        List<AnalyticsSnapshot> snapshots = snapshotRepository
                .findByMetricTypeAndSnapshotDateBetweenOrderBySnapshotDateAsc(
                        MetricType.RESEARCH, today.minusDays(30), today);

        Map<LocalDate, Long> trend = snapshots.stream()
                .collect(Collectors.toMap(
                        AnalyticsSnapshot::getSnapshotDate,
                        AnalyticsSnapshot::getNewCount,
                        (a, b) -> b,
                        LinkedHashMap::new));

        return ResearchMetricsResponse.builder()
                .totalResearch(total)
                .researchThisMonth(thisMonth)
                .totalDownloads(totalDownloads)
                .totalCitations(totalCitations)
                .averageViewsPerPaper(Math.round(avgViews * 100.0) / 100.0)
                .uploadTrendLastMonth(trend)
                .build();
    }

    public MessageMetricsResponse getMessageMetrics() {
        Long totalMessages = metricsCache.getCounter("messages:total");
        Long thisMonth = metricsCache.getCounter("messages:month");
        Long thisWeek = metricsCache.getCounter("messages:week");
        Long today = metricsCache.getCounter("messages:today");
        Long activeConversations = metricsCache.getCounter("messages:conversations:active");

        LocalDate todayDate = LocalDate.now();
        List<AnalyticsSnapshot> snapshots = snapshotRepository
                .findByMetricTypeAndSnapshotDateBetweenOrderBySnapshotDateAsc(
                        MetricType.MESSAGES, todayDate.minusDays(30), todayDate);

        Map<LocalDate, Long> trend = snapshots.stream()
                .collect(Collectors.toMap(
                        AnalyticsSnapshot::getSnapshotDate,
                        AnalyticsSnapshot::getNewCount,
                        (a, b) -> b,
                        LinkedHashMap::new));

        return MessageMetricsResponse.builder()
                .totalMessages(totalMessages)
                .messagesThisMonth(thisMonth)
                .messagesThisWeek(thisWeek)
                .messagesToday(today)
                .activeConversations(activeConversations)
                .messageTrendLastMonth(trend)
                .build();
    }

    public List<TimelineEntry> getTimelineMetrics(LocalDate from, LocalDate to) {
        List<AnalyticsSnapshot> snapshots = snapshotRepository
                .findBySnapshotDateBetweenOrderBySnapshotDateAsc(from, to);

        return snapshots.stream()
                .map(s -> TimelineEntry.builder()
                        .date(s.getSnapshotDate())
                        .metricType(s.getMetricType())
                        .totalCount(s.getTotalCount())
                        .newCount(s.getNewCount())
                        .engagementScore(s.getEngagementScore())
                        .build())
                .toList();
    }

    public String exportMetricsAsCsv(String type) {
        StringWriter sw = new StringWriter();
        PrintWriter pw = new PrintWriter(sw);

        if ("users".equalsIgnoreCase(type)) {
            pw.println("userId,userName,role,postsCreated,eventsAttended,jobsApplied,researchUploaded,messagesCount,lastActiveAt,loginCount");
            userMetricRepository.findAll().forEach(u ->
                    pw.printf("%d,%s,%s,%d,%d,%d,%d,%d,%s,%d%n",
                            u.getUserId(),
                            escapeCsv(u.getUserName()),
                            u.getRole(),
                            u.getPostsCreated(),
                            u.getEventsAttended(),
                            u.getJobsApplied(),
                            u.getResearchUploaded(),
                            u.getMessagesCount(),
                            u.getLastActiveAt(),
                            u.getLoginCount()));
        } else if ("posts".equalsIgnoreCase(type)) {
            pw.println("postId,createdByUserId,likes,comments,shares,views,createdAt");
            postMetricRepository.findAll().forEach(p ->
                    pw.printf("%s,%s,%d,%d,%d,%d,%s%n",
                            escapeCsv(p.getPostId()),
                            p.getCreatedByUserId(),
                            p.getLikes(),
                            p.getComments(),
                            p.getShares(),
                            p.getViews(),
                            p.getCreatedAt()));
        } else {
            // Default: snapshots
            pw.println("date,metricType,totalCount,newCount,activeCount,engagementScore,averageEngagement");
            snapshotRepository.findAll().forEach(s ->
                    pw.printf("%s,%s,%d,%d,%d,%.2f,%.2f%n",
                            s.getSnapshotDate(),
                            s.getMetricType(),
                            s.getTotalCount(),
                            s.getNewCount(),
                            s.getActiveCount(),
                            s.getEngagementScore(),
                            s.getAverageEngagement()));
        }

        pw.flush();
        return sw.toString();
    }

    private Long fallbackToDb(Long redisValue, MetricType type) {
        if (redisValue != null && redisValue > 0) return redisValue;
        return snapshotRepository.findLatestByMetricType(type)
                .map(AnalyticsSnapshot::getTotalCount)
                .orElse(0L);
    }

    private String escapeCsv(String value) {
        if (value == null) return "";
        if (value.contains(",") || value.contains("\"") || value.contains("\n")) {
            return "\"" + value.replace("\"", "\"\"") + "\"";
        }
        return value;
    }
}
