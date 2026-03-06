import 'dart:convert';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../models/messaging_models.dart';

/// Manages a STOMP WebSocket connection for real-time chat.
class MessagingWebSocketDatasource {
  StompClient? _client;
  final SecureStorageService _storage;
  final void Function(MessageModel) onMessage;
  final void Function(Map<String, dynamic>) onTyping;

  MessagingWebSocketDatasource({
    required SecureStorageService storage,
    required this.onMessage,
    required this.onTyping,
  }) : _storage = storage;

  Future<void> connect({required String conversationId}) async {
    final token = await _storage.readToken();

    _client = StompClient(
      config: StompConfig(
        url: ApiConstants.wsUrl,
        onConnect: (frame) => _onConnect(frame, conversationId),
        onDisconnect: (_) {},
        onWebSocketError: (_) {},
        stompConnectHeaders: token != null ? {'Authorization': 'Bearer $token'} : {},
        webSocketConnectHeaders: token != null ? {'Authorization': 'Bearer $token'} : {},
      ),
    );
    _client!.activate();
  }

  void _onConnect(StompFrame frame, String conversationId) {
    // Subscribe to messages for this conversation
    _client!.subscribe(
      destination: '/topic/messages/$conversationId',
      callback: (frame) {
        if (frame.body == null) return;
        try {
          final data = jsonDecode(frame.body!) as Map<String, dynamic>;
          onMessage(MessageModel.fromJson(data));
        } catch (_) {}
      },
    );
    // Subscribe to typing indicators
    _client!.subscribe(
      destination: '/topic/typing/$conversationId',
      callback: (frame) {
        if (frame.body == null) return;
        try {
          final data = jsonDecode(frame.body!) as Map<String, dynamic>;
          onTyping(data);
        } catch (_) {}
      },
    );
  }

  void sendMessage({required String conversationId, required String content,
      required int userId, required String userName}) {
    _client?.send(
      destination: '/app/chat/send',
      headers: {'X-User-Id': '$userId', 'X-User-Name': userName},
      body: jsonEncode({'conversationId': conversationId, 'content': content}),
    );
  }

  void sendTyping({required String conversationId, required int userId,
      required String userName, required bool typing}) {
    _client?.send(
      destination: '/app/chat/typing',
      body: jsonEncode({
        'conversationId': conversationId,
        'userId': userId,
        'userName': userName,
        'typing': typing,
      }),
    );
  }

  void sendOnline(int userId) {
    _client?.send(
        destination: '/app/chat/online', headers: {'X-User-Id': '$userId'}, body: '');
  }

  void sendOffline(int userId) {
    _client?.send(
        destination: '/app/chat/offline', headers: {'X-User-Id': '$userId'}, body: '');
  }

  void disconnect() {
    _client?.deactivate();
    _client = null;
  }
}
