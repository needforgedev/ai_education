import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../cache/learning_cache_provider.dart';
import '../../data/repositories/course_repository.dart';
import '../../data/repositories/module_repository.dart';
import 'learning_sync_service.dart';

final courseRepositoryProvider = Provider<CourseRepository>((ref) {
  return CourseRepository(ref.read(learningCacheProvider));
});

final moduleRepositoryProvider = Provider<ModuleRepository>((ref) {
  return ModuleRepository(ref.read(learningCacheProvider));
});

final learningSyncServiceProvider = Provider<LearningSyncService>((ref) {
  return LearningSyncService(
    courseRepo: ref.read(courseRepositoryProvider),
    moduleRepo: ref.read(moduleRepositoryProvider),
    cache: ref.read(learningCacheProvider),
  );
});

/// Sync status for UI ("Downloading your courses...").
enum SyncStatus { idle, inProgress, success, failure }

class LearningSyncState {
  final SyncStatus status;
  final int modulesCached;
  final String? errorMessage;

  const LearningSyncState({
    this.status = SyncStatus.idle,
    this.modulesCached = 0,
    this.errorMessage,
  });

  bool get inProgress => status == SyncStatus.inProgress;
}

class LearningSyncNotifier extends StateNotifier<LearningSyncState> {
  final LearningSyncService _service;

  LearningSyncNotifier(this._service) : super(const LearningSyncState());

  Future<void> syncCohort(String cohortId) async {
    state = const LearningSyncState(status: SyncStatus.inProgress);
    final count = await _service.syncCohort(cohortId);
    if (count == null) {
      state = const LearningSyncState(
        status: SyncStatus.failure,
        errorMessage: 'Could not download courses. You can try again later.',
      );
    } else {
      state = LearningSyncState(
        status: SyncStatus.success,
        modulesCached: count,
      );
    }
  }

  void reset() => state = const LearningSyncState();
}

final learningSyncProvider =
    StateNotifierProvider<LearningSyncNotifier, LearningSyncState>((ref) {
  return LearningSyncNotifier(ref.read(learningSyncServiceProvider));
});
