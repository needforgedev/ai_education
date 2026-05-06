import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router.dart';
import '../../../app/theme.dart';
import '../../../data/models/cohort.dart';

class CohortConfirmationScreen extends StatelessWidget {
  final String studentName;
  final int grade;
  final String school;
  final Cohort cohort;

  const CohortConfirmationScreen({
    super.key,
    required this.studentName,
    required this.grade,
    required this.school,
    required this.cohort,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 60, 28, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'COHORT ASSIGNED',
                style: AppText.eyebrow(context, color: AppPalette.primary),
              ),
              const SizedBox(height: 8),
              Text(
                "You're in\n${cohort.name}",
                style: theme.textTheme.displayMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'Grade $grade · $school',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppPalette.textSoft,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppPalette.ink,
                  borderRadius: BorderRadius.circular(AppRadii.card + 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "WHAT'S AHEAD",
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppPalette.cyan,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _CountRow(value: '5', label: 'AI courses'),
                    const SizedBox(height: 12),
                    _CountRow(value: '50', label: 'modules total'),
                    const SizedBox(height: 12),
                    _CountRow(value: '5', label: 'final projects'),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => context.go(AppRoutes.onboarding),
                  child: const Text('Get started'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountRow extends StatelessWidget {
  final String value;
  final String label;

  const _CountRow({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        SizedBox(
          width: 64,
          child: Text(
            value,
            style: theme.textTheme.headlineLarge?.copyWith(
              color: Colors.white,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: const Color(0xFFCBD5E1),
          ),
        ),
      ],
    );
  }
}
