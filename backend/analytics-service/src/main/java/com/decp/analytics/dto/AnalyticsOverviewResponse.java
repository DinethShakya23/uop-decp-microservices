package com.decp.analytics.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AnalyticsOverviewResponse {
    private Long totalUsers;
    private Long totalPosts;
    private Long totalJobs;
    private Long totalEvents;
    private Long totalResearch;
    private Long activeUsersToday;
    private Long activeUsersThisWeek;
    private Long activeUsersThisMonth;
    private List<Double> engagementTrendLastWeek;
    private List<PostSummaryDTO> topPostsThisWeek;
    private List<EventSummaryDTO> topEventsThisWeek;
}
