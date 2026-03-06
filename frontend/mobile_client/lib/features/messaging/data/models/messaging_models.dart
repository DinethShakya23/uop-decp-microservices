class ConversationModel {
  final String id;
  final List<int> participants;
  final List<String> participantNames;
  final String? lastMessage;
  final String? lastMessageAt;
  final String? createdAt;
  final int unreadCount;

  const ConversationModel({
    required this.id,
    required this.participants,
    required this.participantNames,
    this.lastMessage,
    this.lastMessageAt,
    this.createdAt,
    required this.unreadCount,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] as String,
      participants: (json['participants'] as List).map((e) => (e as num).toInt()).toList(),
      participantNames: (json['participantNames'] as List?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      lastMessage: json['lastMessage'] as String?,
      lastMessageAt: json['lastMessageAt'] as String?,
      createdAt: json['createdAt'] as String?,
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class MessageModel {
  final String id;
  final String conversationId;
  final int senderId;
  final String senderName;
  final String content;
  final List<int> readBy;
  final String createdAt;

  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.readBy,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String,
      senderId: (json['senderId'] as num).toInt(),
      senderName: json['senderName'] as String,
      content: json['content'] as String,
      readBy: (json['readBy'] as List?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [],
      createdAt: json['createdAt'] as String? ?? '',
    );
  }
}
