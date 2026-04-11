import 'package:flutter/material.dart';
import '../mock/mock_data.dart';
import '../mock/app_state.dart';
import 'course_detail_screen.dart';

class CourseListScreen extends StatelessWidget {
  const CourseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = AppState();

    return SafeArea(
      child: ListenableBuilder(
        listenable: state,
        builder: (context, _) {
          return Column(
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
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: mockCourses.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final course = mockCourses[index];
                    final completed =
                        state.completedModuleCount(course.id);
                    final progress = completed / 10;

                    return Card(
                      elevation: 0,
                      color: completed > 0
                          ? theme.colorScheme.primaryContainer
                              .withValues(alpha: 0.5)
                          : theme.colorScheme.surfaceContainerLow,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  CourseDetailScreen(course: course),
                            ),
                          );
                        },
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
                                      : theme.colorScheme
                                          .surfaceContainerHighest,
                                  borderRadius:
                                      BorderRadius.circular(12),
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
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      course.title,
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      course.description,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                        color: theme.colorScheme
                                            .onSurfaceVariant,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child:
                                              LinearProgressIndicator(
                                            value: progress,
                                            minHeight: 4,
                                            borderRadius:
                                                BorderRadius.circular(
                                                    2),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '$completed/${course.moduleCount}',
                                          style: theme
                                              .textTheme.labelSmall
                                              ?.copyWith(
                                            color: theme.colorScheme
                                                .onSurfaceVariant,
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
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
