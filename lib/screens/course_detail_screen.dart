import 'package:flutter/material.dart';
import '../mock/mock_data.dart';
import '../mock/app_state.dart';
import 'module_lesson_screen.dart';
import 'final_submission_screen.dart';

class CourseDetailScreen extends StatefulWidget {
  final MockCourse course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = AppState();
    final modules = mockModules
        .where((m) => m.courseId == widget.course.id)
        .toList()
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    final completedCount = state.completedModuleCount(widget.course.id);
    final allDone = state.allModulesCompleted(widget.course.id);
    final avgScore = state.averageQuizScore(widget.course.id);
    final submission = state.getSubmission(widget.course.id);
    final totalScore = state.totalCourseScore(widget.course.id);

    return Scaffold(
      appBar: AppBar(title: Text(widget.course.title)),
      body: Column(
        children: [
          // Course header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: theme.colorScheme.surfaceContainerHighest,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.course.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: completedCount / 10,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
                const SizedBox(height: 8),
                Text(
                  '$completedCount / 10 modules completed',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _ScoreChip(
                      label: 'Quiz Avg',
                      value: avgScore > 0
                          ? '${avgScore.toStringAsFixed(1)}/20'
                          : '--',
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    _ScoreChip(
                      label: 'Submission',
                      value: submission?.isGraded == true
                          ? '${submission!.scoreOutOf80}/80'
                          : '--',
                      color: theme.colorScheme.tertiary,
                    ),
                    const SizedBox(width: 12),
                    _ScoreChip(
                      label: 'Total',
                      value: totalScore != null
                          ? '${totalScore.toStringAsFixed(1)}/100'
                          : '--',
                      color: theme.colorScheme.secondary,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Module list
          Expanded(
            child: ListView.builder(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              itemCount: modules.length + 1, // +1 for final submission
              itemBuilder: (context, index) {
                if (index == modules.length) {
                  return _buildSubmissionTile(
                      context, theme, allDone, submission);
                }

                final module = modules[index];
                final isCompleted =
                    state.isModuleCompleted(widget.course.id, index);
                final isUnlocked =
                    state.isModuleUnlocked(widget.course.id, index);
                final bestScore =
                    state.getBestScore(widget.course.id, index);

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
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 18)
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
                            : theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.6),
                      ),
                    ),
                    subtitle: bestScore != null
                        ? Text(
                            'Best score: $bestScore/20',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.green,
                            ),
                          )
                        : Text(
                            module.objective,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall,
                          ),
                    trailing: isCompleted
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Done',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        : isUnlocked
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Ready',
                                  style: TextStyle(
                                    color: theme.colorScheme.onPrimary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            : Icon(
                                Icons.lock_outline,
                                size: 18,
                                color: theme.colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.5),
                              ),
                    onTap: isUnlocked
                        ? () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ModuleLessonScreen(
                                  module: module,
                                  moduleIndex: index,
                                ),
                              ),
                            );
                            setState(() {}); // Refresh state on return
                          }
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionTile(BuildContext context, ThemeData theme,
      bool allDone, SubmissionState? submission) {
    final bool canSubmit = allDone && submission == null;
    final bool isSubmitted = submission != null;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Card(
        elevation: 0,
        color: isSubmitted
            ? (submission.isGraded
                ? Colors.green.withValues(alpha: 0.12)
                : theme.colorScheme.tertiaryContainer)
            : canSubmit
                ? theme.colorScheme.tertiaryContainer
                : theme.colorScheme.surfaceContainerLow,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: isSubmitted
                ? (submission.isGraded ? Colors.green : theme.colorScheme.tertiary)
                : canSubmit
                    ? theme.colorScheme.tertiary
                    : theme.colorScheme.surfaceContainerHighest,
            child: Icon(
              isSubmitted
                  ? (submission.isGraded
                      ? Icons.grading
                      : Icons.hourglass_top)
                  : Icons.assignment_outlined,
              color: isSubmitted || canSubmit
                  ? Colors.white
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
          title: Text(
            isSubmitted
                ? (submission.isGraded
                    ? 'Graded: ${submission.scoreOutOf80}/80'
                    : 'Submitted — Awaiting Review')
                : 'Final Submission',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            isSubmitted
                ? (submission.isGraded
                    ? submission.moderatorFeedback ?? 'Graded by moderator'
                    : 'A moderator will review your project')
                : allDone
                    ? '80 marks — ready to submit'
                    : '80 marks — complete all modules first',
          ),
          trailing: canSubmit
              ? const Icon(Icons.chevron_right)
              : null,
          onTap: canSubmit
              ? () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          FinalSubmissionScreen(course: widget.course),
                    ),
                  );
                  setState(() {});
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
          Text(
            label,
            style: TextStyle(fontSize: 10, color: color),
          ),
        ],
      ),
    );
  }
}
