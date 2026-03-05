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
public class MessageMetricsResponse {
    private Long totalMessages;
    private Long messagesThisMonth;
    private Long messagesThisWeek;
    private Long messagesToday;
    private Long activeConversations;
    private Map<LocalDate, Long> messageTrendLastMonth;
}
