import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/achievement.dart';
import '../../../data/models/quiz_attempt.dart';
import '../../../data/models/submission.dart';
import '../../auth/providers/auth_provider.dart';
import '../../community/providers/community_provider.dart';
import '../../quizzes/providers/quiz_providers.dart';
import '../../submissions/providers/submission_providers.dart';
import 'dashboard_provider.dart';

class _Signals {
  final int modulesCompleted;
  final int coursesCompleted;
  final int streakDays;
  final List<QuizAttempt> attempts;
  final List<Submission> submissions;
  final int communityThreadCount;
  final int communityRepliedThreads;
  final int communityActiveDays;

  _Signals({
    required this.modulesCompleted,
    required this.coursesCompleted,
    required this.streakDays,
    required this.attempts,
    required this.submissions,
    required this.communityThreadCount,
    required this.communityRepliedThreads,
    required this.communityActiveDays,
  });
}

/// Public provider — list of 20 achievements with their earned status.
final achievementsProvider =
    FutureProvider<List<Achievement>>((ref) async {
  final auth = ref.watch(authProvider);
  final studentId = auth.studentProfile?.id;
  if (studentId == null) return _evaluate(_emptySignals());

  // Pull all signals in parallel.
  final dashboardF = ref.watch(dashboardDataProvider.future);
  final attemptsF =
      ref.read(quizRepositoryProvider).getAllAttemptsForStudent(studentId);
  final submissionsF = ref
      .read(submissionRepositoryProvider)
      .getAllSubmissionsForStudent(studentId);
  final communityF =
      ref.read(communityRepositoryProvider).getAuthorActivity(studentId);

  final results = await Future.wait([
    dashboardF,
    attemptsF,
    submissionsF,
    communityF,
  ]);

  final dashboard = results[0] as DashboardData;
  final attempts = results[1] as List<QuizAttempt>;
  final submissions = results[2] as List<Submission>;
  final community = results[3] as ({
    int threadCount,
    int distinctRepliedThreads,
    Set<String> activeDays,
  });

  final signals = _Signals(
    modulesCompleted: dashboard.modulesCompleted,
    coursesCompleted: dashboard.coursesDone,
    streakDays: dashboard.streakDays,
    attempts: attempts,
    submissions: submissions,
    communityThreadCount: community.threadCount,
    communityRepliedThreads: community.distinctRepliedThreads,
    communityActiveDays: community.activeDays.length,
  );

  return _evaluate(signals);
});

_Signals _emptySignals() => _Signals(
      modulesCompleted: 0,
      coursesCompleted: 0,
      streakDays: 0,
      attempts: const [],
      submissions: const [],
      communityThreadCount: 0,
      communityRepliedThreads: 0,
      communityActiveDays: 0,
    );

