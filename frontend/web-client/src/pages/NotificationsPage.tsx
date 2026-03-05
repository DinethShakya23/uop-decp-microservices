import { useNotifications } from "../context/NotificationContext";
import NotificationItem from "../components/notification/NotificationItem";
import LoadingSpinner from "../components/common/LoadingSpinner";

export default function NotificationsPage() {
  const {
    notifications,
    unreadCount,
    loading,
    markAsRead,
    markAllRead,
    removeNotification,
  } = useNotifications();

  if (loading && notifications.length === 0) return <LoadingSpinner />;

  return (
    <div className="mx-auto max-w-3xl px-4 py-6">
      <div className="mb-6 flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Notifications</h1>
          {unreadCount > 0 && (
            <p className="text-sm text-gray-500">{unreadCount} unread</p>
          )}
        </div>
        {unreadCount > 0 && (
          <button
            onClick={markAllRead}
            className="rounded-lg border border-gray-300 px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50"
          >
            Mark all as read
          </button>
        )}
      </div>

      <div className="space-y-3">
        {notifications.length === 0 ? (
          <div className="rounded-xl border border-gray-200 bg-white p-8 text-center text-gray-500">
            <svg
              className="mx-auto h-12 w-12 text-gray-300"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
              strokeWidth={1}
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"
              />
            </svg>
            <p className="mt-3 text-lg font-medium">No notifications</p>
            <p className="text-sm">You're all caught up!</p>
          </div>
        ) : (
          notifications.map((n) => (
            <NotificationItem
              key={n.id}
              notification={n}
              onMarkRead={markAsRead}
              onDelete={removeNotification}
            />
          ))
        )}
      </div>
    </div>
  );
}
