package com.decp.event.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "rsvps", uniqueConstraints = {
    @UniqueConstraint(columnNames = {"eventId", "userId"})
})
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Rsvp {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long eventId;

    @Column(nullable = false)
    private Long userId;

    private String userName;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private RsvpStatus status;

    private LocalDateTime respondedAt;

    @PrePersist
    protected void onCreate() {
        respondedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        respondedAt = LocalDateTime.now();
    }
}
