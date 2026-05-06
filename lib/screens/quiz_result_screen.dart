import 'package:flutter/material.dart';
import '../app/theme.dart';
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
      backgroundColor: AppPalette.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Text(
                'MODULE ${module.orderIndex} · QUIZ RESULT',
                style: AppText.eyebrow(context, color: AppPalette.primary),
              ),
              const SizedBox(height: 10),
              Text(
                passed ? 'Module passed!' : 'Not quite there',
                style: theme.textTheme.displayMedium?.copyWith(fontSize: 36),
              ),
              const SizedBox(height: 6),
              Text(
                module.title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppPalette.textSoft,
                ),
              ),
              const SizedBox(height: 24),
              _ScoreCard(
                score: score,
                correctAnswers: correctAnswers,
                totalQuestions: totalQuestions,
                isNewBest: isNewBest,
                previousBest: previousBest,
                passed: passed,
              ),
              const SizedBox(height: 16),
              Text(
                passed
                    ? 'Great work — the next module is unlocked.'
                    : 'You need 10/20 (50%) to pass. Take another shot.',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: AppPalette.textSoft, height: 1.5),
              ),
              const Spacer(),
              if (!passed) ...[
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => _retake(context),
                    child: const Text('Retake quiz'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Back to course'),
                  ),
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Continue'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _retake(context),
                    child: const Text('Retake to improve'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _retake(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => QuizScreen(module: module),
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final int score;
  final int correctAnswers;
  final int totalQuestions;
  final bool isNewBest;
  final int? previousBest;
  final bool passed;

  const _ScoreCard({
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.isNewBest,
    required this.previousBest,
    required this.passed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = passed ? AppPalette.primary : const Color(0xFFDC2626);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppPalette.ink,
        borderRadius: BorderRadius.circular(AppRadii.card + 4),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -36,
            top: -36,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    accent.withValues(alpha: 0.5),
                    Colors.transparent,
                  ],
                  stops: const [0, 0.7],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'YOUR SCORE',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: passed ? AppPalette.cyan : const Color(0xFFFCA5A5),
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  if (isNewBest)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppPalette.primary,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'NEW BEST',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          letterSpacing: 1.0,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              RichText(
                text: TextSpan(
                  style: theme.textTheme.displayLarge?.copyWith(
                    color: Colors.white,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    fontSize: 56,
                    height: 1.0,
                  ),
                  children: [
                    TextSpan(text: '$score'),
                    TextSpan(
                      text: ' / 20',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: const Color(0xFFCBD5E1),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '$correctAnswers of $totalQuestions correct',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: const Color(0xFFCBD5E1)),
              ),
              if (!isNewBest && previousBest != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Best score: $previousBest / 20',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppPalette.cyan,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
