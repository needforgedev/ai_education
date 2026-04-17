import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/sync/learning_sync_provider.dart';
import '../../../data/models/course.dart';
import '../../../data/models/module.dart';
import '../../../data/models/module_progress.dart';
import '../../auth/providers/auth_provider.dart';

/// Courses for a cohort (cache-first, Supabase fallback).
final coursesForCohortProvider =
    FutureProvider.family<List<Course>, String>((ref, cohortId) async {
  final repo = ref.read(courseRepositoryProvider);
  return repo.getCoursesForCohort(cohortId);
});

/// Courses for the currently logged-in student's cohort.
final myCoursesProvider = FutureProvider<List<Course>>((ref) async {
  final auth = ref.watch(authProvider);
  final profile = auth.studentProfile;
  if (profile == null) return const [];
  return ref.watch(coursesForCohortProvider(profile.cohortId).future);
});

/// Modules for a course (cache-first).
final modulesForCourseProvider =
    FutureProvider.family<List<CourseModule>, String>((ref, courseId) async {
  final repo = ref.read(moduleRepositoryProvider);
  return repo.getModulesForCourse(courseId);
});

/// Module progress for the current student, keyed by moduleId.
/// Cache-aware: online fetches hit Supabase + write cache; offline reads fall back to cache.
final moduleProgressForCourseProvider = FutureProvider.family<
    Map<String, ModuleProgress>, String>((ref, courseId) async {
  final auth = ref.watch(authProvider);
  final profile = auth.studentProfile;
  if (profile == null) return {};

  final modules = await ref.watch(modulesForCourseProvider(courseId).future);
  if (modules.isEmpty) return {};

  final repo = ref.read(moduleRepositoryProvider);
  return repo.getProgressForCourseModules(
    studentId: profile.id,
    courseId: courseId,
    moduleIds: modules.map((m) => m.id).toList(),
  );
});
