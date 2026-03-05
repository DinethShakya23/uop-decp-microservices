import api from "./api";
import type { ConversationResponse, MessageResponse, Page } from "../types";

export const chatService = {
  getConversations: () => api.get<ConversationResponse[]>("/api/conversations"),

  getConversation: (id: string) =>
    api.get<ConversationResponse>(`/api/conversations/${id}`),

  createConversation: (participants: number[]) =>
    api.post<ConversationResponse>("/api/conversations", { participants }),

  getMessages: (conversationId: string, page = 0, size = 50) =>
    api.get<Page<MessageResponse>>(
      `/api/conversations/${conversationId}/messages`,
      {
        params: { page, size },
      },
    ),

  markRead: (conversationId: string) =>
    api.put(`/api/conversations/${conversationId}/read`),

  deleteConversation: (id: string) => api.delete(`/api/conversations/${id}`),

  getOnlineUsers: (userIds: number[]) =>
    api.get<number[]>("/api/conversations/online", {
      params: { userIds: userIds.join(",") },
    }),
};
