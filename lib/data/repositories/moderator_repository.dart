import 'dart:convert';
import '../../core/constants.dart';
import '../../core/supabase/supabase_client.dart';
import '../models/submission.dart';
import '../models/submission_detail.dart';

/// Moderator-only queries: submissions queue, grading, community stats.
/// All online-only.
class ModeratorRepository {
  /// All submissions with student + course context, newest first.
  Future<List<SubmissionDetail>> getAllSubmissions() async {
    final result = await supabase
        .from(Tables.finalSubmissions)
        .select('*, students(full_name), courses(*)')
        .order('submitted_at', ascending: false);

    return (result as List)
        .map((e) => SubmissionDetail.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Pending (ungraded) submissions only.
  Future<List<SubmissionDetail>> getPendingSubmissions() async {
    final result = await supabase
        .from(Tables.finalSubmissions)
        .select('*, students(full_name), courses(*)')
        .eq('status', 'pending')
        .order('submitted_at', ascending: true);

    return (result as List)
        .map((e) => SubmissionDetail.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Count of unanswered, non-moderator community threads.
  Future<int> getOpenDoubtsCount() async {
    final result = await supabase
        .from(Tables.communityThreads)
        .select('id, community_replies(id)')
        .eq('is_moderator_post', false)
        .eq('is_hidden', false);

    int count = 0;
    for (final row in (result as List)) {
      final replies = (row as Map<String, dynamic>)['community_replies'] as List?;
      if (replies == null || replies.isEmpty) count++;
    }
    return count;
  }

  /// Grade a submission: updates score + feedback + moderator + status + graded_at,
  /// then writes a submission_graded notification for the student.
  Future<Submission> gradeSubmission({
    required String submissionId,
    required String moderatorId,
    required String studentUserId,
    required String courseId,
    required String courseTitle,
    required int scoreOutOf80,
    String? feedback,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();

    final updated = await supabase
        .from(Tables.finalSubmissions)
        .update({
          'status': 'graded',
          'score_out_of_80': scoreOutOf80,
          'moderator_id': moderatorId,
          'moderator_feedback': feedback?.isNotEmpty == true ? feedback : null,
          'graded_at': now,
        })
        .eq('id', submissionId)
        .select()
        .single();

    await supabase.from(Tables.notifications).insert({
      'user_id': studentUserId,
      'type': 'submission_graded',
      'title': 'Your submission was graded',
      'body': '$courseTitle — $scoreOutOf80/80',
      'data': jsonEncode({
        'submission_id': submissionId,
        'course_id': courseId,
        'score_out_of_80': scoreOutOf80,
      }),
    });

    return Submission.fromJson(updated);
  }
}
