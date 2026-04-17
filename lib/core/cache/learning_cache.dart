import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/course.dart';
import '../../data/models/module.dart';
import '../../data/models/module_progress.dart';

/// Local cache for learning content (courses + modules + progress).
/// Course / module reads are cache-first; writes happen on sync only.
/// Progress reads fall back to cache when offline so module unlock works.
class LearningCache {
  static const String _coursesBoxName = 'courses_by_cohort';
  static const String _modulesBoxName = 'modules_by_course';
  static const String _progressBoxName = 'module_progress_by_student_course';
  static const String _metaBoxName = 'learning_meta';
  static const String _lastSyncedKey = 'last_synced_at';
  static const String _schemaVersionKey = 'schema_version';

  // Bump when the cached data shape or ordering changes so stale caches
  // are flushed on next launch. v2 = fixed descending .order() bug that stored
  // modules in reverse order.
  static const int _currentSchemaVersion = 2;

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<dynamic>(_coursesBoxName);
    await Hive.openBox<dynamic>(_modulesBoxName);
    await Hive.openBox<dynamic>(_progressBoxName);
    final meta = await Hive.openBox<dynamic>(_metaBoxName);

    final storedVersion = meta.get(_schemaVersionKey) as int?;
    if (storedVersion != _currentSchemaVersion) {
      await Hive.box<dynamic>(_coursesBoxName).clear();
      await Hive.box<dynamic>(_modulesBoxName).clear();
      await Hive.box<dynamic>(_progressBoxName).clear();
      await meta.put(_schemaVersionKey, _currentSchemaVersion);
    }
  }

  Box<dynamic> get _coursesBox => Hive.box<dynamic>(_coursesBoxName);
  Box<dynamic> get _modulesBox => Hive.box<dynamic>(_modulesBoxName);
  Box<dynamic> get _progressBox => Hive.box<dynamic>(_progressBoxName);
  Box<dynamic> get _metaBox => Hive.box<dynamic>(_metaBoxName);

  String _progressKey(String studentId, String courseId) =>
      '$studentId:$courseId';

  Future<void> saveCoursesForCohort(String cohortId, List<Course> courses) async {
    final payload = courses.map((c) => c.toJson()).toList();
    await _coursesBox.put(cohortId, payload);
  }

  List<Course>? getCoursesForCohort(String cohortId) {
    final raw = _coursesBox.get(cohortId);
    if (raw == null) return null;
    final list = (raw as List).cast<dynamic>();
    return list
        .map((e) => Course.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> saveModulesForCourse(String courseId, List<CourseModule> modules) async {
    final payload = modules.map((m) => m.toJson()).toList();
    await _modulesBox.put(courseId, payload);
  }

  List<CourseModule>? getModulesForCourse(String courseId) {
    final raw = _modulesBox.get(courseId);
    if (raw == null) return null;
    final list = (raw as List).cast<dynamic>();
    return list
        .map((e) => CourseModule.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  CourseModule? getModuleById(String moduleId) {
    for (final key in _modulesBox.keys) {
      final raw = _modulesBox.get(key);
      if (raw == null) continue;
      final list = (raw as List).cast<dynamic>();
      for (final e in list) {
        final json = Map<String, dynamic>.from(e as Map);
        if (json['id'] == moduleId) return CourseModule.fromJson(json);
      }
    }
    return null;
  }

  Future<void> saveProgressForCourse({
    required String studentId,
    required String courseId,
    required List<ModuleProgress> progress,
  }) async {
    final payload = progress.map((p) => p.toJson()).toList();
    await _progressBox.put(_progressKey(studentId, courseId), payload);
  }

  List<ModuleProgress>? getProgressForCourse({
    required String studentId,
    required String courseId,
  }) {
    final raw = _progressBox.get(_progressKey(studentId, courseId));
    if (raw == null) return null;
    final list = (raw as List).cast<dynamic>();
    return list
        .map((e) => ModuleProgress.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> setLastSyncedAt(DateTime timestamp) async {
    await _metaBox.put(_lastSyncedKey, timestamp.toIso8601String());
  }

  DateTime? getLastSyncedAt() {
    final raw = _metaBox.get(_lastSyncedKey);
    if (raw == null) return null;
    return DateTime.tryParse(raw as String);
  }

  bool hasCoursesForCohort(String cohortId) => _coursesBox.containsKey(cohortId);

  Future<void> clear() async {
    await _coursesBox.clear();
    await _modulesBox.clear();
    await _progressBox.clear();
    await _metaBox.clear();
  }
}
