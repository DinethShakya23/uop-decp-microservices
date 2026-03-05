package com.decp.event.dto;

import com.decp.event.model.RsvpStatus;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class RsvpRequest {

    @NotNull(message = "RSVP status is required")
    private RsvpStatus status;
}
