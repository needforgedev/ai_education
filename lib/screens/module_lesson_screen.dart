import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app/theme.dart';
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
      backgroundColor: AppPalette.bg,
      appBar: AppBar(
        title: const SizedBox.shrink(),
        backgroundColor: AppPalette.bg,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        flexibleSpace: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(56, 14, 24, 0),
            child: Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: (_currentPage + 1) / content.length,
                      minHeight: 3,
                      backgroundColor: AppPalette.border,
                      valueColor:
                          const AlwaysStoppedAnimation(AppPalette.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${_currentPage + 1}/${content.length}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppPalette.textSoft,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MODULE ${widget.module.orderIndex} · LESSON',
                    style: AppText.eyebrow(context, color: AppPalette.primary),
                  ),
                  const SizedBox(height: 12),
                  if (_currentPage == 0) ...[
                    Text(
                      widget.module.title,
                      style: theme.textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppPalette.primaryWash,
                        borderRadius: BorderRadius.circular(AppRadii.input),
                        border: Border.all(color: AppPalette.primary),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.flag_outlined,
                              color: AppPalette.primary, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('OBJECTIVE',
                                    style: AppText.eyebrow(context,
                                        color: AppPalette.primary)),
                                const SizedBox(height: 2),
                                Text(
                                  widget.module.objective,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppPalette.text,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                  ],
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppPalette.surface,
                      borderRadius: BorderRadius.circular(AppRadii.card),
                      border: Border.all(color: AppPalette.border),
                    ),
                    child: Text(
                      content[_currentPage],
                      style: theme.textTheme.bodyLarge?.copyWith(
                        height: 1.6,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: AppPalette.surface,
              border: Border(
                top: BorderSide(color: AppPalette.border, width: 1),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Row(
              children: [
                if (_currentPage > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _currentPage--),
                      child: const Text('Previous'),
                    ),
                  ),
                if (_currentPage > 0) const SizedBox(width: 10),
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
                    child: Text(isLast ? 'Take Quiz' : 'Next →'),
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
