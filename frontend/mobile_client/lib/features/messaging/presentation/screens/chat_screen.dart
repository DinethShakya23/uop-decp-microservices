import 'package:decp_mobile_app/features/messaging/presentation/providers/chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/utils/date_utils.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;
  const ChatScreen({super.key, required this.conversationId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _typing = false;

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    ref.read(chatProvider(widget.conversationId).notifier).sendMessage(text);
    _ctrl.clear();
    _scrollToBottom();
    if (_typing) {
      ref.read(chatProvider(widget.conversationId).notifier).sendTyping(false);
      setState(() => _typing = false);
    }
  }

  void _onTextChanged(String value) {
    final now = value.isNotEmpty;
    if (now != _typing) {
      setState(() => _typing = now);
      ref.read(chatProvider(widget.conversationId).notifier).sendTyping(now);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatProvider(widget.conversationId));
    final currentUser = ref.watch(currentUserProvider);

    // Auto-scroll when new messages arrive
    if (state.messages.isNotEmpty) _scrollToBottom();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: state.isConnected ? Colors.greenAccent : Colors.grey,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (state.isLoading)
            const LinearProgressIndicator(),

          // Messages
          Expanded(
            child: state.messages.isEmpty && !state.isLoading
                ? const Center(child: Text('No messages yet. Say hello!'))
                : ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    itemCount: state.messages.length,
                    itemBuilder: (_, i) {
                      final msg = state.messages[i];
                      final isMe = msg.senderId == currentUser?.id;
                      return _MessageBubble(
                          message: msg, isMe: isMe);
                    },
                  ),
          ),

          // Typing indicator
          if (state.someoneTyping) ...[
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 4),
              child: Row(children: [
                Text('${state.typingUser ?? 'Someone'} is typing...',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E),
                        fontStyle: FontStyle.italic)),
              ]),
            ),
          ],

          // Input bar
          Container(
            padding: EdgeInsets.fromLTRB(
                12, 8, 12, MediaQuery.of(context).viewInsets.bottom + 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, -2))
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    onChanged: _onTextChanged,
                    onSubmitted: (_) => _send(),
                    textInputAction: TextInputAction.send,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none),
                      filled: true,
                      fillColor: const Color(0xFFF5F7FA),
                    ),
                    maxLines: null,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF1565C0),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    onPressed: _send,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final dynamic message;
  final bool isMe;
  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 2),
              child: Text(message.senderName,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
            ),
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72),
            decoration: BoxDecoration(
              color: isMe ? const Color(0xFF1565C0) : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isMe ? 18 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 18),
              ),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  message.content,
                  style: TextStyle(
                      color: isMe ? Colors.white : const Color(0xFF212121),
                      fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  timeAgo(message.createdAt),
                  style: TextStyle(
                      fontSize: 10,
                      color: isMe ? Colors.white60 : const Color(0xFFBDBDBD)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
