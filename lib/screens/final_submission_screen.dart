import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/connectivity/connectivity_provider.dart';
import '../data/models/course.dart';
import '../data/models/submission.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/submissions/providers/submission_providers.dart';

const _allowedExtensions = ['pdf', 'txt', 'py', 'js', 'dart'];

class FinalSubmissionScreen extends ConsumerStatefulWidget {
  final Course course;

  const FinalSubmissionScreen({super.key, required this.course});

  @override
  ConsumerState<FinalSubmissionScreen> createState() =>
      _FinalSubmissionScreenState();
}

class _FinalSubmissionScreenState extends ConsumerState<FinalSubmissionScreen> {
  final _notesController = TextEditingController();
  PlatformFile? _pickedFile;
  bool _submitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: _allowedExtensions,
    );
    if (result == null) return;
    setState(() => _pickedFile = result.files.single);
  }

  Future<void> _submit() async {
    final file = _pickedFile;
    if (file == null || file.path == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick a file first')),
      );
      return;
    }
    final studentId = ref.read(authProvider).studentProfile?.id;
    if (studentId == null) return;

    setState(() => _submitting = true);
    try {
      final repo = ref.read(submissionRepositoryProvider);
      final storagePath = await repo.uploadFile(
        studentId: studentId,
        courseId: widget.course.id,
        file: File(file.path!),
        fileName: file.name,
      );
      final ext = (file.extension ?? 'pdf').toLowerCase();
      await repo.createSubmission(
        studentId: studentId,
        courseId: widget.course.id,
        fileUrl: storagePath,
        fileName: file.name,
        fileType: '.$ext',
        notes: _notesController.text.trim(),
      );

      ref.invalidate(submissionForCourseProvider(widget.course.id));
      if (!mounted) return;
      setState(() => _submitting = false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submission failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final online = ref.watch(isOnlineProvider);
    if (!online) {
      return Scaffold(
        appBar: AppBar(title: const Text('Final Submission')),
        body: const _OfflineGate(),
      );
    }

    final existingAsync = ref.watch(submissionForCourseProvider(widget.course.id));
    return existingAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Final Submission')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        appBar: AppBar(title: const Text('Final Submission')),
        body: Center(child: Text('Error: $err')),
      ),
      data: (existing) {
        if (existing != null) {
          return _SubmittedView(course: widget.course, submission: existing);
        }
        return _buildForm(context);
      },
    );
  }

  Widget _buildForm(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Final Submission')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: theme.colorScheme.tertiary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Worth 80 marks. A moderator will review and grade your work.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onTertiaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Course',
                style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 4),
            Text(widget.course.title,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 24),
            Text('Task',
                style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 4),
            Text(
              'Create a simple explanation of an AI use-case you see in your daily life. Describe how it works, what data it might use, and why it matters.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 28),
            Text('Upload File',
                style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _submitting ? null : _pickFile,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      _pickedFile != null
                          ? Icons.insert_drive_file
                          : Icons.cloud_upload_outlined,
                      size: 40,
                      color: _pickedFile != null
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _pickedFile?.name ?? 'Tap to choose file',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: _pickedFile != null
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight: _pickedFile != null
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    if (_pickedFile == null)
                      Text(
                        'Accepted: ${_allowedExtensions.map((e) => ".$e").join(", ")}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _notesController,
              maxLines: 4,
              enabled: !_submitting,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'Add any extra notes about your submission...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Submit Project'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubmittedView extends StatelessWidget {
  final Course course;
  final Submission submission;

  const _SubmittedView({required this.course, required this.submission});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isGraded = submission.isGraded;

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
                  color: isGraded
                      ? Colors.green.withValues(alpha: 0.12)
                      : theme.colorScheme.tertiaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isGraded ? Icons.grading : Icons.cloud_done_outlined,
                  size: 52,
                  color: isGraded ? Colors.green : theme.colorScheme.tertiary,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                isGraded ? 'Graded!' : 'Submission Received!',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                isGraded
                    ? 'Your project for "${course.title}" has been graded.'
                    : 'Your project for "${course.title}" has been submitted. A moderator will review it soon.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (isGraded) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${submission.scoreOutOf80} / 80',
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      if (submission.moderatorFeedback != null &&
                          submission.moderatorFeedback!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          submission.moderatorFeedback!,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              const Spacer(flex: 3),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Back to Course'),
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

class _OfflineGate extends StatelessWidget {
  const _OfflineGate();

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
            Text('Connect to internet', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Submissions need internet so we can upload your file. Reconnect and try again!',
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
