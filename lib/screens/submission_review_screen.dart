import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/connectivity/connectivity_provider.dart';
import '../core/connectivity/offline_gate.dart';
import '../data/models/submission_detail.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/moderator/providers/moderator_providers.dart';
import '../features/submissions/screens/submission_file_viewer_screen.dart';

class SubmissionReviewScreen extends ConsumerStatefulWidget {
  final SubmissionDetail detail;

  const SubmissionReviewScreen({super.key, required this.detail});

  @override
  ConsumerState<SubmissionReviewScreen> createState() =>
      _SubmissionReviewScreenState();
}

class _SubmissionReviewScreenState
    extends ConsumerState<SubmissionReviewScreen> {
  final _understandingController = TextEditingController();
  final _accuracyController = TextEditingController();
  final _applicationController = TextEditingController();
  final _clarityController = TextEditingController();
  final _feedbackController = TextEditingController();
  bool _submitting = false;
  bool _published = false;
  int _publishedScore = 0;

  void _openFile() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SubmissionFileViewerScreen(
          submission: widget.detail.submission,
        ),
      ),
    );
  }

  String? _validateRubricField(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    final n = int.tryParse(value);
    if (n == null) return 'Must be a number';
    if (n < 0 || n > 20) return '0–20';
    return null;
  }

  bool get _rubricComplete {
    for (final c in [
      _understandingController,
      _accuracyController,
      _applicationController,
      _clarityController,
    ]) {
      if (_validateRubricField(c.text) != null) return false;
    }
    return true;
  }

  int get _totalScore {
    final u = int.tryParse(_understandingController.text) ?? 0;
    final a = int.tryParse(_accuracyController.text) ?? 0;
    final ap = int.tryParse(_applicationController.text) ?? 0;
    final c = int.tryParse(_clarityController.text) ?? 0;
    return (u + a + ap + c).clamp(0, 80);
  }

  Future<void> _publishScore() async {
    final moderatorId = ref.read(authProvider).user?.id;
    if (moderatorId == null) return;

    setState(() => _submitting = true);
    try {
      await ref.read(moderatorRepositoryProvider).gradeSubmission(
            submissionId: widget.detail.submission.id,
            moderatorId: moderatorId,
            studentUserId: widget.detail.submission.studentId,
            courseId: widget.detail.course.id,
            courseTitle: widget.detail.course.title,
            scoreOutOf80: _totalScore,
            feedback: _feedbackController.text.trim(),
          );
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _published = true;
        _publishedScore = _totalScore;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not publish: $e')),
      );
    }
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
    final online = ref.watch(isOnlineProvider);

    if (!online) {
      return Scaffold(
        appBar: AppBar(title: const Text('Review Submission')),
        body: const OfflineGate(
          body: 'Grading needs internet so the student gets their score. Reconnect and try again.',
        ),
      );
    }

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
                    '${widget.detail.studentName} received $_publishedScore / 80 for ${widget.detail.course.title}',
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

    final submission = widget.detail.submission;
    return Scaffold(
      appBar: AppBar(title: const Text('Review Submission')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _InfoRow(label: 'Student', value: widget.detail.studentName),
                  const SizedBox(height: 8),
                  _InfoRow(label: 'Course', value: widget.detail.course.title),
                  const SizedBox(height: 8),
                  _InfoRow(label: 'File', value: submission.fileName),
                  if (submission.notes.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _InfoRow(label: 'Notes', value: submission.notes),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(Icons.insert_drive_file,
                      size: 36,
                      color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(height: 8),
                  Text(
                    submission.fileName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonalIcon(
                      onPressed: _openFile,
                      icon: const Icon(Icons.description_outlined, size: 18),
                      label: const Text('Open submission file'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Rubric (Total: 80)',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'Grade each category out of 20.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            _RubricField(
              label: 'Understanding',
              controller: _understandingController,
              onChanged: () => setState(() {}),
              errorText: _validateRubricField(_understandingController.text),
            ),
            _RubricField(
              label: 'Accuracy',
              controller: _accuracyController,
              onChanged: () => setState(() {}),
              errorText: _validateRubricField(_accuracyController.text),
            ),
            _RubricField(
              label: 'Application',
              controller: _applicationController,
              onChanged: () => setState(() {}),
              errorText: _validateRubricField(_applicationController.text),
            ),
            _RubricField(
              label: 'Clarity',
              controller: _clarityController,
              onChanged: () => setState(() {}),
              errorText: _validateRubricField(_clarityController.text),
            ),
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
            TextField(
              controller: _feedbackController,
              maxLines: 3,
              enabled: !_submitting,
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
                onPressed: (_submitting || !_rubricComplete)
                    ? null
                    : _publishScore,
                child: _submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Publish Score'),
              ),
            ),
            if (!_rubricComplete) ...[
              const SizedBox(height: 8),
              Text(
                'Enter a score (0–20) for every category to publish.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
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
  final String? errorText;

  const _RubricField({
    required this.label,
    required this.controller,
    required this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = controller.text.trim().isNotEmpty;
    final showError = hasValue && errorText != null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(label),
            ),
          ),
          SizedBox(
            width: 96,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                suffixText: '/ 20',
                isDense: true,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 10),
                errorText: showError ? errorText : null,
                hintText: '0-20',
              ),
              onChanged: (_) => onChanged(),
            ),
          ),
        ],
      ),
    );
  }
}
