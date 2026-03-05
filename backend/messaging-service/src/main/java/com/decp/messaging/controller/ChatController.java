package com.decp.messaging.controller;

import com.decp.messaging.dto.ChatMessageRequest;
import com.decp.messaging.dto.MessageResponse;
import com.decp.messaging.dto.TypingIndicator;
import com.decp.messaging.service.MessagingService;
import com.decp.messaging.service.OnlineStatusService;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.handler.annotation.Header;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;

@Controller
@RequiredArgsConstructor
public class ChatController {

    private final MessagingService messagingService;
    private final OnlineStatusService onlineStatusService;
    private final SimpMessagingTemplate messagingTemplate;

    @MessageMapping("/chat/send")
    public void sendMessage(@Payload ChatMessageRequest request,
                            @Header(value = "X-User-Id", defaultValue = "0") Long userId,
                            @Header(value = "X-User-Name", defaultValue = "Unknown") String userName) {

        // Refresh online status on activity
        onlineStatusService.setUserOnline(userId);

        MessageResponse response = messagingService.sendMessage(
                request.getConversationId(),
                userId,
                userName,
                request.getContent()
        );

        // Broadcast to conversation topic
        messagingTemplate.convertAndSend(
                "/topic/messages/" + request.getConversationId(),
                response
        );
    }

    @MessageMapping("/chat/typing")
    public void typing(@Payload TypingIndicator indicator) {
        messagingTemplate.convertAndSend(
                "/topic/typing/" + indicator.getConversationId(),
                indicator
        );
    }

    @MessageMapping("/chat/read")
    public void markRead(@Payload String conversationId,
                         @Header(value = "X-User-Id", defaultValue = "0") Long userId) {
        messagingService.markMessagesAsRead(conversationId, userId);

        // Notify others that messages were read
        messagingTemplate.convertAndSend(
                "/topic/read/" + conversationId,
                userId
        );
    }

    @MessageMapping("/chat/online")
    public void setOnline(@Header(value = "X-User-Id", defaultValue = "0") Long userId) {
        onlineStatusService.setUserOnline(userId);
    }

    @MessageMapping("/chat/offline")
    public void setOffline(@Header(value = "X-User-Id", defaultValue = "0") Long userId) {
        onlineStatusService.setUserOffline(userId);
    }
}
