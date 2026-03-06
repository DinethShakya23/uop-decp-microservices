import 'package:decp_mobile_app/features/messaging/data/datasources/messaging_remote_datasource.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/messaging_models.dart';

class ConversationsState {
  final List<ConversationModel> conversations;
  final bool isLoading;
  final String? error;

  const ConversationsState({this.conversations = const [], this.isLoading = false, this.error});

  ConversationsState copyWith({List<ConversationModel>? conversations, bool? isLoading, String? error, bool clearError = false}) =>
      ConversationsState(
        conversations: conversations ?? this.conversations,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
      );
}

class ConversationsNotifier extends Notifier<ConversationsState> {

@override
  ConversationsState build(){
    _init();
    return const ConversationsState();
  }

Future<void> _init() async {
  await loadConversations();
}

  Future<void> loadConversations() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final convs = await ref.read(messagingDatasourceProvider).getConversations();
      state = state.copyWith(conversations: convs, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<ConversationModel?> startConversation(
      List<int> participantIds, List<String> participantNames, String msg) async {
    try {
      final conv = await ref.read(messagingDatasourceProvider)
          .createConversation(participantIds, participantNames, msg);
      state = state.copyWith(conversations: [conv, ...state.conversations]);
      return conv;
    } catch (_) {
      return null;
    }
  }
}

final conversationsProvider = NotifierProvider<ConversationsNotifier, ConversationsState>(ConversationsNotifier.new);
