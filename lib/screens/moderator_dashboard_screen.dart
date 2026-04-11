import 'package:flutter/material.dart';
import '../mock/mock_data.dart';
import '../mock/app_state.dart';
import 'submission_review_screen.dart';
import 'community_screen.dart';
import 'welcome_screen.dart';

class ModeratorDashboardScreen extends StatefulWidget {
  const ModeratorDashboardScreen({super.key});

  @override
  State<ModeratorDashboardScreen> createState() =>
      _ModeratorDashboardScreenState();
}

class _ModeratorDashboardScreenState extends State<ModeratorDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = AppState();

    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: state,
          builder: (context, _) {
            final pending = state.pendingSubmissions();
            final allSubs = state.allSubmissions();
            final graded = allSubs.where((s) => s.isGraded).length;
            final openDoubts = state.communityPosts
                .where((p) => !p.isModeratorPost && p.replies.isEmpty)
                .length;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: theme.colorScheme.primary,
                        child: Icon(Icons.shield_outlined,
                            color: theme.colorScheme.onPrimary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Moderator Dashboard',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'All Cohorts',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          state.reset();
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (_) => const WelcomeScreen()),
                            (_) => false,
                          );
                        },
                        icon: const Icon(Icons.logout),
                        tooltip: 'Logout',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Stats
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.assignment_outlined,
                          label: 'Pending\nSubmissions',
                          value: '${pending.length}',
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.grading,
                          label: 'Graded',
                          value: '$graded',
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.question_answer_outlined,
                          label: 'Open\nDoubts',
                          value: '$openDoubts',
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Quick actions
                  Text(
                    'Actions',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 0,
                    color: theme.colorScheme.surfaceContainerLow,
                    child: ListTile(
                      leading: Icon(Icons.assignment_outlined,
                          color: Colors.orange),
                      title: const Text('Review Submissions',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('${pending.length} pending'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                const _SubmissionQueueScreen(),
                          ),
                        );
                        setState(() {});
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 0,
                    color: theme.colorScheme.surfaceContainerLow,
                    child: ListTile(
                      leading: Icon(Icons.forum_outlined,
                          color: theme.colorScheme.primary),
                      title: const Text('Open Community',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('$openDoubts unanswered doubts'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => Scaffold(
                              appBar:
                                  AppBar(title: const Text('Community')),
                              body: const CommunityScreen(),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 28),

                  // All submissions
                  if (allSubs.isNotEmpty) ...[
                    Text(
                      'All Submissions',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...allSubs.map((sub) {
                      final course = mockCourses.firstWhere(
                        (c) => c.id == sub.courseId,
                        orElse: () => mockCourses.first,
                      );
                      return Card(
                        elevation: 0,
                        color: sub.isGraded
                            ? Colors.green.withValues(alpha: 0.08)
                            : Colors.orange.withValues(alpha: 0.08),
                        child: ListTile(
                          leading: Icon(
                            sub.isGraded
                                ? Icons.check_circle
                                : Icons.hourglass_top,
                            color: sub.isGraded
                                ? Colors.green
                                : Colors.orange,
                          ),
                          title: Text(sub.studentName),
                          subtitle: Text(
                            '${course.title} — ${sub.isGraded ? "${sub.scoreOutOf80}/80" : "Pending"}',
                          ),
                          trailing: sub.isGraded
                              ? null
                              : const Icon(Icons.chevron_right),
                          onTap: sub.isGraded
                              ? null
                              : () async {
                                  await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          SubmissionReviewScreen(
                                        submission: sub,
                                        course: course,
                                      ),
                                    ),
                                  );
                                  setState(() {});
                                },
                        ),
                      );
                    }),
                  ],

                  if (allSubs.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(Icons.inbox_outlined,
                              size: 48,
                              color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(height: 12),
                          Text(
                            'No submissions yet',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Submissions will appear here when students complete all modules in a course and submit their projects.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubmissionQueueScreen extends StatefulWidget {
  const _SubmissionQueueScreen();

  @override
  State<_SubmissionQueueScreen> createState() =>
      _SubmissionQueueScreenState();
}

class _SubmissionQueueScreenState extends State<_SubmissionQueueScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = AppState();
    final pending = state.pendingSubmissions();

    return Scaffold(
      appBar: AppBar(title: const Text('Pending Submissions')),
      body: pending.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outline,
                      size: 56, color: Colors.green),
                  const SizedBox(height: 12),
                  Text(
                    'All caught up!',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: pending.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final sub = pending[index];
                final course = mockCourses.firstWhere(
                  (c) => c.id == sub.courseId,
                  orElse: () => mockCourses.first,
                );

                return Card(
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainerLow,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange,
                      child: Text(
                        sub.studentName[0],
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    title: Text(sub.studentName),
                    subtitle: Text(
                        '${course.title} • ${sub.fileName}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => SubmissionReviewScreen(
                            submission: sub,
                            course: course,
                          ),
                        ),
                      );
                      setState(() {});
                    },
                  ),
                );
              },
            ),
    );
  }
}
