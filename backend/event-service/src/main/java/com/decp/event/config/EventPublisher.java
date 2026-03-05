package com.decp.event.config;

import lombok.RequiredArgsConstructor;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.stereotype.Component;

import java.util.Map;

@Component
@RequiredArgsConstructor
public class EventPublisher {

    private final RabbitTemplate rabbitTemplate;

    public void publishEventCreated(Long eventId, String title, String organizerName) {
        Map<String, Object> message = Map.of(
                "eventId", eventId,
                "title", title,
                "organizerName", organizerName
        );
        rabbitTemplate.convertAndSend(RabbitMQConfig.EXCHANGE_NAME, "event.created", message);
    }

    public void publishEventRsvp(Long eventId, Long userId, String userName, String status) {
        Map<String, Object> message = Map.of(
                "eventId", eventId,
                "userId", userId,
                "userName", userName,
                "status", status
        );
        rabbitTemplate.convertAndSend(RabbitMQConfig.EXCHANGE_NAME, "event.rsvp", message);
    }
}
