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
public class UserMetricsResponse {
    private Long totalUsers;
    private Long usersThisMonth;
    private Long studentCount;
    private Long alumniCount;
    private Long adminCount;
    private List<UserSummaryDTO> mostActiveUsers;
    private Long newUsersThisWeek;
    private Double userRetentionRate;
}
