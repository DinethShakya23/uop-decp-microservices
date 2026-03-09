package com.decp.user_service.repository;

import com.decp.user_service.model.Connection;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface ConnectionRepository extends JpaRepository<Connection, Long> {
    long countByUserId(Long userId);
    Optional<Connection> findByUserIdAndConnectedUserId(Long userId, Long connectedUserId);
}