class CommunityReply {
  final String id;
  final String threadId;
  final String authorId;
  final String authorName;
  final String body;
  final bool isModeratorReply;
  final bool isHidden;
  final DateTime createdAt;

  const CommunityReply({
    required this.id,
    required this.threadId,
    required this.authorId,
    required this.authorName,
    required this.body,
    required this.isModeratorReply,
    required this.isHidden,
    required this.createdAt,
  });

  factory CommunityReply.fromJson(Map<String, dynamic> json) =>
      CommunityReply(
        id: json['id'] as String,
        threadId: json['thread_id'] as String,
        authorId: json['author_id'] as String,
        authorName: json['author_name'] as String,
        body: json['body'] as String,
        isModeratorReply: json['is_moderator_reply'] as bool,
        isHidden: json['is_hidden'] as bool,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'thread_id': threadId,
        'author_id': authorId,
        'author_name': authorName,
        'body': body,
        'is_moderator_reply': isModeratorReply,
        'is_hidden': isHidden,
        'created_at': createdAt.toIso8601String(),
      };
}
