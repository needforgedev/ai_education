import '../../core/supabase/supabase_client.dart';
import '../models/leaderboard_rank.dart';

enum LeaderboardScope { cohort, school, course, overall }

extension on LeaderboardScope {
  String get rpcValue => switch (this) {
        LeaderboardScope.cohort => 'cohort',
        LeaderboardScope.school => 'school',
        LeaderboardScope.course => 'course',
        LeaderboardScope.overall => 'overall',
      };
}

class LeaderboardResult {
  final List<LeaderboardRank> entries;
  final LeaderboardRank? currentUserEntry;

  const LeaderboardResult({
    required this.entries,
    this.currentUserEntry,
  });

  int get totalEntrants => entries.length;
}

/// Talks to the `get_leaderboard` SQL function (sql/07_leaderboard.sql).
class LeaderboardRepository {
  Future<LeaderboardResult> getLeaderboard({
    required LeaderboardScope scope,
    required String currentStudentId,
    String? cohortId,
    String? schoolId,
    String? courseId,
  }) async {
    final result = await supabase.rpc('get_leaderboard', params: {
      'p_scope': scope.rpcValue,
      'p_cohort_id': cohortId,
      'p_school_id': schoolId,
      'p_course_id': courseId,
    });

    final entries = (result as List)
        .map((row) =>
            LeaderboardRank.fromJson(row as Map<String, dynamic>))
        .toList();

    LeaderboardRank? currentUserEntry;
    for (final e in entries) {
      if (e.studentId == currentStudentId) {
        currentUserEntry = e;
        break;
      }
    }

    return LeaderboardResult(
      entries: entries,
      currentUserEntry: currentUserEntry,
    );
  }
}
