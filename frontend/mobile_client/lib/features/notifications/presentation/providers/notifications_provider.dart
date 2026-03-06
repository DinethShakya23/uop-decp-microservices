import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/notification_remote_datasource.dart';
import '../../data/models/notification_model.dart';

class NotificationsState {
  final List<NotificationModel> notifications;
  final bool isLoading;
  final String? error;
  final int unreadCount;

  const NotificationsState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
    this.unreadCount = 0,
  });

  NotificationsState copyWith({
    List<NotificationModel>? notifications,
    bool? isLoading,
    String? error,
    bool clearError = false,
    int? unreadCount,
  }) =>
      NotificationsState(
        notifications: notifications ?? this.notifications,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        unreadCount: unreadCount ?? this.unreadCount,
      );
}

class NotificationsNotifier extends Notifier<NotificationsState> {
  @override
  NotificationsState build() {
    _init();
    return const NotificationsState();
  }

  Future<void> _init() async {
    await loadNotifications();
  }

  Future<void> loadNotifications() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final ds = ref.read(notificationDatasourceProvider);
      final notifications = await ds.getNotifications();
      final unreadCount = await ds.getUnreadCount();
      state = state.copyWith(
          notifications: notifications,
          isLoading: false,
          unreadCount: unreadCount);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> markRead(String id) async {
    try {
      await ref.read(notificationDatasourceProvider).markRead(id);
      final notifications = state.notifications.map((n) {
        return n.id == id ? n.copyWith(read: true) : n;
      }).toList();
      final unread = notifications.where((n) => !n.read).length;
      state = state.copyWith(notifications: notifications, unreadCount: unread);
    } catch (_) {}
  }

  Future<void> markAllRead() async {
    try {
      await ref.read(notificationDatasourceProvider).markAllRead();
      final notifications =
          state.notifications.map((n) => n.copyWith(read: true)).toList();
      state = state.copyWith(notifications: notifications, unreadCount: 0);
    } catch (_) {}
  }

  Future<void> deleteNotification(String id) async {
    try {
      await ref.read(notificationDatasourceProvider).deleteNotification(id);
      final notifications =
          state.notifications.where((n) => n.id != id).toList();
      final unread = notifications.where((n) => !n.read).length;
      state = state.copyWith(notifications: notifications, unreadCount: unread);
    } catch (_) {}
  }
}

final notificationsProvider =
    NotifierProvider<NotificationsNotifier, NotificationsState>(
        NotificationsNotifier.new);
