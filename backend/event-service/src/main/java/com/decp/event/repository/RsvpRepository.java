package com.decp.event.repository;

import com.decp.event.model.Rsvp;
import com.decp.event.model.RsvpStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface RsvpRepository extends JpaRepository<Rsvp, Long> {

    List<Rsvp> findAllByEventId(Long eventId);

    Optional<Rsvp> findByEventIdAndUserId(Long eventId, Long userId);

    long countByEventIdAndStatus(Long eventId, RsvpStatus status);
}
