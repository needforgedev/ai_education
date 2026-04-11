import 'package:flutter/material.dart';
import '../mock/mock_data.dart';
import '../mock/app_state.dart';
import 'quiz_screen.dart';

class ModuleLessonScreen extends StatefulWidget {
  final MockModule module;
  final int moduleIndex;

  const ModuleLessonScreen({
    super.key,
    required this.module,
    required this.moduleIndex,
  });

  @override
  State<ModuleLessonScreen> createState() => _ModuleLessonScreenState();
}

class _ModuleLessonScreenState extends State<ModuleLessonScreen> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = widget.module.lessonContent;
    final isLast = _currentPage == content.length - 1;
    final bestScore = AppState().getBestScore(
        widget.module.courseId, widget.moduleIndex);

    return Scaffold(
      appBar: AppBar(
        title: Text('Module ${widget.module.orderIndex}'),
        actions: [
          if (bestScore != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text('Best: $bestScore/20',
                    style: const TextStyle(fontSize: 11)),
                backgroundColor:
                    Colors.green.withValues(alpha: 0.15),
                side: BorderSide.none,
                visualDensity: VisualDensity.compact,
              ),
            ),
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
                              color: theme.colorScheme.primary,
                              size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.module.objective,
                              style:
                                  theme.textTheme.bodyMedium?.copyWith(
                                color: theme
                                    .colorScheme.onPrimaryContainer,
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
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.7,
                    ),
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
                      onPressed: () {
                        setState(() => _currentPage--);
                      },
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
                            builder: (_) => QuizScreen(
                              module: widget.module,
                              moduleIndex: widget.moduleIndex,
                            ),
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
