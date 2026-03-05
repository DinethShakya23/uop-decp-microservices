package com.decp.messaging.service;

import com.decp.messaging.dto.*;
import com.decp.messaging.model.Conversation;
import com.decp.messaging.model.Message;
import com.decp.messaging.repository.ConversationRepository;
import com.decp.messaging.repository.MessageRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class MessagingService {

    private final ConversationRepository conversationRepository;
    private final MessageRepository messageRepository;

    public ConversationResponse createConversation(ConversationRequest request, Long currentUserId, String currentUserName) {
        // Ensure current user is in participants
        List<Long> participants = new java.util.ArrayList<>(request.getParticipantIds());
        if (!participants.contains(currentUserId)) {
            participants.add(currentUserId);
        }

        List<String> participantNames = request.getParticipantNames() != null
                ? new java.util.ArrayList<>(request.getParticipantNames())
                : new java.util.ArrayList<>();
        if (!participantNames.contains(currentUserName)) {
            participantNames.add(currentUserName);
        }

        LocalDateTime now = LocalDateTime.now();
        Conversation conversation = Conversation.builder()
                .participants(participants)
                .participantNames(participantNames)
                .createdAt(now)
                .updatedAt(now)
                .build();

        // If initial message provided, set it
        if (request.getInitialMessage() != null && !request.getInitialMessage().isBlank()) {
            conversation.setLastMessage(request.getInitialMessage());
            conversation.setLastMessageAt(now);
        }

        Conversation saved = conversationRepository.save(conversation);

        // Create initial message if provided
        if (request.getInitialMessage() != null && !request.getInitialMessage().isBlank()) {
            Message message = Message.builder()
                    .conversationId(saved.getId())
                    .senderId(currentUserId)
                    .senderName(currentUserName)
                    .content(request.getInitialMessage())
                    .readBy(List.of(currentUserId))
                    .createdAt(now)
                    .build();
            messageRepository.save(message);
        }

        return toConversationResponse(saved, currentUserId);
    }

    public List<ConversationResponse> getUserConversations(Long userId) {
        return conversationRepository
                .findByParticipantsContainingAndDeletedByNotContainingOrderByLastMessageAtDesc(userId, userId)
                .stream()
                .map(c -> toConversationResponse(c, userId))
                .toList();
    }

    public ConversationResponse getConversation(String conversationId, Long userId) {
        Conversation conversation = findConversationAndVerifyAccess(conversationId, userId);
        return toConversationResponse(conversation, userId);
    }

    public Page<MessageResponse> getMessages(String conversationId, Long userId, int page, int size) {
        findConversationAndVerifyAccess(conversationId, userId);

        Pageable pageable = PageRequest.of(page, size);
        return messageRepository.findByConversationIdOrderByCreatedAtDesc(conversationId, pageable)
                .map(this::toMessageResponse);
    }

    public MessageResponse sendMessage(String conversationId, Long senderId, String senderName, String content) {
        Conversation conversation = findConversationAndVerifyAccess(conversationId, senderId);

        LocalDateTime now = LocalDateTime.now();
        Message message = Message.builder()
                .conversationId(conversationId)
                .senderId(senderId)
                .senderName(senderName)
                .content(content)
                .readBy(List.of(senderId))
                .createdAt(now)
                .build();

        Message saved = messageRepository.save(message);

        // Update conversation with last message
        conversation.setLastMessage(content);
        conversation.setLastMessageAt(now);
        conversation.setUpdatedAt(now);
        conversationRepository.save(conversation);

        return toMessageResponse(saved);
    }

    public void markMessagesAsRead(String conversationId, Long userId) {
        findConversationAndVerifyAccess(conversationId, userId);

        Pageable allMessages = PageRequest.of(0, 1000);
        Page<Message> messages = messageRepository.findByConversationIdOrderByCreatedAtDesc(conversationId, allMessages);

        messages.getContent().stream()
                .filter(m -> !m.getReadBy().contains(userId))
                .forEach(m -> {
                    m.getReadBy().add(userId);
                    messageRepository.save(m);
                });
    }

    public void deleteConversation(String conversationId, Long userId) {
        Conversation conversation = findConversationAndVerifyAccess(conversationId, userId);
        conversation.getDeletedBy().add(userId);

        // If all participants deleted, remove entirely
        if (conversation.getDeletedBy().containsAll(conversation.getParticipants())) {
            messageRepository.deleteAllByConversationId(conversationId);
            conversationRepository.delete(conversation);
        } else {
            conversationRepository.save(conversation);
        }
    }

    private Conversation findConversationAndVerifyAccess(String conversationId, Long userId) {
        Conversation conversation = conversationRepository.findById(conversationId)
                .orElseThrow(() -> new RuntimeException("Conversation not found with id: " + conversationId));

        if (!conversation.getParticipants().contains(userId)) {
            throw new RuntimeException("Not authorized to access this conversation");
        }

        return conversation;
    }

    private ConversationResponse toConversationResponse(Conversation conversation, Long userId) {
        long unreadCount = messageRepository.countByConversationIdAndReadByNotContaining(conversation.getId(), userId);
        return ConversationResponse.builder()
                .id(conversation.getId())
                .participants(conversation.getParticipants())
                .participantNames(conversation.getParticipantNames())
                .lastMessage(conversation.getLastMessage())
                .lastMessageAt(conversation.getLastMessageAt())
                .createdAt(conversation.getCreatedAt())
                .unreadCount(unreadCount)
                .build();
    }

    private MessageResponse toMessageResponse(Message message) {
        return MessageResponse.builder()
                .id(message.getId())
                .conversationId(message.getConversationId())
                .senderId(message.getSenderId())
                .senderName(message.getSenderName())
                .content(message.getContent())
                .readBy(message.getReadBy())
                .createdAt(message.getCreatedAt())
                .build();
    }
}
