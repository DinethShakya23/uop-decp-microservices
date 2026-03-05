package com.decp.analytics.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PostSummaryDTO {
    private String postId;
    private Long likes;
    private Long comments;
    private Long views;
    private Long totalEngagement;
}
