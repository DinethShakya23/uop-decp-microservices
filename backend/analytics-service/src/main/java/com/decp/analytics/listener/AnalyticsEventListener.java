package com.decp.analytics.listener;

import com.decp.analytics.cache.MetricsCache;
import com.decp.analytics.config.RabbitMQConfig;
import com.decp.analytics.model.PostMetric;
import com.decp.analytics.model.UserMetric;
import com.decp.analytics.repository.PostMetricRepository;
import com.decp.analytics.repository.UserMetricRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.Map;

@Component
@RequiredArgsConstructor
@Slf4j
public class AnalyticsEventListener {

    private final MetricsCache metricsCache;
    private final UserMetricRepository userMetricRepository;
    private final PostMetricRepository postMetricRepository;

    @RabbitListener(queues = RabbitMQConfig.ANALYTICS_USER_REGISTERED)
    public void onUserRegistered(Object message) {
        try {
            String userId = extractString(message);
            log.info("Analytics: user.registered for userId: {}", userId);

            metricsCache.incrementCounter("users:total");
            metricsCache.incrementCounter("users:new:today");

            // Create user metric entry
            try {
                Long uid = Long.parseLong(userId);
                if (userMetricRepository.findByUserId(uid).isEmpty()) {
                    UserMetric metric = UserMetric.builder()
                            .userId(uid)
                            .lastActiveAt(LocalDateTime.now())
                            .build();
                    userMetricRepository.save(metric);
                }
            } catch (NumberFormatException e) {
                log.warn("Could not parse userId: {}", userId);
            }
        } catch (Exception e) {
            log.error("Error processing user.registered: {}", e.getMessage(), e);
        }
    }

    @RabbitListener(queues = RabbitMQConfig.ANALYTICS_POST_CREATED)
    public void onPostCreated(Object message) {
        try {
            String postId = extractString(message);
            log.info("Analytics: post.created for postId: {}", postId);

            metricsCache.incrementCounter("posts:total");
            metricsCache.incrementCounter("posts:new:today");

            // Create post metric entry
            if (postMetricRepository.findByPostId(postId).isEmpty()) {
                PostMetric metric = PostMetric.builder()
                        .postId(postId)
                        .build();
                postMetricRepository.save(metric);
            }
        } catch (Exception e) {
            log.error("Error processing post.created: {}", e.getMessage(), e);
        }
    }

    @RabbitListener(queues = RabbitMQConfig.ANALYTICS_POST_LIKED)
    public void onPostLiked(Map<String, Object> message) {
        try {
            log.info("Analytics: post.liked: {}", message);
            String postId = getString(message, "postId");

            metricsCache.incrementCounter("posts:likes:today");

            if (postId != null) {
                postMetricRepository.findByPostId(postId).ifPresent(metric -> {
                    metric.setLikes(metric.getLikes() + 1);
                    postMetricRepository.save(metric);
                });
            }
        } catch (Exception e) {
            log.error("Error processing post.liked: {}", e.getMessage(), e);
        }
    }

    @RabbitListener(queues = RabbitMQConfig.ANALYTICS_POST_COMMENTED)
    public void onPostCommented(Map<String, Object> message) {
        try {
            log.info("Analytics: post.commented: {}", message);
            String postId = getString(message, "postId");

            metricsCache.incrementCounter("posts:comments:today");

            if (postId != null) {
                postMetricRepository.findByPostId(postId).ifPresent(metric -> {
                    metric.setComments(metric.getComments() + 1);
                    postMetricRepository.save(metric);
                });
            }
        } catch (Exception e) {
            log.error("Error processing post.commented: {}", e.getMessage(), e);
        }
    }

    @RabbitListener(queues = RabbitMQConfig.ANALYTICS_JOB_CREATED)
    public void onJobCreated(Map<String, Object> message) {
        try {
            log.info("Analytics: job.created: {}", message);

            metricsCache.incrementCounter("jobs:total");
            metricsCache.incrementCounter("jobs:new:today");

            String jobId = getString(message, "jobId");
            String title = getString(message, "title");
            if (jobId != null && title != null) {
                metricsCache.trackJobCreated(jobId, title);
            }
        } catch (Exception e) {
            log.error("Error processing job.created: {}", e.getMessage(), e);
        }
    }

    @RabbitListener(queues = RabbitMQConfig.ANALYTICS_JOB_APPLIED)
    public void onJobApplied(Map<String, Object> message) {
        try {
            log.info("Analytics: job.applied: {}", message);

            metricsCache.incrementCounter("jobs:applications:total");
            metricsCache.incrementCounter("jobs:applications:today");

            String jobId = getString(message, "jobId");
            if (jobId != null) {
                metricsCache.incrementJobApplications(jobId);
            }
        } catch (Exception e) {
            log.error("Error processing job.applied: {}", e.getMessage(), e);
        }
    }

    @RabbitListener(queues = RabbitMQConfig.ANALYTICS_EVENT_CREATED)
    public void onEventCreated(Map<String, Object> message) {
        try {
            log.info("Analytics: event.created: {}", message);

            metricsCache.incrementCounter("events:total");
            metricsCache.incrementCounter("events:new:today");

            String eventId = getString(message, "eventId");
            String title = getString(message, "title");
            if (eventId != null && title != null) {
                metricsCache.trackEventCreated(eventId, title);
            }
        } catch (Exception e) {
            log.error("Error processing event.created: {}", e.getMessage(), e);
        }
    }

    @RabbitListener(queues = RabbitMQConfig.ANALYTICS_EVENT_RSVP)
    public void onEventRsvp(Map<String, Object> message) {
        try {
            log.info("Analytics: event.rsvp: {}", message);

            metricsCache.incrementCounter("events:rsvps:total");
            metricsCache.incrementCounter("events:rsvps:today");

            String eventId = getString(message, "eventId");
            if (eventId != null) {
                metricsCache.incrementEventRsvps(eventId);
            }
        } catch (Exception e) {
            log.error("Error processing event.rsvp: {}", e.getMessage(), e);
        }
    }

    @RabbitListener(queues = RabbitMQConfig.ANALYTICS_RESEARCH_UPLOADED)
    public void onResearchUploaded(Map<String, Object> message) {
        try {
            log.info("Analytics: research.uploaded: {}", message);

            metricsCache.incrementCounter("research:total");
            metricsCache.incrementCounter("research:new:today");
        } catch (Exception e) {
            log.error("Error processing research.uploaded: {}", e.getMessage(), e);
        }
    }

    @RabbitListener(queues = RabbitMQConfig.ANALYTICS_RESEARCH_CITED)
    public void onResearchCited(Map<String, Object> message) {
        try {
            log.info("Analytics: research.cited: {}", message);
            metricsCache.incrementCounter("research:citations:today");
        } catch (Exception e) {
            log.error("Error processing research.cited: {}", e.getMessage(), e);
        }
    }

    private String extractString(Object message) {
        if (message instanceof String s) {
            return s;
        }
        if (message instanceof Number n) {
            return n.toString();
        }
        if (message instanceof byte[] bytes) {
            return new String(bytes);
        }
        return String.valueOf(message);
    }

    private String getString(Map<String, Object> map, String key) {
        Object val = map.get(key);
        return val != null ? val.toString() : null;
    }
}
