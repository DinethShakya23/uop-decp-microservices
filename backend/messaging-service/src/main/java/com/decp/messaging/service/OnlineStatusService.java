package com.decp.messaging.service;

import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class OnlineStatusService {

    private static final String ONLINE_KEY_PREFIX = "user:online:";
    private static final Duration ONLINE_TTL = Duration.ofMinutes(5);

    private final StringRedisTemplate redisTemplate;

    public void setUserOnline(Long userId) {
        redisTemplate.opsForValue().set(ONLINE_KEY_PREFIX + userId, "online", ONLINE_TTL);
    }

    public void setUserOffline(Long userId) {
        redisTemplate.delete(ONLINE_KEY_PREFIX + userId);
    }

    public boolean isUserOnline(Long userId) {
        return Boolean.TRUE.equals(redisTemplate.hasKey(ONLINE_KEY_PREFIX + userId));
    }

    public Set<Long> getOnlineUsers(Set<Long> userIds) {
        return userIds.stream()
                .filter(this::isUserOnline)
                .collect(Collectors.toSet());
    }

    public void refreshOnlineStatus(Long userId) {
        redisTemplate.expire(ONLINE_KEY_PREFIX + userId, ONLINE_TTL);
    }
}
