import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../app/router.dart';
import '../core/connectivity/connectivity_provider.dart';
import '../core/connectivity/offline_gate.dart';
import '../data/models/submission_detail.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/moderator/providers/moderator_providers.dart';
import 'change_password_screen.dart';
import 'moderator_community_screen.dart';
import 'submission_review_screen.dart';

class ModeratorDashboardScreen extends ConsumerWidget {
  const ModeratorDashboardScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(allSubmissionsProvider);
    ref.invalidate(openDoubtsCountProvider);
    ref.invalidate(moderatorStatsProvider);
    await ref.read(moderatorStatsProvider.future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final online = ref.watch(isOnlineProvider);

    if (!online) {
      return Scaffold(
        appBar: AppBar(title: const Text('Moderator Dashboard')),
        body: const OfflineGate(
          body: 'The moderator dashboard needs internet. Reconnect to review submissions and reply to doubts.',
        ),
      );
    }

    final statsAsync = ref.watch(moderatorStatsProvider);
    final submissionsAsync = ref.watch(allSubmissionsProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _refresh(ref),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(onLogout: () async {
                  await ref.read(authProvider.notifier).signOut();
                  if (!context.mounted) return;
                  context.go(AppRoutes.welcome);
                }),
                const SizedBox(height: 24),

                // Stats
                statsAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (err, _) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text('Could not load stats: $err',
                        style: theme.textTheme.bodyMedium),
                  ),
                  data: (stats) => Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.assignment_outlined,
                          label: 'Pending\nSubmissions',
                          value: '${stats.pending}',
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.grading,
                          label: 'Graded',
                          value: '${stats.graded}',
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.question_answer_outlined,
                          label: 'Open\nDoubts',
                          value: '${stats.openDoubts}',
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Quick actions
                Text(
                  'Actions',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Card(
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainerLow,
                  child: ListTile(
                    leading: const Icon(Icons.assignment_outlined,
                        color: Colors.orange),
                    title: const Text('Review Submissions',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: statsAsync.maybeWhen(
                      data: (s) => Text('${s.pending} pending'),
                      orElse: () => const Text('—'),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const _SubmissionQueueScreen(),
                        ),
                      );
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
                    subtitle: statsAsync.maybeWhen(
                      data: (s) => Text('${s.openDoubts} unanswered doubts'),
                      orElse: () => const Text('—'),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ModeratorCommunityScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 28),

                Text(
                  'All Submissions',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                submissionsAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (err, _) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text('Could not load submissions: $err',
                        style: theme.textTheme.bodyMedium),
                  ),
                  data: (subs) {
                    if (subs.isEmpty) return const _EmptySubmissions();
                    return Column(
                      children: subs
                          .map((s) => _SubmissionTile(detail: s))
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final Future<void> Function() onLogout;

  const _Header({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
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
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
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
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ChangePasswordScreen(),
              ),
            );
          },
          icon: const Icon(Icons.settings_outlined),
          tooltip: 'Change Password',
        ),
        IconButton(
          onPressed: onLogout,
          icon: const Icon(Icons.logout),
          tooltip: 'Logout',
        ),
      ],
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

class _SubmissionTile extends ConsumerWidget {
  final SubmissionDetail detail;
  const _SubmissionTile({required this.detail});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sub = detail.submission;
    final isGraded = sub.isGraded;

    return Card(
      elevation: 0,
      color: isGraded
          ? Colors.green.withValues(alpha: 0.08)
          : Colors.orange.withValues(alpha: 0.08),
      child: ListTile(
        leading: Icon(
          isGraded ? Icons.check_circle : Icons.hourglass_top,
          color: isGraded ? Colors.green : Colors.orange,
        ),
        title: Text(detail.studentName),
        subtitle: Text(
          '${detail.course.title} — ${isGraded ? "${sub.scoreOutOf80}/80" : "Pending"}',
        ),
        trailing: isGraded ? null : const Icon(Icons.chevron_right),
        onTap: isGraded
            ? null
            : () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SubmissionReviewScreen(detail: detail),
                  ),
                );
                ref.invalidate(allSubmissionsProvider);
                ref.invalidate(moderatorStatsProvider);
              },
      ),
    );
  }
}

class _EmptySubmissions extends StatelessWidget {
  const _EmptySubmissions();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined,
              size: 48, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(
            'No submissions yet',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Submissions will appear here when students complete a course and submit their projects.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubmissionQueueScreen extends ConsumerWidget {
  const _SubmissionQueueScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final pendingAsync = ref.watch(pendingSubmissionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pending Submissions')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(pendingSubmissionsProvider);
          await ref.read(pendingSubmissionsProvider.future);
        },
        child: pendingAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err')),
          data: (pending) {
            if (pending.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_outline,
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
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: pending.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final detail = pending[index];
                final sub = detail.submission;
                return Card(
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainerLow,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange,
                      child: Text(
                        detail.studentName.isNotEmpty
                            ? detail.studentName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    title: Text(detail.studentName),
                    subtitle:
                        Text('${detail.course.title} • ${sub.fileName}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              SubmissionReviewScreen(detail: detail),
                        ),
                      );
                      ref.invalidate(pendingSubmissionsProvider);
                      ref.invalidate(allSubmissionsProvider);
                      ref.invalidate(moderatorStatsProvider);
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
