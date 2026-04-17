import 'package:flutter/material.dart';
import '../data/models/module.dart';
import 'quiz_screen.dart';

class QuizResultScreen extends StatelessWidget {
  final CourseModule module;
  final int score;
  final int totalQuestions;
  final int correctAnswers;
  final bool isNewBest;
  final bool passed;
  final int? previousBest;

  const QuizResultScreen({
    super.key,
    required this.module,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.isNewBest,
    required this.passed,
    this.previousBest,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: passed
                      ? Colors.green.withValues(alpha: 0.12)
                      : Colors.red.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  passed ? Icons.emoji_events : Icons.refresh,
                  size: 52,
                  color: passed ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                passed ? 'Module Passed!' : 'Not Passed',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: passed ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Module ${module.orderIndex}: ${module.title}',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      '$score / 20',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: passed ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$correctAnswers of $totalQuestions correct',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (isNewBest) ...[
                      const SizedBox(height: 8),
                      Text(
                        'New best score!',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ] else if (previousBest != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Best score: $previousBest / 20',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (!passed) ...[
                Text(
                  'You need at least 50% (10/20) to pass.\nRetake the quiz to try again.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.red.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ] else ...[
                Text(
                  'Great job! The next module is unlocked.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const Spacer(flex: 3),
              if (!passed)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => QuizScreen(module: module),
                        ),
                      );
                    },
                    child: const Text('Retake Quiz'),
                  ),
                ),
              if (!passed) const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: passed
                    ? FilledButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Continue'),
                      )
                    : OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Back to Course'),
                      ),
              ),
              if (passed) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => QuizScreen(module: module),
                      ),
                    );
                  },
                  child: const Text('Retake to improve score'),
                ),
              ],
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
