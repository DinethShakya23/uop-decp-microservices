package com.decp.analytics.cache;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Component;

import java.time.Duration;
import java.util.*;
import java.util.stream.Collectors;

@Component
@RequiredArgsConstructor
@Slf4j
public class MetricsCache {

    private final StringRedisTemplate redisTemplate;

    private static final String PREFIX = "analytics:";
    private static final String LEADERBOARD_JOBS = PREFIX + "leaderboard:jobs";
    private static final String LEADERBOARD_EVENTS = PREFIX + "leaderboard:events";
    private static final String JOB_TITLES = PREFIX + "job:titles";
    private static final String EVENT_TITLES = PREFIX + "event:titles";

    // --- Counters ---

    public void incrementCounter(String key) {
        try {
            redisTemplate.opsForValue().increment(PREFIX + key);
        } catch (Exception e) {
            log.warn("Redis increment failed for key {}: {}", key, e.getMessage());
        }
    }

    public Long getCounter(String key) {
        try {
            String val = redisTemplate.opsForValue().get(PREFIX + key);
            return val != null ? Long.parseLong(val) : 0L;
        } catch (Exception e) {
            log.warn("Redis get failed for key {}: {}", key, e.getMessage());
            return 0L;
        }
    }

    public void setCounter(String key, long value) {
        try {
            redisTemplate.opsForValue().set(PREFIX + key, String.valueOf(value));
        } catch (Exception e) {
            log.warn("Redis set failed for key {}: {}", key, e.getMessage());
        }
    }

    public void setCounterWithExpiry(String key, long value, Duration duration) {
        try {
            redisTemplate.opsForValue().set(PREFIX + key, String.valueOf(value), duration);
        } catch (Exception e) {
            log.warn("Redis set with expiry failed for key {}: {}", key, e.getMessage());
        }
    }

    // --- Job Leaderboard ---

    public void trackJobCreated(String jobId, String title) {
        try {
            redisTemplate.opsForZSet().add(LEADERBOARD_JOBS, jobId, 0);
            redisTemplate.opsForHash().put(JOB_TITLES, jobId, title);
        } catch (Exception e) {
            log.warn("Redis trackJobCreated failed: {}", e.getMessage());
        }
    }

    public void incrementJobApplications(String jobId) {
        try {
            redisTemplate.opsForZSet().incrementScore(LEADERBOARD_JOBS, jobId, 1);
        } catch (Exception e) {
            log.warn("Redis incrementJobApplications failed: {}", e.getMessage());
        }
    }

    public List<Map<String, Object>> getTopJobs(int count) {
        try {
            var entries = redisTemplate.opsForZSet().reverseRangeWithScores(LEADERBOARD_JOBS, 0, count - 1L);
            if (entries == null) return List.of();

            return entries.stream().map(entry -> {
                String jobId = entry.getValue();
                Double score = entry.getScore();
                Object title = redisTemplate.opsForHash().get(JOB_TITLES, jobId);
                Map<String, Object> map = new LinkedHashMap<>();
                map.put("jobId", jobId);
                map.put("title", title != null ? title.toString() : "");
                map.put("applications", score != null ? score.longValue() : 0L);
                return map;
            }).collect(Collectors.toList());
        } catch (Exception e) {
            log.warn("Redis getTopJobs failed: {}", e.getMessage());
            return List.of();
        }
    }

    // --- Event Leaderboard ---

    public void trackEventCreated(String eventId, String title) {
        try {
            redisTemplate.opsForZSet().add(LEADERBOARD_EVENTS, eventId, 0);
            redisTemplate.opsForHash().put(EVENT_TITLES, eventId, title);
        } catch (Exception e) {
            log.warn("Redis trackEventCreated failed: {}", e.getMessage());
        }
    }

    public void incrementEventRsvps(String eventId) {
        try {
            redisTemplate.opsForZSet().incrementScore(LEADERBOARD_EVENTS, eventId, 1);
        } catch (Exception e) {
            log.warn("Redis incrementEventRsvps failed: {}", e.getMessage());
        }
    }

    public List<Map<String, Object>> getTopEvents(int count) {
        try {
            var entries = redisTemplate.opsForZSet().reverseRangeWithScores(LEADERBOARD_EVENTS, 0, count - 1L);
            if (entries == null) return List.of();

            return entries.stream().map(entry -> {
                String eventId = entry.getValue();
                Double score = entry.getScore();
                Object title = redisTemplate.opsForHash().get(EVENT_TITLES, eventId);
                Map<String, Object> map = new LinkedHashMap<>();
                map.put("eventId", eventId);
                map.put("title", title != null ? title.toString() : "");
                map.put("rsvpCount", score != null ? score.longValue() : 0L);
                return map;
            }).collect(Collectors.toList());
        } catch (Exception e) {
            log.warn("Redis getTopEvents failed: {}", e.getMessage());
            return List.of();
        }
    }

    // --- Daily counter reset ---

    public void resetDailyCounters() {
        try {
            Set<String> keys = redisTemplate.keys(PREFIX + "*:today");
            if (keys != null && !keys.isEmpty()) {
                redisTemplate.delete(keys);
            }
        } catch (Exception e) {
            log.warn("Redis resetDailyCounters failed: {}", e.getMessage());
        }
    }
}
