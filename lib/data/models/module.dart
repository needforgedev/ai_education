class CourseModule {
  final String id;
  final String courseId;
  final String title;
  final String objective;
  final List<String> contentBlocks;
  final int orderIndex;

  const CourseModule({
    required this.id,
    required this.courseId,
    required this.title,
    required this.objective,
    required this.contentBlocks,
    required this.orderIndex,
  });

  factory CourseModule.fromJson(Map<String, dynamic> json) => CourseModule(
        id: json['id'] as String,
        courseId: json['course_id'] as String,
        title: json['title'] as String,
        objective: json['objective'] as String,
        contentBlocks: (json['content_blocks'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
        orderIndex: json['order_index'] as int,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'course_id': courseId,
        'title': title,
        'objective': objective,
        'content_blocks': contentBlocks,
        'order_index': orderIndex,
      };
}
