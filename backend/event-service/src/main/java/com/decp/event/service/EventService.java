package com.decp.event.service;

import com.decp.event.config.EventPublisher;
import com.decp.event.dto.EventRequest;
import com.decp.event.dto.EventResponse;
import com.decp.event.dto.RsvpRequest;
import com.decp.event.dto.RsvpResponse;
import com.decp.event.model.Event;
import com.decp.event.model.Rsvp;
import com.decp.event.model.RsvpStatus;
import com.decp.event.repository.EventRepository;
import com.decp.event.repository.RsvpRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;

@Service
@RequiredArgsConstructor
public class EventService {

    private final EventRepository eventRepository;
    private final RsvpRepository rsvpRepository;
    private final EventPublisher eventPublisher;

    public EventResponse createEvent(EventRequest request, String userName) {
        Event event = Event.builder()
                .title(request.getTitle())
                .description(request.getDescription())
                .location(request.getLocation())
                .eventDate(request.getEventDate())
                .startTime(request.getStartTime())
                .endTime(request.getEndTime())
                .organizerName(userName)
                .category(request.getCategory())
                .maxAttendees(request.getMaxAttendees())
                .build();

        Event saved = eventRepository.save(event);

        eventPublisher.publishEventCreated(saved.getId(), saved.getTitle(), saved.getOrganizerName());

        return toEventResponse(saved);
    }

    public List<EventResponse> getAllEvents() {
        return eventRepository.findAllByOrderByEventDateAsc()
                .stream()
                .map(this::toEventResponse)
                .toList();
    }

    public EventResponse getEventById(Long id) {
        Event event = eventRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Event not found with id: " + id));
        return toEventResponse(event);
    }

    public EventResponse updateEvent(Long id, EventRequest request, String userName) {
        Event event = eventRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Event not found with id: " + id));

        if (!userName.equals(event.getOrganizerName())) {
            throw new RuntimeException("Only the event creator can update this event");
        }

        event.setTitle(request.getTitle());
        event.setDescription(request.getDescription());
        event.setLocation(request.getLocation());
        event.setEventDate(request.getEventDate());
        event.setStartTime(request.getStartTime());
        event.setEndTime(request.getEndTime());
        event.setCategory(request.getCategory());
        event.setMaxAttendees(request.getMaxAttendees());

        Event updated = eventRepository.save(event);
        return toEventResponse(updated);
    }

    public void deleteEvent(Long id, String userName, String userRole) {
        Event event = eventRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Event not found with id: " + id));

        if (!"ADMIN".equals(userRole) && !userName.equals(event.getOrganizerName())) {
            throw new RuntimeException("Only the event creator or an admin can delete this event");
        }

        eventRepository.delete(event);
    }

    public RsvpResponse rsvpToEvent(Long eventId, RsvpRequest request, String userName) {
        Event event = eventRepository.findById(eventId)
                .orElseThrow(() -> new RuntimeException("Event not found with id: " + eventId));

        if (event.getMaxAttendees() != null && request.getStatus() == RsvpStatus.GOING) {
            long goingCount = rsvpRepository.countByEventIdAndStatus(eventId, RsvpStatus.GOING);
            if (goingCount >= event.getMaxAttendees()) {
                throw new RuntimeException("Event has reached maximum capacity");
            }
        }

        // Check for existing RSVP by this user (matched by userName since userId isn't in gateway headers)
        Rsvp existingRsvp = findRsvpByEventAndUserName(eventId, userName);
        Rsvp saved;
        if (existingRsvp != null) {
            existingRsvp.setStatus(request.getStatus());
            saved = rsvpRepository.save(existingRsvp);
        } else {
            Rsvp rsvp = Rsvp.builder()
                    .eventId(eventId)
                    .userName(userName)
                    .status(request.getStatus())
                    .build();
            saved = rsvpRepository.save(rsvp);
        }

        eventPublisher.publishEventRsvp(eventId, saved.getUserId(), userName, request.getStatus().name());

        return toRsvpResponse(saved);
    }

    private Rsvp findRsvpByEventAndUserName(Long eventId, String userName) {
        return rsvpRepository.findAllByEventId(eventId).stream()
                .filter(r -> userName.equals(r.getUserName()))
                .findFirst()
                .orElse(null);
    }

    public List<RsvpResponse> getAttendees(Long eventId) {
        eventRepository.findById(eventId)
                .orElseThrow(() -> new RuntimeException("Event not found with id: " + eventId));

        return rsvpRepository.findAllByEventId(eventId)
                .stream()
                .map(this::toRsvpResponse)
                .toList();
    }

    public List<EventResponse> getUpcomingEvents() {
        return eventRepository.findByEventDateGreaterThanEqualOrderByEventDateAsc(LocalDate.now())
                .stream()
                .map(this::toEventResponse)
                .toList();
    }

    private EventResponse toEventResponse(Event event) {
        long attendeeCount = rsvpRepository.countByEventIdAndStatus(event.getId(), RsvpStatus.GOING);
        return EventResponse.builder()
                .id(event.getId())
                .title(event.getTitle())
                .description(event.getDescription())
                .location(event.getLocation())
                .eventDate(event.getEventDate())
                .startTime(event.getStartTime())
                .endTime(event.getEndTime())
                .organizer(event.getOrganizer())
                .organizerName(event.getOrganizerName())
                .category(event.getCategory())
                .maxAttendees(event.getMaxAttendees())
                .createdAt(event.getCreatedAt())
                .attendeeCount(attendeeCount)
                .build();
    }

    private RsvpResponse toRsvpResponse(Rsvp rsvp) {
        return RsvpResponse.builder()
                .id(rsvp.getId())
                .eventId(rsvp.getEventId())
                .userId(rsvp.getUserId())
                .userName(rsvp.getUserName())
                .status(rsvp.getStatus())
                .respondedAt(rsvp.getRespondedAt())
                .build();
    }
}
