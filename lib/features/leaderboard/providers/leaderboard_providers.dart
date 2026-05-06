import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/leaderboard_repository.dart';
import '../../auth/providers/auth_provider.dart';
import '../../courses/providers/course_providers.dart';

final leaderboardRepositoryProvider =
    Provider<LeaderboardRepository>((ref) => LeaderboardRepository());

class LeaderboardQuery {
  final LeaderboardScope scope;
  final String? courseId;

  const LeaderboardQuery({required this.scope, this.courseId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LeaderboardQuery &&
          scope == other.scope &&
          courseId == other.courseId);

  @override
  int get hashCode => Object.hash(scope, courseId);
}

/// Fetches a ranked leaderboard for the given scope. The cohortId/schoolId
/// args are filled from the current student's profile automatically.
final leaderboardProvider = FutureProvider.family<LeaderboardResult,
    LeaderboardQuery>((ref, query) async {
  final auth = ref.watch(authProvider);
  final profile = auth.studentProfile;
  if (profile == null) {
    return const LeaderboardResult(entries: []);
  }

  // For "course" scope, fall back to the first course in the student's
  // cohort if no specific courseId was passed in.
  String? resolvedCourseId = query.courseId;
  if (query.scope == LeaderboardScope.course && resolvedCourseId == null) {
    final courses = await ref.watch(myCoursesProvider.future);
    if (courses.isEmpty) {
      return const LeaderboardResult(entries: []);
    }
    resolvedCourseId = courses.first.id;
  }

  final repo = ref.read(leaderboardRepositoryProvider);
  return repo.getLeaderboard(
    scope: query.scope,
    currentStudentId: profile.id,
    cohortId: profile.cohortId,
    schoolId: profile.schoolId,
    courseId: resolvedCourseId,
  );
});
