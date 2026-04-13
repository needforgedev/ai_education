import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/cohort.dart';
import '../../../app/router.dart';

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
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_outline,
                  size: 56,
                  color: theme.colorScheme.tertiary,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Welcome, $studentName!',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _InfoRow(label: 'School', value: school),
                    const SizedBox(height: 12),
                    _InfoRow(label: 'Cohort', value: cohort.name),
                    const SizedBox(height: 12),
                    _InfoRow(label: 'Grade', value: 'Grade $grade'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Courses prepared for your level are ready.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 3),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () => context.go(AppRoutes.home),
                  child: const Text('Go to Dashboard'),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
