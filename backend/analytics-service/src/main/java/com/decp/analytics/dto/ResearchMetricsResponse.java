package com.decp.analytics.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.util.Map;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ResearchMetricsResponse {
    private Long totalResearch;
    private Long researchThisMonth;
    private Long totalDownloads;
    private Long totalCitations;
    private Double averageViewsPerPaper;
    private Map<LocalDate, Long> uploadTrendLastMonth;
}
