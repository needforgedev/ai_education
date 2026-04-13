class QuizAttempt {
  final String id;
  final String studentId;
  final String moduleId;
  final int scoreOutOf20;
  final List<int> answers;
  final DateTime attemptedAt;

  const QuizAttempt({
    required this.id,
    required this.studentId,
    required this.moduleId,
    required this.scoreOutOf20,
    required this.answers,
    required this.attemptedAt,
  });

  factory QuizAttempt.fromJson(Map<String, dynamic> json) => QuizAttempt(
        id: json['id'] as String,
        studentId: json['student_id'] as String,
        moduleId: json['module_id'] as String,
        scoreOutOf20: json['score_out_of_20'] as int,
        answers: (json['answers'] as List<dynamic>)
            .map((e) => e as int)
            .toList(),
        attemptedAt: DateTime.parse(json['attempted_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'student_id': studentId,
        'module_id': moduleId,
        'score_out_of_20': scoreOutOf20,
        'answers': answers,
        'attempted_at': attemptedAt.toIso8601String(),
      };
}
