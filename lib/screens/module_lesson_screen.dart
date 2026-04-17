import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/connectivity/connectivity_provider.dart';
import '../core/sync/learning_sync_provider.dart';
import '../data/models/module.dart';
import '../features/auth/providers/auth_provider.dart';
import 'quiz_screen.dart';

class ModuleLessonScreen extends ConsumerStatefulWidget {
  final CourseModule module;

  const ModuleLessonScreen({super.key, required this.module});

  @override
  ConsumerState<ModuleLessonScreen> createState() => _ModuleLessonScreenState();
}

class _ModuleLessonScreenState extends ConsumerState<ModuleLessonScreen> {
  int _currentPage = 0;
  bool _lessonMarked = false;

  void _maybeMarkLessonViewed() {
    if (_lessonMarked) return;
    final auth = ref.read(authProvider);
    final studentId = auth.studentProfile?.id;
    final online = ref.read(isOnlineProvider);
    if (studentId == null || !online) return;

    _lessonMarked = true;
    final repo = ref.read(moduleRepositoryProvider);
    repo.markLessonViewed(studentId: studentId, moduleId: widget.module.id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = widget.module.contentBlocks;
    final isLast = _currentPage == content.length - 1;

    if (isLast) _maybeMarkLessonViewed();

    return Scaffold(
      appBar: AppBar(
        title: Text('Module ${widget.module.orderIndex}'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_currentPage + 1} / ${content.length}',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentPage + 1) / content.length,
            minHeight: 3,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_currentPage == 0) ...[
                    Text(
                      widget.module.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.flag_outlined,
                              color: theme.colorScheme.primary, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.module.objective,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  Text(
                    content[_currentPage],
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.7),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                if (_currentPage > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _currentPage--),
                      child: const Text('Previous'),
                    ),
                  ),
                if (_currentPage > 0) const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      if (isLast) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => QuizScreen(module: widget.module),
                          ),
                        );
                      } else {
                        setState(() => _currentPage++);
                      }
                    },
                    child: Text(isLast ? 'Take Quiz' : 'Next'),
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
