package com.decp.event.dto;

import com.decp.event.model.EventCategory;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class EventRequest {

    @NotBlank(message = "Title is required")
    private String title;

    private String description;

    private String location;

    @NotNull(message = "Event date is required")
    private LocalDate eventDate;

    private LocalTime startTime;

    private LocalTime endTime;

    @NotNull(message = "Category is required")
    private EventCategory category;

    private Integer maxAttendees;
}
