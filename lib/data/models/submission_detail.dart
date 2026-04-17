import 'course.dart';
import 'submission.dart';

/// Submission row joined with student + course info for moderator screens.
class SubmissionDetail {
  final Submission submission;
  final String studentName;
  final Course course;

  const SubmissionDetail({
    required this.submission,
    required this.studentName,
    required this.course,
  });

  factory SubmissionDetail.fromJson(Map<String, dynamic> json) {
    final student = json['students'] as Map<String, dynamic>?;
    final course = json['courses'] as Map<String, dynamic>?;
    if (student == null || course == null) {
      throw StateError(
        'SubmissionDetail expects embedded students + courses data',
      );
    }

    // Strip embedded objects before parsing the base submission row.
    final submissionJson = Map<String, dynamic>.from(json)
      ..remove('students')
      ..remove('courses');

    return SubmissionDetail(
      submission: Submission.fromJson(submissionJson),
      studentName: student['full_name'] as String,
      course: Course.fromJson(course),
    );
  }
}
