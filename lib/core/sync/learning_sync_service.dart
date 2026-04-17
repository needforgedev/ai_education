import '../cache/learning_cache.dart';
import '../../data/repositories/course_repository.dart';
import '../../data/repositories/module_repository.dart';

/// Downloads all courses + modules for a cohort into the local Hive cache.
/// Called on login/signup and on manual pull-to-refresh.
class LearningSyncService {
  final CourseRepository _courseRepo;
  final ModuleRepository _moduleRepo;
  final LearningCache _cache;

  LearningSyncService({
    required CourseRepository courseRepo,
    required ModuleRepository moduleRepo,
    required LearningCache cache,
  })  : _courseRepo = courseRepo,
        _moduleRepo = moduleRepo,
        _cache = cache;

  /// Pulls courses + all their modules for a cohort into Hive.
  /// Returns the number of modules cached, or null on failure.
  Future<int?> syncCohort(String cohortId) async {
    try {
      final courses = await _courseRepo.fetchRemoteCoursesForCohort(cohortId);
      await _cache.saveCoursesForCohort(cohortId, courses);

      int moduleCount = 0;
      for (final course in courses) {
        final modules = await _moduleRepo.fetchRemoteModulesForCourse(course.id);
        await _cache.saveModulesForCourse(course.id, modules);
        moduleCount += modules.length;
      }

      await _cache.setLastSyncedAt(DateTime.now());
      return moduleCount;
    } catch (_) {
      return null;
    }
  }
}
