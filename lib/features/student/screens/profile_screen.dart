import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme.dart';
import '../../../screens/settings_screen.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final dashboardAsync = ref.watch(dashboardDataProvider);

    final profile = auth.studentProfile;
    final name = profile?.fullName ?? 'Student';
    final initials = _initialsFor(name);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SettingsScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.settings_outlined),
                color: AppPalette.text,
              ),
            ),
            _ProfileHeader(
              initials: initials,
              name: name,
              grade: profile?.grade,
              school: auth.schoolName,
              cohort: auth.cohortName,
            ),
            const SizedBox(height: 18),
            dashboardAsync.maybeWhen(
              data: (d) => _StatsRow(
                modules: d.modulesCompleted,
                courses: d.totalCourses,
                avg: d.averageQuizScore,
                streak: d.streakDays,
              ),
              orElse: () => const _StatsRow(
                modules: 0,
                courses: 0,
                avg: 0,
                streak: 0,
              ),
            ),
            const SizedBox(height: 24),
            Text('ACHIEVEMENTS', style: AppText.eyebrow(context)),
            const SizedBox(height: 12),
            const _AchievementsGrid(),
            const SizedBox(height: 24),
            Text('ACTIVITY · 30D', style: AppText.eyebrow(context)),
            const SizedBox(height: 12),
            _ActivityChart(
              activityByDay: dashboardAsync.maybeWhen(
                data: (d) => d.activityByDay,
                orElse: () => const <String, int>{},
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _initialsFor(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'S';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}

class _ProfileHeader extends StatelessWidget {
  final String initials;
  final String name;
  final int? grade;
  final String? school;
  final String? cohort;

  const _ProfileHeader({
    required this.initials,
    required this.name,
    required this.grade,
    required this.school,
    required this.cohort,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gradeAndSchool = [
      if (grade != null) 'Grade $grade',
      if (school != null && school!.isNotEmpty) school,
    ].whereType<String>().join(' · ');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 76,
          height: 76,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppPalette.primary,
            borderRadius: BorderRadius.circular(38),
          ),
          child: Text(
            initials,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: theme.textTheme.headlineMedium),
              if (gradeAndSchool.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  gradeAndSchool,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: AppPalette.textSoft),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (cohort != null && cohort!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  cohort!.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppPalette.primary,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int modules;
  final int courses;
  final double avg;
  final int streak;

  const _StatsRow({
    required this.modules,
    required this.courses,
    required this.avg,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _StatTile(value: '$modules', label: 'modules')),
        const SizedBox(width: 8),
        Expanded(child: _StatTile(value: '$courses', label: 'courses')),
        const SizedBox(width: 8),
        Expanded(
          child: _StatTile(
            value: avg > 0 ? avg.toStringAsFixed(avg < 10 ? 1 : 0) : '—',
            label: 'avg',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatTile(
            value: streak > 0 ? '${streak}d' : '0d',
            label: 'streak',
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String value;
  final String label;

  const _StatTile({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(AppRadii.input),
        border: Border.all(color: AppPalette.border),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: AppPalette.ink,
              fontFeatures: const [FontFeature.tabularFigures()],
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppPalette.textSoft,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementsGrid extends StatelessWidget {
  const _AchievementsGrid();

  static const _items = [
    _Achievement(emoji: '🎯', label: 'Sharpshooter', earned: true),
    _Achievement(emoji: '🔥', label: '7-day', earned: true),
    _Achievement(emoji: '🚀', label: 'Fast start', earned: true),
    _Achievement(emoji: '🧠', label: 'Top 10%', earned: true),
    _Achievement(emoji: '💬', label: 'Helper', earned: true),
    _Achievement(emoji: '✍️', label: 'Note taker', earned: true),
    _Achievement(emoji: '🏁', label: 'First course', earned: true),
    _Achievement(emoji: '🔒', label: 'Locked', earned: false),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 8.0;
        final cellWidth = (constraints.maxWidth - spacing * 3) / 4;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: _items
              .map((a) => SizedBox(
                    width: cellWidth,
                    height: 92,
                    child: _AchievementTile(achievement: a),
                  ))
              .toList(),
        );
      },
    );
  }
}

class _Achievement {
  final String emoji;
  final String label;
  final bool earned;

  const _Achievement({
    required this.emoji,
    required this.label,
    required this.earned,
  });
}

class _AchievementTile extends StatelessWidget {
  final _Achievement achievement;

  const _AchievementTile({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final earned = achievement.earned;

    return Container(
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(AppRadii.input),
        border: Border.all(color: AppPalette.border),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Opacity(
            opacity: earned ? 1.0 : 0.35,
            child: Text(
              achievement.emoji,
              style: const TextStyle(fontSize: 22, height: 1.0),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            achievement.label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: earned ? AppPalette.text : AppPalette.textSoft,
              fontWeight: FontWeight.w500,
              fontSize: 11,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityChart extends StatelessWidget {
  final Map<String, int> activityByDay;

  const _ActivityChart({required this.activityByDay});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();
    final values = List<int>.generate(30, (i) {
      final day = today.subtract(Duration(days: 29 - i));
      return activityByDay[_dayKey(day)] ?? 0;
    });
    final maxCount = values.fold<int>(0, (a, b) => b > a ? b : a);
    final hasAny = maxCount > 0;

    return Container(
      height: 120,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppPalette.border),
      ),
      child: !hasAny
          ? Center(
              child: Text(
                'Take a quiz to start your activity log.',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: AppPalette.textSoft),
              ),
            )
          : LayoutBuilder(
              builder: (context, c) {
                const gap = 4.0;
                final barWidth =
                    (c.maxWidth - gap * (values.length - 1)) / values.length;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(values.length, (i) {
                    final count = values[i];
                    // Min height so empty days still show as a tiny tick.
                    final ratio = count == 0
                        ? 0.05
                        : (0.25 + 0.75 * (count / maxCount));
                    final color =
                        i.isEven ? AppPalette.primary : AppPalette.cyan;
                    final faded = count == 0;
                    return Padding(
                      padding: EdgeInsets.only(
                          right: i == values.length - 1 ? 0 : gap),
                      child: Container(
                        width: barWidth,
                        height: c.maxHeight * ratio,
                        decoration: BoxDecoration(
                          color: color.withValues(
                              alpha: faded ? 0.18 : 0.55 + 0.45 * (count / maxCount)),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
    );
  }

  String _dayKey(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
