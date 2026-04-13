class Submission {
  final String id;
  final String studentId;
  final String courseId;
  final String fileUrl;
  final String fileName;
  final String fileType;
  final String notes;
  final DateTime submittedAt;
  final String status; // 'pending' | 'graded'
  final int? scoreOutOf80;
  final String? moderatorId;
  final String? moderatorFeedback;
  final DateTime? gradedAt;

  const Submission({
    required this.id,
    required this.studentId,
    required this.courseId,
    required this.fileUrl,
    required this.fileName,
    required this.fileType,
    required this.notes,
    required this.submittedAt,
    required this.status,
    this.scoreOutOf80,
    this.moderatorId,
    this.moderatorFeedback,
    this.gradedAt,
  });

  bool get isGraded => status == 'graded';

  factory Submission.fromJson(Map<String, dynamic> json) => Submission(
        id: json['id'] as String,
        studentId: json['student_id'] as String,
        courseId: json['course_id'] as String,
        fileUrl: json['file_url'] as String,
        fileName: json['file_name'] as String,
        fileType: json['file_type'] as String,
        notes: (json['notes'] as String?) ?? '',
        submittedAt: DateTime.parse(json['submitted_at'] as String),
        status: json['status'] as String,
        scoreOutOf80: json['score_out_of_80'] as int?,
        moderatorId: json['moderator_id'] as String?,
        moderatorFeedback: json['moderator_feedback'] as String?,
        gradedAt: json['graded_at'] != null
            ? DateTime.parse(json['graded_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'student_id': studentId,
        'course_id': courseId,
        'file_url': fileUrl,
        'file_name': fileName,
        'file_type': fileType,
        'notes': notes,
        'submitted_at': submittedAt.toIso8601String(),
        'status': status,
        'score_out_of_80': scoreOutOf80,
        'moderator_id': moderatorId,
        'moderator_feedback': moderatorFeedback,
        'graded_at': gradedAt?.toIso8601String(),
      };
}
