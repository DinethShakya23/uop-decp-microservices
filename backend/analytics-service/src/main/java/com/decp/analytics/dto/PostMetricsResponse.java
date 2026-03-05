package com.decp.analytics.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PostMetricsResponse {
    private Long totalPosts;
    private Long postsThisMonth;
    private Double averageLikesPerPost;
    private Double averageCommentsPerPost;
    private Double averageViewsPerPost;
    private List<PostSummaryDTO> topPostsAllTime;
    private Map<LocalDate, Double> engagementTrend;
}
