import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app/theme.dart';
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
      backgroundColor: AppPalette.bg,
      appBar: AppBar(
        title: Text(course.title),
        backgroundColor: AppPalette.bg,
      ),
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
          final allDone =
              completedCount == modules.length && modules.isNotEmpty;

          final scores = progressMap.values
              .where((p) => p.bestQuizScore != null)
              .map((p) => p.bestQuizScore!)
              .toList();
          final avgScore = scores.isEmpty
              ? 0.0
              : scores.reduce((a, b) => a + b) / scores.length;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CORE · ${modules.length} modules'.toUpperCase(),
                  style: AppText.eyebrow(context, color: AppPalette.primary),
                ),
                const SizedBox(height: 4),
                Text(course.title, style: Theme.of(context).textTheme.displaySmall),
                const SizedBox(height: 16),
                _ProgressCard(
                  completed: completedCount,
                  total: modules.length,
                  avgScore: avgScore,
                ),
                const SizedBox(height: 24),
                Text('MODULES', style: AppText.eyebrow(context)),
                const SizedBox(height: 12),
                _ModuleList(
                  modules: modules,
                  progressMap: progressMap,
                  onTapModule: (module) async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ModuleLessonScreen(module: module),
                      ),
                    );
                    ref.invalidate(
                        moduleProgressForCourseProvider(course.id));
                  },
                ),
                const SizedBox(height: 20),
                _FinalSubmissionTile(
                  course: course,
                  allModulesDone: allDone,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final int completed;
  final int total;
  final double avgScore;

  const _ProgressCard({
    required this.completed,
    required this.total,
    required this.avgScore,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratio = total == 0 ? 0.0 : completed / total;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppPalette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PROGRESS', style: AppText.eyebrow(context)),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      style: theme.textTheme.displaySmall,
                      children: [
                        TextSpan(text: '$completed'),
                        TextSpan(
                          text: '/$total',
                          style: theme.textTheme.displaySmall?.copyWith(
                            color: AppPalette.textSoft,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('AVG SCORE', style: AppText.eyebrow(context)),
                  const SizedBox(height: 4),
                  Text(
                    avgScore > 0 ? avgScore.toStringAsFixed(0) : '—',
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: AppPalette.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 4,
              backgroundColor: AppPalette.border,
              valueColor:
                  const AlwaysStoppedAnimation(AppPalette.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModuleList extends StatelessWidget {
  final List<CourseModule> modules;
  final Map<String, ModuleProgress> progressMap;
  final void Function(CourseModule module) onTapModule;

  const _ModuleList({
    required this.modules,
    required this.progressMap,
    required this.onTapModule,
  });

  bool _isUnlocked(int index) {
    if (index == 0) return true;
    final prev = modules[index - 1];
    return progressMap[prev.id]?.isQuizPassed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppPalette.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < modules.length; i++) ...[
            _ModuleRow(
              module: modules[i],
              progress: progressMap[modules[i].id],
              unlocked: _isUnlocked(i),
              onTap: () => onTapModule(modules[i]),
            ),
            if (i < modules.length - 1)
              const Divider(height: 1, color: AppPalette.border),
          ],
        ],
      ),
    );
  }
}

enum _ModuleStatus { done, current, locked }

class _ModuleRow extends StatelessWidget {
  final CourseModule module;
  final ModuleProgress? progress;
  final bool unlocked;
  final VoidCallback onTap;

  const _ModuleRow({
    required this.module,
    required this.progress,
    required this.unlocked,
    required this.onTap,
  });

  _ModuleStatus get _status {
    if (progress?.isCompleted ?? false) return _ModuleStatus.done;
    if (unlocked) return _ModuleStatus.current;
    return _ModuleStatus.locked;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = _status;
    final bestScore = progress?.bestQuizScore;

    final circleColor = switch (status) {
      _ModuleStatus.done => AppPalette.primary,
      _ModuleStatus.current => AppPalette.cyan,
      _ModuleStatus.locked => AppPalette.border,
    };

    final circleChild = switch (status) {
      _ModuleStatus.done =>
        const Icon(Icons.check, size: 14, color: Colors.white),
      _ModuleStatus.current => Text(
          '${module.orderIndex}',
          style: theme.textTheme.labelMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      _ModuleStatus.locked =>
        const Icon(Icons.lock_outline, size: 12, color: AppPalette.textSoft),
    };

    return InkWell(
      onTap: status == _ModuleStatus.locked ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: circleColor,
                shape: BoxShape.circle,
              ),
              child: circleChild,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Module ${module.orderIndex}',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: AppPalette.textSoft),
                  ),
                  Text(
                    module.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: status == _ModuleStatus.locked
                          ? AppPalette.textSoft
                          : null,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (status == _ModuleStatus.done && bestScore != null)
              Text(
                '$bestScore/20',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppPalette.primary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            if (status == _ModuleStatus.current)
              Text(
                'NOW',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppPalette.cyan,
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
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

    return InkWell(
      onTap: allModulesDone
          ? () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => FinalSubmissionScreen(course: course),
                ),
              );
            }
          : null,
      borderRadius: BorderRadius.circular(AppRadii.button),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: allModulesDone ? AppPalette.ink : AppPalette.surface,
          borderRadius: BorderRadius.circular(AppRadii.button),
          border: Border.all(
            color: allModulesDone ? AppPalette.ink : AppPalette.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.assignment_outlined,
              color: allModulesDone ? Colors.white : AppPalette.textSoft,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Final project',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: allModulesDone ? Colors.white : AppPalette.text,
                    ),
                  ),
                  Text(
                    allModulesDone
                        ? '80 marks · ready to submit'
                        : 'Unlocks at 100%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: allModulesDone
                          ? Colors.white.withValues(alpha: 0.7)
                          : AppPalette.textSoft,
                    ),
                  ),
                ],
              ),
            ),
            if (allModulesDone)
              const Icon(Icons.arrow_forward, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
