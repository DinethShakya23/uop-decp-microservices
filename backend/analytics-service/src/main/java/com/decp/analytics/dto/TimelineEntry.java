package com.decp.analytics.dto;

import com.decp.analytics.model.MetricType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TimelineEntry {
    private LocalDate date;
    private MetricType metricType;
    private Long totalCount;
    private Long newCount;
    private Double engagementScore;
}
