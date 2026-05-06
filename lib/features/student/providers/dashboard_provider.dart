import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/course.dart';
import '../../auth/providers/auth_provider.dart';
import '../../courses/providers/course_providers.dart';
import '../../quizzes/providers/quiz_providers.dart';

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
  final int totalCourses;
  final double averageQuizScore; // 0..20, 0 means no quiz attempts yet
  final int streakDays;
  final Map<String, int> activityByDay; // 'YYYY-MM-DD' → attempt count
  final Course? continueCourse;
  final int continueNextModuleIndex; // 1-based

  const DashboardData({
    required this.summaries,
    required this.coursesInProgress,
    required this.modulesCompleted,
    required this.coursesDone,
    required this.totalCourses,
    required this.averageQuizScore,
    required this.streakDays,
    required this.activityByDay,
    this.continueCourse,
    this.continueNextModuleIndex = 1,
  });
}

/// Aggregates course progress, quiz averages, and activity for the dashboard
/// and profile. Pulls only from existing tables — no schema changes.
final dashboardDataProvider = FutureProvider<DashboardData>((ref) async {
  final auth = ref.watch(authProvider);
  final courses = await ref.watch(myCoursesProvider.future);

  final summaries = <CourseSummary>[];
  int totalCompleted = 0;
  int inProgress = 0;
  int done = 0;
  Course? continueCourse;
  int continueIndex = 1;

  // Average across every module that has a best_quiz_score.
  int scoreSum = 0;
  int scoreCount = 0;

  for (final course in courses) {
    final progress =
        await ref.watch(moduleProgressForCourseProvider(course.id).future);
    final completed = progress.values.where((p) => p.isCompleted).length;

    summaries.add(CourseSummary(course: course, completedCount: completed));
    totalCompleted += completed;

    for (final p in progress.values) {
      if (p.bestQuizScore != null) {
        scoreSum += p.bestQuizScore!;
        scoreCount++;
      }
    }

    if (course.moduleCount > 0 && completed >= course.moduleCount) {
      done++;
    } else if (completed > 0) {
      inProgress++;
      continueCourse ??= course;
      if (continueCourse == course) continueIndex = completed + 1;
    }
  }

  if (continueCourse == null && courses.isNotEmpty) {
    continueCourse = courses.first;
    continueIndex = 1;
  }

  // Streak + activity from quiz_attempts dates.
  final studentId = auth.studentProfile?.id;
  int streak = 0;
  final activityByDay = <String, int>{};
  if (studentId != null) {
    try {
      final dates = await ref
          .read(quizRepositoryProvider)
          .getQuizAttemptDates(studentId);
      for (final dt in dates) {
        final key = _dayKey(dt);
        activityByDay[key] = (activityByDay[key] ?? 0) + 1;
      }
      streak = _computeStreak(activityByDay);
    } catch (_) {
      // Offline or RLS hiccup: leave streak/activity empty.
    }
  }

  return DashboardData(
    summaries: summaries,
    coursesInProgress: inProgress,
    modulesCompleted: totalCompleted,
    coursesDone: done,
    totalCourses: summaries.length,
    averageQuizScore: scoreCount == 0 ? 0 : scoreSum / scoreCount,
    streakDays: streak,
    activityByDay: activityByDay,
    continueCourse: continueCourse,
    continueNextModuleIndex: continueIndex,
  );
});

String _dayKey(DateTime dt) {
  final y = dt.year.toString().padLeft(4, '0');
  final m = dt.month.toString().padLeft(2, '0');
  final d = dt.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

int _computeStreak(Map<String, int> activityByDay) {
  if (activityByDay.isEmpty) return 0;
  final today = DateTime.now();
  final todayKey = _dayKey(today);
  final yesterdayKey = _dayKey(today.subtract(const Duration(days: 1)));

  // Streak counts from today if there's activity today, otherwise from
  // yesterday — so a student doesn't lose their streak just because it's
  // morning and they haven't started yet.
  DateTime cursor;
  if (activityByDay.containsKey(todayKey)) {
    cursor = DateTime(today.year, today.month, today.day);
  } else if (activityByDay.containsKey(yesterdayKey)) {
    cursor = DateTime(today.year, today.month, today.day)
        .subtract(const Duration(days: 1));
  } else {
    return 0;
  }

  int streak = 0;
  while (activityByDay.containsKey(_dayKey(cursor))) {
    streak++;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return streak;
}
