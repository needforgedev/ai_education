class ModuleProgress {
  final String id;
  final String studentId;
  final String moduleId;
  final DateTime? lessonViewedAt;
  final DateTime? quizPassedAt;
  final int? bestQuizScore;
  final DateTime? completedAt;

  const ModuleProgress({
    required this.id,
    required this.studentId,
    required this.moduleId,
    this.lessonViewedAt,
    this.quizPassedAt,
    this.bestQuizScore,
    this.completedAt,
  });

  bool get isLessonViewed => lessonViewedAt != null;
  bool get isQuizPassed => quizPassedAt != null;
  bool get isCompleted => completedAt != null;

  factory ModuleProgress.fromJson(Map<String, dynamic> json) =>
      ModuleProgress(
        id: json['id'] as String,
        studentId: json['student_id'] as String,
        moduleId: json['module_id'] as String,
        lessonViewedAt: json['lesson_viewed_at'] != null
            ? DateTime.parse(json['lesson_viewed_at'] as String)
            : null,
        quizPassedAt: json['quiz_passed_at'] != null
            ? DateTime.parse(json['quiz_passed_at'] as String)
            : null,
        bestQuizScore: json['best_quiz_score'] as int?,
        completedAt: json['completed_at'] != null
            ? DateTime.parse(json['completed_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'student_id': studentId,
        'module_id': moduleId,
        'lesson_viewed_at': lessonViewedAt?.toIso8601String(),
        'quiz_passed_at': quizPassedAt?.toIso8601String(),
        'best_quiz_score': bestQuizScore,
        'completed_at': completedAt?.toIso8601String(),
      };
}
