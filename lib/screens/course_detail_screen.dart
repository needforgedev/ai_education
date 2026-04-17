import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/course.dart';
import '../data/models/module.dart';
import '../data/models/module_progress.dart';
import '../features/courses/providers/course_providers.dart';
import 'module_lesson_screen.dart';
import 'final_submission_screen.dart';

class CourseDetailScreen extends ConsumerWidget {
  final Course course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modulesAsync = ref.watch(modulesForCourseProvider(course.id));
    final progressAsync = ref.watch(moduleProgressForCourseProvider(course.id));

    return Scaffold(
      appBar: AppBar(title: Text(course.title)),
      body: modulesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (modules) {
          final progressMap = progressAsync.maybeWhen(
            data: (m) => m,
            orElse: () => const <String, ModuleProgress>{},
          );

          final completedCount =
              progressMap.values.where((p) => p.isCompleted).length;
          final allDone = completedCount == modules.length && modules.isNotEmpty;

          final scores = progressMap.values
              .where((p) => p.bestQuizScore != null)
              .map((p) => p.bestQuizScore!)
              .toList();
          final avgScore = scores.isEmpty
              ? 0.0
              : scores.reduce((a, b) => a + b) / scores.length;

          return Column(
            children: [
              _CourseHeader(
                course: course,
                moduleCount: modules.length,
                completedCount: completedCount,
                avgScore: avgScore,
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  itemCount: modules.length + 1,
                  itemBuilder: (context, index) {
                    if (index == modules.length) {
                      return _FinalSubmissionTile(
                        course: course,
                        allModulesDone: allDone,
                      );
                    }

                    final module = modules[index];
                    final progress = progressMap[module.id];
                    final isCompleted = progress?.isCompleted ?? false;
                    final bestScore = progress?.bestQuizScore;
                    final isUnlocked = _isModuleUnlocked(index, modules, progressMap);

                    return _ModuleTile(
                      module: module,
                      isCompleted: isCompleted,
                      isUnlocked: isUnlocked,
                      bestScore: bestScore,
                      onTap: isUnlocked
                          ? () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ModuleLessonScreen(module: module),
                                ),
                              );
                              // Progress is invalidated from inside quiz_screen
                              // after a successful submission, so the UI updates
                              // when the user returns here.
                            }
                          : null,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  bool _isModuleUnlocked(
    int index,
    List<CourseModule> modules,
    Map<String, ModuleProgress> progressMap,
  ) {
    if (index == 0) return true;
    final prev = modules[index - 1];
    return progressMap[prev.id]?.isQuizPassed ?? false;
  }
}

class _CourseHeader extends StatelessWidget {
  final Course course;
  final int moduleCount;
  final int completedCount;
  final double avgScore;

  const _CourseHeader({
    required this.course,
    required this.moduleCount,
    required this.completedCount,
    required this.avgScore,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratio = moduleCount == 0 ? 0.0 : completedCount / moduleCount;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: theme.colorScheme.surfaceContainerHighest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            course.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: ratio,
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 8),
          Text(
            '$completedCount / $moduleCount modules completed',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _ScoreChip(
                label: 'Quiz Avg',
                value: avgScore > 0 ? '${avgScore.toStringAsFixed(1)}/20' : '--',
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              _ScoreChip(
                label: 'Submission',
                value: '/80',
                color: theme.colorScheme.tertiary,
              ),
              const SizedBox(width: 12),
              _ScoreChip(
                label: 'Total',
                value: '/100',
                color: theme.colorScheme.secondary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModuleTile extends StatelessWidget {
  final CourseModule module;
  final bool isCompleted;
  final bool isUnlocked;
  final int? bestScore;
  final VoidCallback? onTap;

  const _ModuleTile({
    required this.module,
    required this.isCompleted,
    required this.isUnlocked,
    required this.bestScore,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: isCompleted
              ? Colors.green
              : isUnlocked
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surfaceContainerHighest,
          child: isCompleted
              ? const Icon(Icons.check, color: Colors.white, size: 18)
              : Text(
                  '${module.orderIndex}',
                  style: TextStyle(
                    color: isUnlocked
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
        ),
        title: Text(
          module.title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isUnlocked
                ? null
                : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
        ),
        subtitle: bestScore != null
            ? Text(
                'Best score: $bestScore/20',
                style:
                    theme.textTheme.bodySmall?.copyWith(color: Colors.green),
              )
            : Text(
                module.objective,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
        trailing: isCompleted
            ? _StatusBadge(label: 'Done', color: Colors.green)
            : isUnlocked
                ? _StatusBadge(
                    label: 'Ready',
                    color: theme.colorScheme.primary,
                  )
                : Icon(
                    Icons.lock_outline,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.5),
                  ),
        onTap: onTap,
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _FinalSubmissionTile extends StatelessWidget {
  final Course course;
  final bool allModulesDone;

  const _FinalSubmissionTile({
    required this.course,
    required this.allModulesDone,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Card(
        elevation: 0,
        color: allModulesDone
            ? theme.colorScheme.tertiaryContainer
            : theme.colorScheme.surfaceContainerLow,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: allModulesDone
                ? theme.colorScheme.tertiary
                : theme.colorScheme.surfaceContainerHighest,
            child: Icon(
              Icons.assignment_outlined,
              color: allModulesDone
                  ? Colors.white
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
          title: const Text(
            'Final Submission',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            allModulesDone
                ? '80 marks — ready to submit'
                : '80 marks — complete all modules first',
          ),
          trailing:
              allModulesDone ? const Icon(Icons.chevron_right) : null,
          onTap: allModulesDone
              ? () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => FinalSubmissionScreen(course: course),
                    ),
                  );
                }
              : null,
        ),
      ),
    );
  }
}

class _ScoreChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ScoreChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 14,
            ),
          ),
          Text(label, style: TextStyle(fontSize: 10, color: color)),
        ],
      ),
    );
  }
}
