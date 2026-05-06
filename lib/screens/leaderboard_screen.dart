import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app/theme.dart';
import '../features/auth/providers/auth_provider.dart';
import '../mock/mock_data.dart';

enum _Scope { cohort, school, course, overall }

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  _Scope _scope = _Scope.cohort;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = ref.watch(authProvider);
    final school = auth.schoolName ?? 'Your School';
    final cohort = auth.cohortName ?? 'Cohort';
    final entries = mockLeaderboardEntries(school);
    // Stub current rank — real value comes from course_progress view (Step 10)
    const currentRank = 8;
    const totalEntrants = 124;
    const rankDelta = 3;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Leaderboard',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: AppPalette.textSoft)),
            const SizedBox(height: 2),
            Text(_titleForScope(_scope, cohort, school),
                style: theme.textTheme.displaySmall),
            const SizedBox(height: 18),
            _ScopeChips(
              scope: _scope,
              onChange: (s) => setState(() => _scope = s),
            ),
            const SizedBox(height: 20),
            _YourRankCard(
              rank: currentRank,
              total: totalEntrants,
              delta: rankDelta,
            ),
            const SizedBox(height: 24),
            Text('TOP 3', style: AppText.eyebrow(context)),
            const SizedBox(height: 12),
            if (entries.length >= 3)
              _Top3Row(entries: entries.take(3).toList()),
            const SizedBox(height: 18),
            _RankList(
              entries: entries.skip(3).toList(),
              currentUserName: auth.studentProfile?.fullName,
              currentUserRank: currentRank,
            ),
          ],
        ),
      ),
    );
  }

  String _titleForScope(_Scope scope, String cohort, String school) {
    switch (scope) {
      case _Scope.cohort:
        return cohort;
      case _Scope.school:
        return school;
      case _Scope.course:
        return 'This Course';
      case _Scope.overall:
        return 'Everyone';
    }
  }
}

class _ScopeChips extends StatelessWidget {
  final _Scope scope;
  final ValueChanged<_Scope> onChange;

  const _ScopeChips({required this.scope, required this.onChange});

  @override
  Widget build(BuildContext context) {
    final items = [
      (_Scope.cohort, 'Cohort'),
      (_Scope.school, 'School'),
      (_Scope.course, 'Course'),
      (_Scope.overall, 'Overall'),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            _ScopeChip(
              label: items[i].$2,
              selected: scope == items[i].$1,
              onTap: () => onChange(items[i].$1),
            ),
          ],
        ],
      ),
    );
  }
}

class _ScopeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ScopeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.chip),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppPalette.primary : AppPalette.surface,
          borderRadius: BorderRadius.circular(AppRadii.chip),
          border: Border.all(
            color: selected ? AppPalette.primary : AppPalette.border,
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: selected ? Colors.white : AppPalette.text,
            fontWeight: FontWeight.w500,
            height: 1.2,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _YourRankCard extends StatelessWidget {
  final int? rank;
  final int total;
  final int delta;

  const _YourRankCard({
    required this.rank,
    required this.total,
    required this.delta,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasRank = rank != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppPalette.ink,
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hasRank ? '#$rank' : '—',
            style: theme.textTheme.displayMedium?.copyWith(
              color: Colors.white,
              fontFeatures: const [FontFeature.tabularFigures()],
              fontSize: 40,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'YOUR RANK',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppPalette.cyan,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hasRank
                      ? (delta > 0
                          ? '+$delta places this week'
                          : delta < 0
                              ? '$delta places this week'
                              : 'no change this week')
                      : 'complete a course to rank',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFFCBD5E1),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              hasRank ? 'of $total' : 'of —',
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFFCBD5E1),
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Top3Row extends StatelessWidget {
  final List<LeaderboardEntry> entries;
  const _Top3Row({required this.entries});

  static const _avatarColors = [
    AppPalette.primary,
    AppPalette.cyan,
    Color(0xFFCBD5E1),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(entries.length, (i) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < entries.length - 1 ? 8 : 0),
            child: _Top3Card(
              entry: entries[i],
              avatarColor: _avatarColors[i],
            ),
          ),
        );
      }),
    );
  }
}

class _Top3Card extends StatelessWidget {
  final LeaderboardEntry entry;
  final Color avatarColor;

  const _Top3Card({required this.entry, required this.avatarColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final firstName = entry.studentName.split(' ').first;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppPalette.border),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: avatarColor,
              shape: BoxShape.circle,
            ),
            child: Text(
              _initials(entry.studentName),
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '#${entry.rank}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppPalette.textSoft,
            ),
          ),
          Text(
            firstName,
            style: theme.textTheme.titleSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            entry.score.toStringAsFixed(0),
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppPalette.primary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}

class _RankList extends StatelessWidget {
  final List<LeaderboardEntry> entries;
  final String? currentUserName;
  final int? currentUserRank;

  const _RankList({
    required this.entries,
    required this.currentUserName,
    required this.currentUserRank,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppPalette.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < entries.length; i++) ...[
            _RankRow(
              entry: entries[i],
              isCurrentUser: currentUserName != null &&
                  entries[i].studentName == currentUserName,
            ),
            if (i < entries.length - 1)
              const Divider(height: 1, color: AppPalette.border),
          ],
        ],
      ),
    );
  }
}

class _RankRow extends StatelessWidget {
  final LeaderboardEntry entry;
  final bool isCurrentUser;

  const _RankRow({required this.entry, required this.isCurrentUser});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initials = _initials(entry.studentName);
    final firstAndLast = _firstAndLastInitial(entry.studentName);

    return Container(
      color: isCurrentUser ? AppPalette.primaryWash : null,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              '#${entry.rank}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppPalette.textSoft,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(width: 6),
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isCurrentUser
                  ? AppPalette.primary
                  : const Color(0xFFCBD5E1),
              shape: BoxShape.circle,
            ),
            child: Text(
              initials,
              style: theme.textTheme.labelMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isCurrentUser ? '$firstAndLast (you)' : firstAndLast,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight:
                    isCurrentUser ? FontWeight.w700 : FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            entry.score.toStringAsFixed(0),
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppPalette.text,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  /// "Aarav Patel" → "Aarav P."
  String _firstAndLastInitial(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return name;
    if (parts.length == 1) return parts.first;
    return '${parts.first} ${parts.last.substring(0, 1).toUpperCase()}.';
  }
}
