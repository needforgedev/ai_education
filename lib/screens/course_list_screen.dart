import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app/theme.dart';
import '../core/sync/learning_sync_provider.dart';
import '../data/models/course.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/courses/providers/course_providers.dart';
import 'course_detail_screen.dart';

class CourseListScreen extends ConsumerStatefulWidget {
  const CourseListScreen({super.key});

  @override
  ConsumerState<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends ConsumerState<CourseListScreen> {
  String _filter = 'All';
  static const _filters = ['All', 'In progress', 'Completed', 'Not started'];

  Future<void> _refresh(WidgetRef ref) async {
    final auth = ref.read(authProvider);
    final cohortId = auth.studentProfile?.cohortId;
    if (cohortId == null) return;
    await ref.read(learningSyncProvider.notifier).syncCohort(cohortId);
    ref.invalidate(coursesForCohortProvider(cohortId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final coursesAsync = ref.watch(myCoursesProvider);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Library',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: AppPalette.textSoft)),
                Text('Courses', style: theme.textTheme.displaySmall),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 14, 0, 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(right: 24),
              child: Row(
                children: [
                  for (var i = 0; i < _filters.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    _FilterChip(
                      label: _filters[i],
                      selected: _filter == _filters[i],
                      onTap: () => setState(() => _filter = _filters[i]),
                    ),
                  ],
                ],
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
                    padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
                    itemCount: courses.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final course = courses[index];
                      return _CourseCard(
                        course: course,
                        accent: _accentForIndex(index),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  CourseDetailScreen(course: course),
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

  Color _accentForIndex(int i) {
    const palette = [
      AppPalette.primary,
      AppPalette.cyan,
      AppPalette.ink,
      AppPalette.primaryDeep,
    ];
    return palette[i % palette.length];
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.chip),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppPalette.ink : AppPalette.surface,
          borderRadius: BorderRadius.circular(AppRadii.chip),
          border: Border.all(
            color: selected ? AppPalette.ink : AppPalette.border,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : AppPalette.text,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

class _CourseCard extends ConsumerWidget {
  final Course course;
  final Color accent;
  final VoidCallback onTap;

  const _CourseCard({
    required this.course,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final progressAsync = ref.watch(moduleProgressForCourseProvider(course.id));

    final completed = progressAsync.maybeWhen(
      data: (m) => m.values.where((p) => p.isCompleted).length,
      orElse: () => 0,
    );
    final ratio = course.moduleCount == 0 ? 0.0 : completed / course.moduleCount;
    final status = completed == 0
        ? 'Not started'
        : completed >= course.moduleCount
            ? 'Completed'
            : 'In progress';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: Container(
        decoration: BoxDecoration(
          color: AppPalette.surface,
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: AppPalette.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 96,
              padding: const EdgeInsets.all(16),
              color: accent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        course.icon,
                        style: const TextStyle(fontSize: 22),
                      ),
                      Text(
                        '${course.moduleCount} MODULES',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                          letterSpacing: 1.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    course.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontSize: 22,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: ratio,
                        minHeight: 4,
                        backgroundColor: AppPalette.border,
                        valueColor: AlwaysStoppedAnimation(accent),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    status,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppPalette.textSoft,
                      fontWeight: FontWeight.w500,
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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(40),
      children: [
        const SizedBox(height: 80),
        Icon(Icons.auto_stories_outlined,
            size: 64, color: AppPalette.textSoft),
        const SizedBox(height: 16),
        Text(
          'No courses yet',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          'Pull down to download courses for your grade.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall,
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
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 60),
        const Icon(Icons.error_outline, size: 48),
        const SizedBox(height: 12),
        Text(
          'Could not load courses',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          message,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}
