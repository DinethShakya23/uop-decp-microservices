package com.decp.feed_service.dto;

import lombok.Data;

@Data
public class PostRequest {
    private Long authorId;
    private String authorName;
    private String content;
}