import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/connectivity/connectivity_provider.dart';
import '../data/models/module.dart';
import '../data/models/quiz_question.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/courses/providers/course_providers.dart';
import '../features/quizzes/providers/quiz_providers.dart';
import 'quiz_result_screen.dart';

class QuizScreen extends ConsumerWidget {
  final CourseModule module;

  const QuizScreen({super.key, required this.module});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(isOnlineProvider);
    if (!online) {
      return Scaffold(
        appBar: AppBar(title: Text('Quiz: Module ${module.orderIndex}')),
        body: const _OfflineGate(
          title: 'Connect to internet',
          body: 'Quizzes need internet so we can save your score. Reconnect and try again!',
        ),
      );
    }

    final questionsAsync = ref.watch(quizQuestionsProvider(module.id));
    return Scaffold(
      appBar: AppBar(title: Text('Quiz: Module ${module.orderIndex}')),
      body: questionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Could not load quiz: $err',
                textAlign: TextAlign.center),
          ),
        ),
        data: (questions) {
          if (questions.isEmpty) {
            return const Center(child: Text('No quiz questions yet.'));
          }
          return _QuizBody(module: module, questions: questions);
        },
      ),
    );
  }
}

class _QuizBody extends ConsumerStatefulWidget {
  final CourseModule module;
  final List<QuizQuestion> questions;

  const _QuizBody({required this.module, required this.questions});

  @override
  ConsumerState<_QuizBody> createState() => _QuizBodyState();
}

class _QuizBodyState extends ConsumerState<_QuizBody> {
  int _currentQuestion = 0;
  int? _selectedOption;
  final Map<int, int> _answers = {};
  bool _submitting = false;

  Future<void> _onNextOrSubmit() async {
    if (_selectedOption == null) return;
    _answers[_currentQuestion] = _selectedOption!;

    if (_currentQuestion < widget.questions.length - 1) {
      setState(() {
        _currentQuestion++;
        _selectedOption = _answers[_currentQuestion];
      });
      return;
    }

    // Final submission
    final studentId = ref.read(authProvider).studentProfile?.id;
    if (studentId == null) return;

    int correct = 0;
    final answerList = <int>[];
    for (int i = 0; i < widget.questions.length; i++) {
      final answer = _answers[i] ?? -1;
      answerList.add(answer);
      if (widget.questions[i].correctIndex == answer) correct++;
    }
    final score = (correct / widget.questions.length * 20).round();

    setState(() => _submitting = true);
    try {
      final result = await ref.read(quizRepositoryProvider).submitAttempt(
            studentId: studentId,
            moduleId: widget.module.id,
            scoreOutOf20: score,
            answers: answerList,
          );

      // Refresh the course's module progress so the detail screen shows
      // the updated "Done" / unlock state as soon as the user navigates back.
      ref.invalidate(moduleProgressForCourseProvider(widget.module.courseId));

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => QuizResultScreen(
            module: widget.module,
            score: result.score,
            totalQuestions: widget.questions.length,
            correctAnswers: correct,
            isNewBest: result.isNewBest,
            passed: result.passed,
            previousBest: result.previousBest,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not submit: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final question = widget.questions[_currentQuestion];
    final isLast = _currentQuestion == widget.questions.length - 1;

    return Column(
      children: [
        LinearProgressIndicator(
          value: (_currentQuestion + 1) / widget.questions.length,
          minHeight: 3,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${_currentQuestion + 1} / ${widget.questions.length}',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Question ${_currentQuestion + 1}',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  question.question,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                ...List.generate(question.options.length, (index) {
                  final isSelected = _selectedOption == index;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Material(
                      color: isSelected
                          ? theme.colorScheme.primaryContainer
                          : theme.colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => setState(() => _selectedOption = index),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.surfaceContainerHighest,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  String.fromCharCode(65 + index),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: isSelected
                                        ? theme.colorScheme.onPrimary
                                        : theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  question.options[index],
                                  style: theme.textTheme.bodyLarge,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed:
                  (_selectedOption != null && !_submitting) ? _onNextOrSubmit : null,
              child: _submitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(isLast ? 'Submit Quiz' : 'Next Question'),
            ),
          ),
        ),
      ],
    );
  }
}

class _OfflineGate extends StatelessWidget {
  final String title;
  final String body;

  const _OfflineGate({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off, size: 64, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              body,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
