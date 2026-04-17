import '../../core/cache/learning_cache.dart';
import '../../core/constants.dart';
import '../../core/supabase/supabase_client.dart';
import '../models/module.dart';
import '../models/module_progress.dart';

/// Module reads: cache-first (lesson content works offline).
/// Progress reads/writes: Supabase only (online required).
class ModuleRepository {
  final LearningCache _cache;

  ModuleRepository(this._cache);

  /// Returns cached modules if present; otherwise fetches + caches.
  Future<List<CourseModule>> getModulesForCourse(String courseId) async {
    final cached = _cache.getModulesForCourse(courseId);
    if (cached != null && cached.isNotEmpty) return cached;

    try {
      final remote = await fetchRemoteModulesForCourse(courseId);
      await _cache.saveModulesForCourse(courseId, remote);
      return remote;
    } catch (_) {
      return const [];
    }
  }

  /// Fetches modules straight from Supabase. Used by sync.
  Future<List<CourseModule>> fetchRemoteModulesForCourse(String courseId) async {
    final result = await supabase
        .from(Tables.modules)
        .select()
        .eq('course_id', courseId)
        .order('order_index');

    return (result as List)
        .map((e) => CourseModule.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Lookup a single cached module by id (offline-friendly).
  CourseModule? getCachedModule(String moduleId) => _cache.getModuleById(moduleId);

  // -------- Progress (online-only) --------

  /// Fetch progress for a single module. Online-only.
  Future<ModuleProgress?> getModuleProgress({
    required String studentId,
    required String moduleId,
  }) async {
    final result = await supabase
        .from(Tables.moduleProgress)
        .select()
        .eq('student_id', studentId)
        .eq('module_id', moduleId)
        .maybeSingle();

    if (result == null) return null;
    return ModuleProgress.fromJson(result);
  }

  /// Fetch all module progress rows for a student across a course.
  /// Online: fetches from Supabase and caches to Hive.
  /// Offline: falls back to the Hive cache so module unlock still works.
  Future<Map<String, ModuleProgress>> getProgressForCourseModules({
    required String studentId,
    required String courseId,
    required List<String> moduleIds,
  }) async {
    if (moduleIds.isEmpty) return {};

    try {
      final result = await supabase
          .from(Tables.moduleProgress)
          .select()
          .eq('student_id', studentId)
          .inFilter('module_id', moduleIds);

      final list = (result as List)
          .map((e) => ModuleProgress.fromJson(e as Map<String, dynamic>))
          .toList();

      await _cache.saveProgressForCourse(
        studentId: studentId,
        courseId: courseId,
        progress: list,
      );

      return {for (final p in list) p.moduleId: p};
    } catch (_) {
      final cached = _cache.getProgressForCourse(
        studentId: studentId,
        courseId: courseId,
      );
      if (cached == null) return {};
      return {for (final p in cached) p.moduleId: p};
    }
  }

  /// Mark a lesson as viewed. Upserts module_progress row. Online-only.
  Future<void> markLessonViewed({
    required String studentId,
    required String moduleId,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await supabase.from(Tables.moduleProgress).upsert(
      {
        'student_id': studentId,
        'module_id': moduleId,
        'lesson_viewed_at': now,
      },
      onConflict: 'student_id,module_id',
      ignoreDuplicates: false,
    );
  }
}
