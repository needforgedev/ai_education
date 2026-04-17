import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/course.dart';
import '../../courses/providers/course_providers.dart';

class CourseSummary {
  final Course course;
  final int completedCount;

  const CourseSummary({
    required this.course,
    required this.completedCount,
  });

  bool get isInProgress =>
      completedCount > 0 && completedCount < course.moduleCount;
  bool get isDone =>
      course.moduleCount > 0 && completedCount >= course.moduleCount;
  double get ratio =>
      course.moduleCount == 0 ? 0 : completedCount / course.moduleCount;
}

class DashboardData {
  final List<CourseSummary> summaries;
  final int coursesInProgress;
  final int modulesCompleted;
  final int coursesDone;
  final Course? continueCourse;
  final int continueNextModuleIndex; // 1-based

  const DashboardData({
    required this.summaries,
    required this.coursesInProgress,
    required this.modulesCompleted,
    required this.coursesDone,
    this.continueCourse,
    this.continueNextModuleIndex = 1,
  });
}

/// Aggregates course progress across the student's cohort for the dashboard.
final dashboardDataProvider = FutureProvider<DashboardData>((ref) async {
  final courses = await ref.watch(myCoursesProvider.future);

  final summaries = <CourseSummary>[];
  int totalCompleted = 0;
  int inProgress = 0;
  int done = 0;
  Course? continueCourse;
  int continueIndex = 1;

  for (final course in courses) {
    final progress =
        await ref.watch(moduleProgressForCourseProvider(course.id).future);
    final completed = progress.values.where((p) => p.isCompleted).length;

    final summary = CourseSummary(course: course, completedCount: completed);
    summaries.add(summary);

    totalCompleted += completed;
    if (summary.isDone) {
      done++;
    } else if (summary.isInProgress) {
      inProgress++;
      continueCourse ??= course;
      if (continueCourse == course) continueIndex = completed + 1;
    }
  }

  // If no in-progress course, point to the first course's first module.
  if (continueCourse == null && courses.isNotEmpty) {
    continueCourse = courses.first;
    continueIndex = 1;
  }

  return DashboardData(
    summaries: summaries,
    coursesInProgress: inProgress,
    modulesCompleted: totalCompleted,
    coursesDone: done,
    continueCourse: continueCourse,
    continueNextModuleIndex: continueIndex,
  );
});
