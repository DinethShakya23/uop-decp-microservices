import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notifications_provider.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(notificationsProvider.notifier).loadNotifications());
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'POST_LIKED': return Icons.favorite_rounded;
      case 'POST_COMMENTED': return Icons.comment_rounded;
      case 'NEW_POST': return Icons.feed_rounded;
      case 'JOB_CREATED': return Icons.work_rounded;
      case 'JOB_APPLICATION': return Icons.send_rounded;
      case 'EVENT_CREATED': return Icons.event_rounded;
      case 'EVENT_RSVP': return Icons.how_to_reg_rounded;
      case 'USER_REGISTERED': return Icons.person_add_rounded;
      default: return Icons.notifications_rounded;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'POST_LIKED': return Colors.red;
      case 'POST_COMMENTED': return const Color(0xFF1565C0);
      case 'JOB_CREATED':
      case 'JOB_APPLICATION': return const Color(0xFF00897B);
      case 'EVENT_CREATED':
      case 'EVENT_RSVP': return const Color(0xFFF57C00);
      default: return const Color(0xFF546E7A);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (state.notifications.any((n) => !n.read))
            TextButton(
              onPressed: () =>
                  ref.read(notificationsProvider.notifier).markAllRead(),
              child: const Text('Mark all read',
                  style: TextStyle(color: Colors.white, fontSize: 13)),
            ),
        ],
      ),
      body: Builder(builder: (_) {
        if (state.isLoading && state.notifications.isEmpty) {
          return const AppLoadingWidget(message: 'Loading notifications...');
        }
        if (state.error != null && state.notifications.isEmpty) {
          return AppErrorWidget(
              message: state.error!,
              onRetry: () =>
                  ref.read(notificationsProvider.notifier).loadNotifications());
        }
        if (state.notifications.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_none_outlined, size: 60, color: Color(0xFFBDBDBD)),
                SizedBox(height: 16),
                Text('No notifications yet', style: TextStyle(color: Color(0xFF9E9E9E))),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () =>
              ref.read(notificationsProvider.notifier).loadNotifications(),
          child: ListView.builder(
            itemCount: state.notifications.length,
            itemBuilder: (_, i) {
              final n = state.notifications[i];
              final iconColor = _colorForType(n.type);
              return Dismissible(
                key: Key(n.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete_outline, color: Colors.white),
                ),
                onDismissed: (_) =>
                    ref.read(notificationsProvider.notifier).deleteNotification(n.id),
                child: InkWell(
                  onTap: () {
                    if (!n.read) {
                      ref.read(notificationsProvider.notifier).markRead(n.id);
                    }
                  },
                  child: Container(
                    color: n.read ? null : const Color(0xFF1565C0).withValues(alpha: 0.05),
                    child: ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: iconColor.withValues(alpha: 0.12),
                        child: Icon(_iconForType(n.type), color: iconColor, size: 22),
                      ),
                      title: Text(n.title,
                          style: TextStyle(
                              fontWeight: n.read ? FontWeight.normal : FontWeight.w700,
                              fontSize: 14)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(n.message, style: const TextStyle(fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(timeAgo(n.createdAt),
                              style: const TextStyle(
                                  fontSize: 11, color: Color(0xFFBDBDBD))),
                        ],
                      ),
                      trailing: !n.read
                          ? Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                  color: Color(0xFF1565C0), shape: BoxShape.circle))
                          : null,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