List<Achievement> _evaluate(_Signals s) {
  // Per-module attempt history (oldest → newest), keyed by module_id.
  final byModule = <String, List<QuizAttempt>>{};
  for (final a in s.attempts) {
    byModule.putIfAbsent(a.moduleId, () => []).add(a);
  }
  for (final list in byModule.values) {
    list.sort((a, b) => a.attemptedAt.compareTo(b.attemptedAt));
  }

  final perfectQuizCount =
      s.attempts.where((a) => a.scoreOutOf20 == 20).length;

  final perfectModuleCount = byModule.entries
      .where((e) => e.value.any((a) => a.scoreOutOf20 == 20))
      .length;

  final firstTryPassCount = byModule.values
      .where((list) => list.first.scoreOutOf20 >= 10)
      .length;

  final retakeImprovedCount = byModule.values.where((list) {
    if (list.length < 2) return false;
    final first = list.first.scoreOutOf20;
    return list.skip(1).any((a) => a.scoreOutOf20 > first);
  }).length;

  final passCount = s.attempts.where((a) => a.scoreOutOf20 >= 10).length;

  final weekendQuiz = s.attempts.any((a) {
    final wd = a.attemptedAt.weekday;
    return wd == DateTime.saturday || wd == DateTime.sunday;
  });

  final today = DateTime.now();
  bool isToday(DateTime d) =>
      d.year == today.year && d.month == today.month && d.day == today.day;
  final quizToday = s.attempts.any((a) => isToday(a.attemptedAt.toLocal()));

  final hasSubmission = s.submissions.isNotEmpty;
  final highSubmission = s.submissions.any((sub) =>
      sub.scoreOutOf80 != null && sub.scoreOutOf80! >= 70);
  final perfectSubmission = s.submissions.any((sub) =>
      sub.scoreOutOf80 != null && sub.scoreOutOf80! >= 80);

  return [
    Achievement(
      id: 'first_steps',
      emoji: '🎯',
      title: 'First steps',
      description: 'Complete your first module.',
      earned: s.modulesCompleted >= 1,
    ),
    Achievement(
      id: 'sharpshooter',
      emoji: '🏹',
      title: 'Sharpshooter',
      description: 'Score a perfect 20/20 on any module quiz.',
      earned: perfectQuizCount >= 1,
    ),
    Achievement(
      id: 'hot_streak',
      emoji: '🔥',
      title: 'Hot streak',
      description: 'Pass 3 module quizzes on the first try.',
      earned: firstTryPassCount >= 3,
    ),
    Achievement(
      id: 'no_mistakes',
      emoji: '💯',
      title: 'No mistakes',
      description: 'Score 20/20 on 5 different module quizzes.',
      earned: perfectModuleCount >= 5,
    ),
    Achievement(
      id: 'comeback_kid',
      emoji: '🔁',
      title: 'Comeback kid',
      description: 'Improve your score on a quiz retake.',
      earned: retakeImprovedCount >= 1,
    ),
    Achievement(
      id: 'quick_thinker',
      emoji: '⚡',
      title: 'Quick thinker',
      description: 'Pass 5 module quizzes total.',
      earned: passCount >= 5,
    ),
    Achievement(
      id: 'knowledge_tower',
      emoji: '🗼',
      title: 'Knowledge tower',
      description: 'Complete 10 modules across any courses.',
      earned: s.modulesCompleted >= 10,
    ),
    Achievement(
      id: 'course_master',
      emoji: '🎓',
      title: 'Course master',
      description: 'Complete every module in any course.',
      earned: s.coursesCompleted >= 1,
    ),
    Achievement(
      id: 'triple_threat',
      emoji: '🥉',
      title: 'Triple threat',
      description: 'Complete 3 different courses.',
      earned: s.coursesCompleted >= 3,
    ),
    Achievement(
      id: 'day_one',
      emoji: '🌅',
      title: 'Day one',
      description: 'Take a quiz today.',
      earned: quizToday,
    ),
    Achievement(
      id: 'three_day',
      emoji: '⏳',
      title: '3-day streak',
      description: 'Take a quiz 3 days in a row.',
      earned: s.streakDays >= 3,
    ),
    Achievement(
      id: 'seven_day',
      emoji: '📅',
      title: '7-day streak',
      description: 'Take a quiz 7 days in a row.',
      earned: s.streakDays >= 7,
    ),
    Achievement(
      id: 'monthly_grinder',
      emoji: '🗓️',
      title: 'Monthly grinder',
      description: 'Take a quiz 30 days in a row.',
      earned: s.streakDays >= 30,
    ),
    Achievement(
      id: 'weekend_warrior',
      emoji: '🛌',
      title: 'Weekend warrior',
      description: 'Take a quiz on a Saturday or Sunday.',
      earned: weekendQuiz,
    ),
    Achievement(
      id: 'shipped_it',
      emoji: '🚀',
      title: 'Shipped it',
      description: 'Submit your first final project.',
      earned: hasSubmission,
    ),
    Achievement(
      id: 'top_marks',
      emoji: '🏆',
      title: 'Top marks',
      description: 'Score 70/80 or higher on a final submission.',
      earned: highSubmission,
    ),
    Achievement(
      id: 'perfectionist',
      emoji: '💎',
      title: 'Perfectionist',
      description: 'Score a perfect 80/80 on a final submission.',
      earned: perfectSubmission,
    ),
    Achievement(
      id: 'asker',
      emoji: '💬',
      title: 'Asked & answered',
      description: 'Post your first thread in the community.',
      earned: s.communityThreadCount >= 1,
    ),
    Achievement(
      id: 'helper',
      emoji: '🤝',
      title: 'Helper',
      description: 'Reply on 5 different community threads.',
      earned: s.communityRepliedThreads >= 5,
    ),
    Achievement(
      id: 'conversationalist',
      emoji: '✍️',
      title: 'Conversationalist',
      description: 'Post or reply in the community on 5 different days.',
      earned: s.communityActiveDays >= 5,
    ),
  ];
}
