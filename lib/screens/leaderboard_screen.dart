import 'package:flutter/material.dart';
import '../mock/mock_data.dart';
import '../mock/app_state.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  String _filter = 'overall'; // overall, course-specific id

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = AppState();
    final entries = state.getLeaderboard(
      courseId: _filter == 'overall' ? null : _filter,
    );

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Leaderboard',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${state.school ?? "Your School"} — ${state.cohort?.name ?? ""}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),

                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'Overall',
                        isSelected: _filter == 'overall',
                        onTap: () => setState(() => _filter = 'overall'),
                      ),
                      ...mockCourses.map((course) => _FilterChip(
                            label: course.title,
                            isSelected: _filter == course.id,
                            onTap: () =>
                                setState(() => _filter = course.id),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Top 3 podium
          if (entries.length >= 3)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _PodiumCard(
                    entry: entries[1],
                    height: 90,
                    color: Colors.grey.shade400,
                    medal: '2nd',
                  ),
                  const SizedBox(width: 8),
                  _PodiumCard(
                    entry: entries[0],
                    height: 110,
                    color: Colors.amber,
                    medal: '1st',
                  ),
                  const SizedBox(width: 8),
                  _PodiumCard(
                    entry: entries[2],
                    height: 75,
                    color: Colors.brown.shade300,
                    medal: '3rd',
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),

          // Full list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                final isCurrentUser =
                    entry.studentName == state.studentName;

                return Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    color: isCurrentUser
                        ? theme.colorScheme.primaryContainer
                        : null,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: index < 3
                          ? [Colors.amber, Colors.grey.shade400, Colors.brown.shade300][index]
                          : theme.colorScheme.surfaceContainerHighest,
                      child: Text(
                        '${entry.rank}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: index < 3
                              ? Colors.white
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    title: Text(
                      entry.studentName +
                          (isCurrentUser ? ' (You)' : ''),
                      style: TextStyle(
                        fontWeight: isCurrentUser
                            ? FontWeight.bold
                            : FontWeight.w500,
                      ),
                    ),
                    trailing: Text(
                      entry.score.toStringAsFixed(0),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Your rank banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: theme.colorScheme.primaryContainer,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Your Rank: --',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '(complete courses to rank)',
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
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onSelected: (_) => onTap(),
        showCheckmark: false,
        selectedColor: theme.colorScheme.primaryContainer,
      ),
    );
  }
}

class _PodiumCard extends StatelessWidget {
  final LeaderboardEntry entry;
  final double height;
  final Color color;
  final String medal;

  const _PodiumCard({
    required this.entry,
    required this.height,
    required this.color,
    required this.medal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: color,
          child: Text(
            entry.studentName[0],
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          entry.studentName.split(' ').first,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          entry.score.toStringAsFixed(0),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.3),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(8),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            medal,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
