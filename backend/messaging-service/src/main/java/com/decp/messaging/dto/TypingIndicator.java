package com.decp.messaging.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class TypingIndicator {

    private String conversationId;
    private Long userId;
    private String userName;
    private boolean typing;
}
