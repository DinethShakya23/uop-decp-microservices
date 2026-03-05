package com.decp.event.dto;

import com.decp.event.model.EventCategory;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class EventResponse {

    private Long id;
    private String title;
    private String description;
    private String location;
    private LocalDate eventDate;
    private LocalTime startTime;
    private LocalTime endTime;
    private Long organizer;
    private String organizerName;
    private EventCategory category;
    private Integer maxAttendees;
    private LocalDateTime createdAt;
    private long attendeeCount;
}
