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
public class JobMetricsResponse {
    private Long totalJobs;
    private Long openJobs;
    private Long jobsThisMonth;
    private Long totalApplications;
    private Long applicationsThisMonth;
    private Double averageApplicationsPerJob;
    private List<JobSummaryDTO> topJobsByApplications;
    private Map<LocalDate, Long> applicationTrendLastMonth;
}
