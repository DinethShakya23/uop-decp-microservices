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
public class EventMetricsResponse {
    private Long totalEvents;
    private Long eventsThisMonth;
    private Long totalRsvps;
    private Long rsvpsThisMonth;
    private Double averageRsvpsPerEvent;
    private List<EventSummaryDTO> topEventsByRsvps;
    private Map<LocalDate, Long> eventTrendLastMonth;
}
