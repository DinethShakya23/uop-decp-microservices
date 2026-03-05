import type { NotificationResponse } from "../../types";
import { formatRelativeTime } from "../../utils/formatDate";

interface NotificationItemProps {
  notification: NotificationResponse;
  onMarkRead?: (id: string) => void;
  onDelete?: (id: string) => void;
}

const typeIcons: Record<string, string> = {
  POST_LIKED: "❤️",
  COMMENT: "💬",
  MENTORSHIP_REQUEST: "🤝",
  JOB_APPLICATION: "💼",
  EVENT_CREATED: "📅",
  EVENT_RSVP: "✅",
  SYSTEM: "🔔",
};

export default function NotificationItem({
  notification,
  onMarkRead,
  onDelete,
}: NotificationItemProps) {
  return (
    <div
      className={`flex items-start gap-3 rounded-lg border p-4 transition-colors ${
        notification.read
          ? "border-gray-100 bg-white"
          : "border-primary-100 bg-primary-50/50"
      }`}
    >
      <span className="text-xl">{typeIcons[notification.type] || "🔔"}</span>
      <div className="flex-1 min-w-0">
        <p className="text-sm font-medium text-gray-900">
          {notification.title}
        </p>
        <p className="mt-0.5 text-sm text-gray-600">{notification.message}</p>
        <p className="mt-1 text-xs text-gray-400">
          {formatRelativeTime(notification.createdAt)}
        </p>
      </div>
      <div className="flex flex-shrink-0 gap-1">
        {!notification.read && onMarkRead && (
          <button
            onClick={() => onMarkRead(notification.id)}
            className="rounded p-1 text-xs text-primary-600 hover:bg-primary-50"
            title="Mark as read"
          >
            ✓
          </button>
        )}
        {onDelete && (
          <button
            onClick={() => onDelete(notification.id)}
            className="rounded p-1 text-xs text-gray-400 hover:bg-gray-100 hover:text-red-500"
            title="Delete"
          >
            ✕
          </button>
        )}
      </div>
    </div>
  );
}
