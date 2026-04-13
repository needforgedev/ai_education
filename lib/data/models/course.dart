class Course {
  final String id;
  final String cohortId;
  final String title;
  final String description;
  final int moduleCount;
  final String icon;
  final int orderIndex;
  final bool isPublished;

  const Course({
    required this.id,
    required this.cohortId,
    required this.title,
    required this.description,
    required this.moduleCount,
    required this.icon,
    required this.orderIndex,
    required this.isPublished,
  });

  factory Course.fromJson(Map<String, dynamic> json) => Course(
        id: json['id'] as String,
        cohortId: json['cohort_id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        moduleCount: json['module_count'] as int,
        icon: json['icon'] as String,
        orderIndex: json['order_index'] as int,
        isPublished: json['is_published'] as bool,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'cohort_id': cohortId,
        'title': title,
        'description': description,
        'module_count': moduleCount,
        'icon': icon,
        'order_index': orderIndex,
        'is_published': isPublished,
      };
}
