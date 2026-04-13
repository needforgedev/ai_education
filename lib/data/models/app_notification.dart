class AppNotification {
  final String id;
  final String userId;
  final String type; // 'submission_graded' | 'moderator_reply' | 'continue_reminder'
  final String title;
  final String body;
  final String? data; // JSON string with contextual info
  final bool isRead;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.data,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        type: json['type'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        data: json['data'] as String?,
        isRead: json['is_read'] as bool,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'type': type,
        'title': title,
        'body': body,
        'data': data,
        'is_read': isRead,
        'created_at': createdAt.toIso8601String(),
      };
}
