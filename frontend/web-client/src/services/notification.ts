import api from "./api";
import type { NotificationResponse, UnreadCountResponse } from "../types";

export const notificationService = {
  getAll: () => api.get<NotificationResponse[]>("/api/notifications"),

  markAsRead: (id: string) =>
    api.put<NotificationResponse>(`/api/notifications/${id}/read`),

  markAllRead: () => api.put("/api/notifications/read-all"),

  getUnreadCount: () =>
    api.get<UnreadCountResponse>("/api/notifications/unread-count"),

  remove: (id: string) => api.delete(`/api/notifications/${id}`),
};
