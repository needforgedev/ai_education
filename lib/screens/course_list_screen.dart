import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/sync/learning_sync_provider.dart';
import '../data/models/course.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/courses/providers/course_providers.dart';
import 'course_detail_screen.dart';

class CourseListScreen extends ConsumerWidget {
  const CourseListScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    final auth = ref.read(authProvider);
    final cohortId = auth.studentProfile?.cohortId;
    if (cohortId == null) return;
    await ref.read(learningSyncProvider.notifier).syncCohort(cohortId);
    ref.invalidate(coursesForCohortProvider(cohortId));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final coursesAsync = ref.watch(myCoursesProvider);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Text(
              'My Courses',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _refresh(ref),
              child: coursesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => _ErrorState(message: err.toString()),
                data: (courses) {
                  if (courses.isEmpty) return const _EmptyState();
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: courses.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final course = courses[index];
                      return _CourseCard(
                        course: course,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => CourseDetailScreen(course: course),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseCard extends ConsumerWidget {
  final Course course;
  final VoidCallback onTap;

  const _CourseCard({required this.course, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final progressAsync = ref.watch(moduleProgressForCourseProvider(course.id));

    final completed = progressAsync.maybeWhen(
      data: (m) => m.values.where((p) => p.isCompleted).length,
      orElse: () => 0,
    );
    final ratio = course.moduleCount == 0 ? 0.0 : completed / course.moduleCount;

    return Card(
      elevation: 0,
      color: completed > 0
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
          : theme.colorScheme.surfaceContainerLow,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: completed > 0
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  course.icon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      course.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: ratio,
                            minHeight: 4,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$completed/${course.moduleCount}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(40),
      children: [
        const SizedBox(height: 80),
        Icon(Icons.auto_stories_outlined,
            size: 64, color: Theme.of(context).colorScheme.outline),
        const SizedBox(height: 16),
        Text(
          'No courses yet',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          'Pull down to download courses for your grade.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 60),
        const Icon(Icons.error_outline, size: 48),
        const SizedBox(height: 12),
        Text(
          'Could not load courses',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
