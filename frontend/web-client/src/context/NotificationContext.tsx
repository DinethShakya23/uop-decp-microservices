import {
  createContext,
  useContext,
  useState,
  useEffect,
  useCallback,
  type ReactNode,
} from "react";
import type { NotificationResponse } from "../types";
import { notificationService } from "../services/notification";
import { useAuth } from "./AuthContext";

interface NotificationContextType {
  notifications: NotificationResponse[];
  unreadCount: number;
  loading: boolean;
  refresh: () => Promise<void>;
  markAsRead: (id: string) => Promise<void>;
  markAllRead: () => Promise<void>;
  removeNotification: (id: string) => Promise<void>;
}

const NotificationContext = createContext<NotificationContextType | undefined>(
  undefined,
);

export function NotificationProvider({ children }: { children: ReactNode }) {
  const { isAuthenticated } = useAuth();
  const [notifications, setNotifications] = useState<NotificationResponse[]>(
    [],
  );
  const [unreadCount, setUnreadCount] = useState(0);
  const [loading, setLoading] = useState(false);

  const refresh = useCallback(async () => {
    if (!isAuthenticated) return;
    setLoading(true);
    try {
      const [notifRes, countRes] = await Promise.all([
        notificationService.getAll(),
        notificationService.getUnreadCount(),
      ]);
      setNotifications(notifRes.data);
      setUnreadCount(countRes.data.count);
    } catch {
      // silently fail
    } finally {
      setLoading(false);
    }
  }, [isAuthenticated]);

  useEffect(() => {
    refresh();
    if (!isAuthenticated) return;
    const interval = setInterval(refresh, 30000);
    return () => clearInterval(interval);
  }, [refresh, isAuthenticated]);

  const markAsRead = useCallback(async (id: string) => {
    await notificationService.markAsRead(id);
    setNotifications((prev) =>
      prev.map((n) => (n.id === id ? { ...n, read: true } : n)),
    );
    setUnreadCount((prev) => Math.max(0, prev - 1));
  }, []);

  const markAllRead = useCallback(async () => {
    await notificationService.markAllRead();
    setNotifications((prev) => prev.map((n) => ({ ...n, read: true })));
    setUnreadCount(0);
  }, []);

  const removeNotification = useCallback(async (id: string) => {
    await notificationService.remove(id);
    setNotifications((prev) => {
      const n = prev.find((x) => x.id === id);
      if (n && !n.read) setUnreadCount((c) => Math.max(0, c - 1));
      return prev.filter((x) => x.id !== id);
    });
  }, []);

  return (
    <NotificationContext.Provider
      value={{
        notifications,
        unreadCount,
        loading,
        refresh,
        markAsRead,
        markAllRead,
        removeNotification,
      }}
    >
      {children}
    </NotificationContext.Provider>
  );
}

export function useNotifications(): NotificationContextType {
  const ctx = useContext(NotificationContext);
  if (!ctx)
    throw new Error(
      "useNotifications must be used within NotificationProvider",
    );
  return ctx;
}
