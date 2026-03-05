package com.decp.messaging.repository;

import com.decp.messaging.model.Conversation;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ConversationRepository extends MongoRepository<Conversation, String> {

    List<Conversation> findByParticipantsContainingOrderByLastMessageAtDesc(Long userId);

    List<Conversation> findByParticipantsContainingAndDeletedByNotContainingOrderByLastMessageAtDesc(Long userId, Long deletedUserId);
}
