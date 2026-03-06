import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/messaging_remote_datasource.dart';
import '../../data/datasources/messaging_websocket_datasource.dart';
import '../../data/models/messaging_models.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/storage/secure_storage_service.dart';

// --- Chat State ---
class ChatState {
  final List<MessageModel> messages;
  final bool isLoading;
  final bool isConnected;
  final bool someoneTyping;
  final String? typingUser;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.isConnected = false,
    this.someoneTyping = false,
    this.typingUser,
  });

  ChatState copyWith({
    List<MessageModel>? messages,
    bool? isLoading,
    bool? isConnected,
    bool? someoneTyping,
    String? typingUser,
    bool clearTyping = false,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isConnected: isConnected ?? this.isConnected,
      someoneTyping:
          clearTyping ? false : (someoneTyping ?? this.someoneTyping),
      typingUser: clearTyping ? null : (typingUser ?? this.typingUser),
    );
  }
}

class ChatNotifier extends Notifier<ChatState> {
  final String conversationId;
  late final MessagingWebSocketDatasource _ws;

  ChatNotifier(this.conversationId);

  @override
  ChatState build() {
    _init();
    return const ChatState();
  }

  Future<void> _init() async {
    state = state.copyWith(isLoading: true);
    try {
      // Load history
      final messages = await ref
          .read(messagingDatasourceProvider)
          .getMessages(conversationId);
      state = state.copyWith(
          messages: messages.reversed.toList(), isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }

    // Connect WebSocket
    final user = ref.read(currentUserProvider);
    _ws = MessagingWebSocketDatasource(
      storage: ref.read(secureStorageProvider),
      onMessage: (msg) {
        state = state.copyWith(messages: [...state.messages, msg]);
      },
      onTyping: (data) {
        final isTyping = data['typing'] as bool? ?? false;
        state = state.copyWith(
          someoneTyping: isTyping,
          typingUser: data['userName'] as String?,
          clearTyping: !isTyping,
        );
      },
    );
    await _ws.connect(conversationId: conversationId);
    if (user != null) _ws.sendOnline(user.id);

    // Cleanup on dispose
    ref.onDispose(() {
      if (user != null) _ws.sendOffline(user.id);
      _ws.disconnect();
    });

    state = state.copyWith(isConnected: true);
  }

  void sendMessage(String content) {
    final user = ref.read(currentUserProvider);
    if (user == null || content.trim().isEmpty) return;
    _ws.sendMessage(
        conversationId: conversationId,
        content: content,
        userId: user.id,
        userName: user.username);
    // Optimistic: add immediately
    final optimistic = MessageModel(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: conversationId,
      senderId: user.id,
      senderName: user.username,
      content: content,
      readBy: [user.id],
      createdAt: DateTime.now().toIso8601String(),
    );
    state = state.copyWith(messages: [...state.messages, optimistic]);
  }

  void sendTyping(bool typing) {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    _ws.sendTyping(
        conversationId: conversationId,
        userId: user.id,
        userName: user.username,
        typing: typing);
  }
}

final chatProvider =
    NotifierProvider.family<ChatNotifier, ChatState, String>(ChatNotifier.new);
