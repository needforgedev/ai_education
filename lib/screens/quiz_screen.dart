import 'package:flutter/material.dart';
import '../mock/mock_data.dart';
import '../mock/app_state.dart';
import 'quiz_result_screen.dart';

class QuizScreen extends StatefulWidget {
  final MockModule module;
  final int moduleIndex;

  const QuizScreen({
    super.key,
    required this.module,
    required this.moduleIndex,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestion = 0;
  int? _selectedOption;
  final Map<int, int> _answers = {};

  List<MockQuestion> get _questions => mockQuizzes[widget.moduleIndex];

  void _submitAnswer() {
    if (_selectedOption == null) return;

    _answers[_currentQuestion] = _selectedOption!;

    if (_currentQuestion < _questions.length - 1) {
      setState(() {
        _currentQuestion++;
        _selectedOption = _answers[_currentQuestion];
      });
    } else {
      // Calculate score
      int correct = 0;
      for (final entry in _answers.entries) {
        if (_questions[entry.key].correctIndex == entry.value) {
          correct++;
        }
      }
      final score = (correct / _questions.length * 20).round();

      // Submit to app state — tracks best score
      final isNewBest = AppState().submitQuizScore(
        widget.module.courseId,
        widget.moduleIndex,
        score,
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => QuizResultScreen(
            module: widget.module,
            moduleIndex: widget.moduleIndex,
            score: score,
            totalQuestions: _questions.length,
            correctAnswers: correct,
            isNewBest: isNewBest,
            passed: score >= 10, // 50% = 10/20
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final question = _questions[_currentQuestion];
    final isLast = _currentQuestion == _questions.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz: Module ${widget.module.orderIndex}'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_currentQuestion + 1} / ${_questions.length}',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentQuestion + 1) / _questions.length,
            minHeight: 3,
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
                          onTap: () {
                            setState(() => _selectedOption = index);
                          },
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
                                        : theme.colorScheme
                                            .surfaceContainerHighest,
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
                onPressed: _selectedOption != null ? _submitAnswer : null,
                child: Text(isLast ? 'Submit Quiz' : 'Next Question'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
