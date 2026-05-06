import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app/theme.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/student/providers/dashboard_provider.dart';
import 'course_detail_screen.dart';
import 'settings_screen.dart';

class StudentDashboardScreen extends ConsumerWidget {
  final VoidCallback? onNavigateToCourses;

  const StudentDashboardScreen({super.key, this.onNavigateToCourses});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final studentName = authState.studentProfile?.fullName ?? 'Student';
    final firstName = studentName.split(' ').first;
    final initials = _initialsFor(studentName);
    final dashboardAsync = ref.watch(dashboardDataProvider);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardDataProvider);
          await ref.read(dashboardDataProvider.future);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(firstName: firstName, initials: initials),
              const SizedBox(height: 20),
              dashboardAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (err, _) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text('Could not load your progress.\n$err',
                      style: theme.textTheme.bodyMedium),
                ),
                data: (data) => _DashboardBody(
                  data: data,
                  onContinue: () {
                    final course = data.continueCourse;
                    if (course != null) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CourseDetailScreen(course: course),
                        ),
                      );
                    } else {
                      onNavigateToCourses?.call();
                    }
                  },
                  onAllCourses: () => onNavigateToCourses?.call(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _initialsFor(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'S';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}

class _Header extends StatelessWidget {
  final String firstName;
  final String initials;

  const _Header({required this.firstName, required this.initials});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome back',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: AppPalette.textSoft)),
              const SizedBox(height: 2),
              Text(firstName, style: theme.textTheme.headlineMedium),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          },
          icon: const Icon(Icons.notifications_outlined),
          color: AppPalette.text,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppPalette.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: theme.textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DashboardBody extends StatelessWidget {
  final DashboardData data;
  final VoidCallback onContinue;
  final VoidCallback onAllCourses;

  const _DashboardBody({
    required this.data,
    required this.onContinue,
    required this.onAllCourses,
  });

  @override
  Widget build(BuildContext context) {
    final continueCourse = data.continueCourse;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ContinueHero(
          courseTitle: continueCourse?.title ?? 'No courses yet',
          moduleIndex: data.continueNextModuleIndex,
          completedCount: continueCourse == null
              ? 0
              : data.summaries
                  .firstWhere(
                    (s) => s.course.id == continueCourse.id,
                    orElse: () =>
                        CourseSummary(course: continueCourse, completedCount: 0),
                  )
                  .completedCount,
          totalCount: continueCourse?.moduleCount ?? 0,
          enabled: continueCourse != null,
          onTap: onContinue,
        ),
        const SizedBox(height: 16),
        _StatsRow(
          inProgress: data.coursesInProgress,
          completed: data.modulesCompleted,
          done: data.coursesDone,
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('THIS WEEK', style: AppText.eyebrow(context)),
            InkWell(
              onTap: onAllCourses,
              child: Text(
                'All courses →',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppPalette.primary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (data.summaries.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'No courses are available yet.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppPalette.textSoft,
                  ),
            ),
          ),
        ...List.generate(data.summaries.length, (i) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _CourseRow(
                summary: data.summaries[i],
                accent: i.isEven ? AppPalette.primary : AppPalette.cyan,
              ),
            )),
      ],
    );
  }
}

class _ContinueHero extends StatelessWidget {
  final String courseTitle;
  final int moduleIndex;
  final int completedCount;
  final int totalCount;
  final bool enabled;
  final VoidCallback onTap;

  const _ContinueHero({
    required this.courseTitle,
    required this.moduleIndex,
    required this.completedCount,
    required this.totalCount,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratio = totalCount == 0 ? 0.0 : completedCount / totalCount;

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(AppRadii.card + 4),
      child: Container(
        decoration: BoxDecoration(
          color: AppPalette.ink,
          borderRadius: BorderRadius.circular(AppRadii.card + 4),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              right: -40,
              top: -40,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppPalette.primary.withValues(alpha: 0.55),
                      Colors.transparent,
                    ],
                    stops: const [0, 0.7],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    enabled
                        ? 'CONTINUE · ${courseTitle.toUpperCase()}'
                        : 'CONTINUE',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppPalette.cyan,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    enabled
                        ? 'Module $moduleIndex'
                        : 'Pull to download courses',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontSize: 22,
                      letterSpacing: -0.5,
                    ),
                  ),
                  if (enabled) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: ratio,
                              minHeight: 4,
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.15),
                              valueColor:
                                  const AlwaysStoppedAnimation(AppPalette.cyan),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '$completedCount/$totalCount',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFFCBD5E1),
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: enabled
                          ? AppPalette.primary
                          : AppPalette.primary.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          enabled ? 'Resume →' : 'Open Course',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int inProgress;
  final int completed;
  final int done;

  const _StatsRow({
    required this.inProgress,
    required this.completed,
    required this.done,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            value: '$completed',
            label: 'modules',
            sub: 'completed',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            value: '$inProgress',
            label: 'courses',
            sub: 'in progress',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            value: '$done',
            label: 'done',
            sub: 'finished',
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final String sub;

  const _StatCard({
    required this.value,
    required this.label,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppPalette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: AppPalette.ink,
              fontFeatures: const [FontFeature.tabularFigures()],
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(label,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: AppPalette.text)),
          Text(sub,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: AppPalette.textSoft, fontSize: 10)),
        ],
      ),
    );
  }
}

class _CourseRow extends StatelessWidget {
  final CourseSummary summary;
  final Color accent;
  const _CourseRow({required this.summary, required this.accent});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = summary.course;
    final pct = (summary.ratio * 100).round();
    final statusLabel = summary.isDone
        ? 'completed'
        : summary.isInProgress
            ? 'in progress'
            : 'not started';
    final nextModule = summary.completedCount + 1;
    final subtitle = summary.isDone
        ? 'all modules · $statusLabel'
        : 'Module $nextModule · $statusLabel';

    return Container(
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppPalette.border),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 44,
            decoration: BoxDecoration(
              color: summary.isDone ? Colors.green : accent,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.title, style: theme.textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: AppPalette.textSoft),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$pct%',
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppPalette.text,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
