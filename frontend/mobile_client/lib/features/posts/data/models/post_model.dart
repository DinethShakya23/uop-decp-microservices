class CommentModel {
  final int userId;
  final String username;
  final String text;
  final String? createdAt;

  const CommentModel({
    required this.userId,
    required this.username,
    required this.text,
    this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      userId: (json['userId'] as num).toInt(),
      username: json['username'] as String,
      text: json['text'] as String,
      createdAt: json['createdAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'username': username,
        'text': text,
        'createdAt': createdAt,
      };
}

class PostModel {
  final String id;
  final int userId;
  final String username;
  final String fullName;
  final String content;
  final List<String> mediaUrls;
  final List<int> likedBy;
  final List<CommentModel> comments;
  final String createdAt;
  final String updatedAt;

  const PostModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.fullName,
    required this.content,
    required this.mediaUrls,
    required this.likedBy,
    required this.comments,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      userId: (json['userId'] as num).toInt(),
      username: json['username'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      content: json['content'] as String,
      mediaUrls: (json['mediaUrls'] as List?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      likedBy: (json['likedBy'] as List?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [],
      comments: (json['comments'] as List?)
              ?.map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
    );
  }
}
