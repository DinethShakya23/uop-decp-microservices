package com.decp.messaging.dto;

import jakarta.validation.constraints.NotEmpty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ConversationRequest {

    @NotEmpty(message = "Participants list is required")
    private List<Long> participantIds;

    private List<String> participantNames;

    private String initialMessage;
}
