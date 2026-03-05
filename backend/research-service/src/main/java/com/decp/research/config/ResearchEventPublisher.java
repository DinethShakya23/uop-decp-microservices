package com.decp.research.config;

import lombok.RequiredArgsConstructor;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.stereotype.Component;

import java.util.Map;

@Component
@RequiredArgsConstructor
public class ResearchEventPublisher {

    private final RabbitTemplate rabbitTemplate;

    public void publishResearchUploaded(Long researchId, String title, String authorName) {
        Map<String, Object> message = Map.of(
                "researchId", researchId,
                "title", title,
                "authorName", authorName
        );
        rabbitTemplate.convertAndSend(RabbitMQConfig.EXCHANGE_NAME, "research.uploaded", message);
    }

    public void publishResearchCited(Long researchId, String title) {
        Map<String, Object> message = Map.of(
                "researchId", researchId,
                "title", title
        );
        rabbitTemplate.convertAndSend(RabbitMQConfig.EXCHANGE_NAME, "research.cited", message);
    }
}
