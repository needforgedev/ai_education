/// Represents a row from the `course_progress` view, used for leaderboard display.
class LeaderboardEntry {
  final String studentId;
  final String courseId;
  final String cohortId;
  final String schoolId;
  final String studentName;
  final int completedModuleCount;
  final int totalModuleCount;
  final double avgQuizScore;
  final int? finalSubmissionScore;
  final double? totalScoreOutOf100;
  final String status;

  const LeaderboardEntry({
    required this.studentId,
    required this.courseId,
    required this.cohortId,
    required this.schoolId,
    required this.studentName,
    required this.completedModuleCount,
    required this.totalModuleCount,
    required this.avgQuizScore,
    this.finalSubmissionScore,
    this.totalScoreOutOf100,
    required this.status,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      LeaderboardEntry(
        studentId: json['student_id'] as String,
        courseId: json['course_id'] as String,
        cohortId: json['cohort_id'] as String,
        schoolId: json['school_id'] as String,
        studentName: json['student_name'] as String,
        completedModuleCount: json['completed_module_count'] as int,
        totalModuleCount: json['total_module_count'] as int,
        avgQuizScore: (json['avg_quiz_score'] as num).toDouble(),
        finalSubmissionScore: json['final_submission_score'] as int?,
        totalScoreOutOf100:
            (json['total_score_out_of_100'] as num?)?.toDouble(),
        status: json['status'] as String,
      );
}
