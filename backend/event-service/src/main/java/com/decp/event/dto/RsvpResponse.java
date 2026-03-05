package com.decp.event.dto;

import com.decp.event.model.RsvpStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RsvpResponse {

    private Long id;
    private Long eventId;
    private Long userId;
    private String userName;
    private RsvpStatus status;
    private LocalDateTime respondedAt;
}
