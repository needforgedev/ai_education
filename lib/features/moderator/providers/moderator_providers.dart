import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/submission_detail.dart';
import '../../../data/repositories/moderator_repository.dart';

final moderatorRepositoryProvider = Provider<ModeratorRepository>((ref) {
  return ModeratorRepository();
});

/// All submissions (pending + graded), newest first.
final allSubmissionsProvider =
    FutureProvider<List<SubmissionDetail>>((ref) async {
  return ref.read(moderatorRepositoryProvider).getAllSubmissions();
});

/// Pending-only queue for the review screen.
final pendingSubmissionsProvider =
    FutureProvider<List<SubmissionDetail>>((ref) async {
  return ref.read(moderatorRepositoryProvider).getPendingSubmissions();
});

/// Open doubts (unanswered, non-moderator threads).
final openDoubtsCountProvider = FutureProvider<int>((ref) async {
  return ref.read(moderatorRepositoryProvider).getOpenDoubtsCount();
});

class ModeratorStats {
  final int pending;
  final int graded;
  final int openDoubts;

  const ModeratorStats({
    required this.pending,
    required this.graded,
    required this.openDoubts,
  });
}

/// Aggregated dashboard stats.
final moderatorStatsProvider = FutureProvider<ModeratorStats>((ref) async {
  final submissions = await ref.watch(allSubmissionsProvider.future);
  final openDoubts = await ref.watch(openDoubtsCountProvider.future);

  int pending = 0;
  int graded = 0;
  for (final s in submissions) {
    if (s.submission.isGraded) {
      graded++;
    } else {
      pending++;
    }
  }
  return ModeratorStats(
    pending: pending,
    graded: graded,
    openDoubts: openDoubts,
  );
});
