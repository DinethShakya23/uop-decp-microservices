package com.decp.messaging.controller;

import com.decp.messaging.dto.ConversationRequest;
import com.decp.messaging.dto.ConversationResponse;
import com.decp.messaging.dto.MessageResponse;
import com.decp.messaging.service.MessagingService;
import com.decp.messaging.service.OnlineStatusService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Set;

@RestController
@RequestMapping("/api/conversations")
@RequiredArgsConstructor
public class ConversationController {

    private final MessagingService messagingService;
    private final OnlineStatusService onlineStatusService;

    @PostMapping
    public ResponseEntity<ConversationResponse> createConversation(
            @RequestHeader("X-User-Name") String userName,
            @RequestHeader(value = "X-User-Id", required = false, defaultValue = "0") Long userId,
            @Valid @RequestBody ConversationRequest request) {
        return ResponseEntity.ok(messagingService.createConversation(request, userId, userName));
    }

    @GetMapping
    public ResponseEntity<List<ConversationResponse>> getUserConversations(
            @RequestHeader(value = "X-User-Id", required = false, defaultValue = "0") Long userId) {
        return ResponseEntity.ok(messagingService.getUserConversations(userId));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ConversationResponse> getConversation(
            @PathVariable String id,
            @RequestHeader(value = "X-User-Id", required = false, defaultValue = "0") Long userId) {
        return ResponseEntity.ok(messagingService.getConversation(id, userId));
    }

    @GetMapping("/{id}/messages")
    public ResponseEntity<Page<MessageResponse>> getMessages(
            @PathVariable String id,
            @RequestHeader(value = "X-User-Id", required = false, defaultValue = "0") Long userId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "50") int size) {
        return ResponseEntity.ok(messagingService.getMessages(id, userId, page, size));
    }

    @PutMapping("/{id}/read")
    public ResponseEntity<Void> markAsRead(
            @PathVariable String id,
            @RequestHeader(value = "X-User-Id", required = false, defaultValue = "0") Long userId) {
        messagingService.markMessagesAsRead(id, userId);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteConversation(
            @PathVariable String id,
            @RequestHeader(value = "X-User-Id", required = false, defaultValue = "0") Long userId) {
        messagingService.deleteConversation(id, userId);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/online")
    public ResponseEntity<Set<Long>> getOnlineUsers(
            @RequestParam Set<Long> userIds) {
        return ResponseEntity.ok(onlineStatusService.getOnlineUsers(userIds));
    }
}
