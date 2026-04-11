import 'package:flutter/material.dart';
import '../mock/mock_data.dart';
import '../mock/app_state.dart';

class SubmissionReviewScreen extends StatefulWidget {
  final SubmissionState submission;
  final MockCourse course;

  const SubmissionReviewScreen({
    super.key,
    required this.submission,
    required this.course,
  });

  @override
  State<SubmissionReviewScreen> createState() => _SubmissionReviewScreenState();
}

class _SubmissionReviewScreenState extends State<SubmissionReviewScreen> {
  final _understandingController = TextEditingController(text: '15');
  final _accuracyController = TextEditingController(text: '16');
  final _applicationController = TextEditingController(text: '14');
  final _clarityController = TextEditingController(text: '17');
  final _feedbackController = TextEditingController();
  bool _published = false;

  int get _totalScore {
    final u = int.tryParse(_understandingController.text) ?? 0;
    final a = int.tryParse(_accuracyController.text) ?? 0;
    final ap = int.tryParse(_applicationController.text) ?? 0;
    final c = int.tryParse(_clarityController.text) ?? 0;
    return (u + a + ap + c).clamp(0, 80);
  }

  void _publishScore() {
    AppState().gradeSubmission(
      widget.submission.courseId,
      _totalScore,
      _feedbackController.text.isNotEmpty
          ? _feedbackController.text
          : 'Reviewed by moderator.',
    );
    setState(() => _published = true);
  }

  @override
  void dispose() {
    _understandingController.dispose();
    _accuracyController.dispose();
    _applicationController.dispose();
    _clarityController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_published) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle,
                        size: 48, color: Colors.green),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Score Published!',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.submission.studentName} received $_totalScore / 80 for ${widget.course.title}',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Back to Dashboard'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Review Submission')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _InfoRow(label: 'Student', value: widget.submission.studentName),
                  const SizedBox(height: 8),
                  _InfoRow(label: 'Course', value: widget.course.title),
                  const SizedBox(height: 8),
                  _InfoRow(label: 'File', value: widget.submission.fileName),
                  if (widget.submission.notes.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _InfoRow(label: 'Notes', value: widget.submission.notes),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Mock file viewer
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.insert_drive_file,
                      size: 36,
                      color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(height: 8),
                  Text(
                    widget.submission.fileName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '(Mock file preview)',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Rubric scoring
            Text(
              'Rubric (Total: 80)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _RubricField(label: 'Understanding', controller: _understandingController, onChanged: () => setState(() {})),
            _RubricField(label: 'Accuracy', controller: _accuracyController, onChanged: () => setState(() {})),
            _RubricField(label: 'Application', controller: _applicationController, onChanged: () => setState(() {})),
            _RubricField(label: 'Clarity', controller: _clarityController, onChanged: () => setState(() {})),

            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Score',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  Text(
                    '$_totalScore / 80',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Feedback
            TextField(
              controller: _feedbackController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Moderator Feedback (optional)',
                hintText: 'Add feedback for the student...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _publishScore,
                child: const Text('Publish Score'),
              ),
            ),
          ],
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 70,
          child: Text(label,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ),
        Expanded(
          child: Text(value,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

class _RubricField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final VoidCallback onChanged;

  const _RubricField({
    required this.label,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          SizedBox(
            width: 80,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                suffixText: '/ 20',
                isDense: true,
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              ),
              onChanged: (_) => onChanged(),
            ),
          ),
        ],
      ),
    );
  }
}
