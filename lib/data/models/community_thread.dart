import 'community_reply.dart';

class CommunityThread {
  final String id;
  final String schoolId;
  final String? courseId;
  final String? moduleId;
  final String authorId;
  final String authorName;
  final String title;
  final String body;
  final bool isModeratorPost;
  final bool isPinned;
  final bool isHidden;
  final DateTime createdAt;
  final List<CommunityReply> replies;

  const CommunityThread({
    required this.id,
    required this.schoolId,
    this.courseId,
    this.moduleId,
    required this.authorId,
    required this.authorName,
    required this.title,
    required this.body,
    required this.isModeratorPost,
    required this.isPinned,
    required this.isHidden,
    required this.createdAt,
    this.replies = const [],
  });

  factory CommunityThread.fromJson(Map<String, dynamic> json) =>
      CommunityThread(
        id: json['id'] as String,
        schoolId: json['school_id'] as String,
        courseId: json['course_id'] as String?,
        moduleId: json['module_id'] as String?,
        authorId: json['author_id'] as String,
        authorName: json['author_name'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        isModeratorPost: json['is_moderator_post'] as bool,
        isPinned: json['is_pinned'] as bool,
        isHidden: json['is_hidden'] as bool,
        createdAt: DateTime.parse(json['created_at'] as String),
        replies: json['community_replies'] != null
            ? (json['community_replies'] as List<dynamic>)
                .map((e) =>
                    CommunityReply.fromJson(e as Map<String, dynamic>))
                .toList()
            : [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'school_id': schoolId,
        'course_id': courseId,
        'module_id': moduleId,
        'author_id': authorId,
        'author_name': authorName,
        'title': title,
        'body': body,
        'is_moderator_post': isModeratorPost,
        'is_pinned': isPinned,
        'is_hidden': isHidden,
        'created_at': createdAt.toIso8601String(),
      };
}
