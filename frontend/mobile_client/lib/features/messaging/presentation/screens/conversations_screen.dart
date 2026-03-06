import 'package:decp_mobile_app/features/messaging/presentation/providers/conversations_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../core/utils/date_utils.dart';

class ConversationsScreen extends ConsumerStatefulWidget {
  const ConversationsScreen({super.key});

  @override
  ConsumerState<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends ConsumerState<ConversationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(conversationsProvider.notifier).loadConversations());
  }

  @override
  Widget build(BuildContext context, ) {
    final state = ref.watch(conversationsProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: Builder(builder: (_) {
        if (state.isLoading && state.conversations.isEmpty) {
          return const AppLoadingWidget(message: 'Loading conversations...');
        }
        if (state.error != null && state.conversations.isEmpty) {
          return AppErrorWidget(
              message: state.error!,
              onRetry: () => ref.read(conversationsProvider.notifier).loadConversations());
        }
        if (state.conversations.isEmpty) {
          return const Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.chat_bubble_outline_rounded, size: 60, color: Color(0xFFBDBDBD)),
              SizedBox(height: 16),
              Text('No conversations yet', style: TextStyle(color: Color(0xFF9E9E9E))),
            ]),
          );
        }
        return RefreshIndicator(
          onRefresh: () => ref.read(conversationsProvider.notifier).loadConversations(),
          child: ListView.builder(
            itemCount: state.conversations.length,
            itemBuilder: (_, i) {
              final conv = state.conversations[i];
              // Determine the other participant's name
              final otherNames = currentUser == null
                  ? conv.participantNames
                  : conv.participantNames
                      .where((name) => name != currentUser.username)
                      .toList();
              final displayName = otherNames.isNotEmpty
                  ? otherNames.join(', ')
                  : conv.participantNames.join(', ');
              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFF1565C0).withValues(alpha: 0.15),
                  child: Text(
                    displayName.isNotEmpty
                        ? displayName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Color(0xFF1565C0)),
                  ),
                ),
                title: Text(displayName, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(conv.lastMessage ?? 'No messages yet',
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13)),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (conv.lastMessageAt != null)
                      Text(timeAgo(conv.lastMessageAt!),
                          style: const TextStyle(fontSize: 11, color: Color(0xFFBDBDBD))),
                    if (conv.unreadCount > 0) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                            color: const Color(0xFF1565C0),
                            borderRadius: BorderRadius.circular(12)),
                        child: Text('${conv.unreadCount}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ],
                ),
                onTap: () => context.push('/chat/${conv.id}'),
              );
            },
          ),
        );
      }),
    );
  }
}
