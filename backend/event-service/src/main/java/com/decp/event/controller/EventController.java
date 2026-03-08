package com.decp.event.controller;

import com.decp.event.dto.EventRequest;
import com.decp.event.dto.EventResponse;
import com.decp.event.dto.RsvpRequest;
import com.decp.event.dto.RsvpResponse;
import com.decp.event.service.EventService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/events")
@RequiredArgsConstructor
public class EventController {

    private final EventService eventService;

    @PostMapping
    public ResponseEntity<EventResponse> createEvent(
            @RequestHeader("X-User-Name") String userName,
            @RequestHeader("X-User-Role") String userRole,
            @RequestHeader("X-User-Id") Long userId,
            @Valid @RequestBody EventRequest request) {
        if (!"ALUMNI".equals(userRole) && !"ADMIN".equals(userRole)) {
            return ResponseEntity.status(403).build();
        }
        return ResponseEntity.ok(eventService.createEvent(request, userId, userName));
    }

    @GetMapping
    public ResponseEntity<List<EventResponse>> getAllEvents() {
        return ResponseEntity.ok(eventService.getAllEvents());
    }

    @GetMapping("/upcoming")
    public ResponseEntity<List<EventResponse>> getUpcomingEvents() {
        return ResponseEntity.ok(eventService.getUpcomingEvents());
    }

    @GetMapping("/{id}")
    public ResponseEntity<EventResponse> getEventById(@PathVariable Long id) {
        return ResponseEntity.ok(eventService.getEventById(id));
    }

    @PutMapping("/{id}")
    public ResponseEntity<EventResponse> updateEvent(
            @PathVariable Long id,
            @RequestHeader("X-User-Name") String userName,
            @Valid @RequestBody EventRequest request) {
        return ResponseEntity.ok(eventService.updateEvent(id, request, userName));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteEvent(
            @PathVariable Long id,
            @RequestHeader("X-User-Name") String userName,
            @RequestHeader("X-User-Role") String userRole) {
        eventService.deleteEvent(id, userName, userRole);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/rsvp")
    public ResponseEntity<RsvpResponse> rsvpToEvent(
            @PathVariable Long id,
            @RequestHeader("X-User-Name") String userName,
            @RequestHeader("X-User-Id") Long userId,
            @Valid @RequestBody RsvpRequest request) {
        return ResponseEntity.ok(eventService.rsvpToEvent(id, request, userId, userName));
    }

    @GetMapping("/{id}/attendees")
    public ResponseEntity<List<RsvpResponse>> getAttendees(@PathVariable Long id) {
        return ResponseEntity.ok(eventService.getAttendees(id));
    }
}
