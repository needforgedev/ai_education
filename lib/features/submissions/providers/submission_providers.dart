import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/submission.dart';
import '../../../data/repositories/submission_repository.dart';
import '../../auth/providers/auth_provider.dart';

final submissionRepositoryProvider = Provider<SubmissionRepository>((ref) {
  return SubmissionRepository();
});

/// Fetch existing submission for current student + course (online).
final submissionForCourseProvider =
    FutureProvider.family<Submission?, String>((ref, courseId) async {
  final studentId = ref.watch(authProvider).studentProfile?.id;
  if (studentId == null) return null;
  final repo = ref.read(submissionRepositoryProvider);
  return repo.getSubmission(studentId: studentId, courseId: courseId);
});
