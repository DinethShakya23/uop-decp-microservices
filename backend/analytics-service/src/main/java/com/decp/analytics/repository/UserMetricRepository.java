package com.decp.analytics.repository;

import com.decp.analytics.model.UserMetric;
import com.decp.analytics.model.UserRole;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface UserMetricRepository extends JpaRepository<UserMetric, Long> {

    Optional<UserMetric> findByUserId(Long userId);

    Long countByRole(UserRole role);

    Long countByCreatedAtAfter(LocalDateTime after);

    Long countByLastActiveAtAfter(LocalDateTime after);

    @Query("SELECT u FROM UserMetric u ORDER BY " +
           "(u.postsCreated + u.eventsAttended + u.jobsApplied + u.researchUploaded + u.messagesCount) DESC LIMIT 10")
    List<UserMetric> findMostActiveUsers();

    @Query("SELECT COUNT(u) FROM UserMetric u WHERE u.lastActiveAt > :since AND u.createdAt < :since")
    Long countReturningUsersSince(@Param("since") LocalDateTime since);
}
