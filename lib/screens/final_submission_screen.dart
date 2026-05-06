import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app/theme.dart';
import '../core/connectivity/connectivity_provider.dart';
import '../core/connectivity/offline_gate.dart';
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
        backgroundColor: AppPalette.bg,
        appBar: AppBar(
          title: const Text('Final submission'),
          backgroundColor: AppPalette.bg,
        ),
        body: const OfflineGate(
          body:
              'Submissions need internet so we can upload your file. Reconnect and try again!',
        ),
      );
    }

    final existingAsync = ref.watch(submissionForCourseProvider(widget.course.id));
    return existingAsync.when(
      loading: () => Scaffold(
        backgroundColor: AppPalette.bg,
        appBar: AppBar(
          title: const Text('Final submission'),
          backgroundColor: AppPalette.bg,
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        backgroundColor: AppPalette.bg,
        appBar: AppBar(
          title: const Text('Final submission'),
          backgroundColor: AppPalette.bg,
        ),
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
      backgroundColor: AppPalette.bg,
      appBar: AppBar(
        title: const SizedBox.shrink(),
        backgroundColor: AppPalette.bg,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('FINAL PROJECT · 80 MARKS',
                style: AppText.eyebrow(context, color: AppPalette.primary)),
            const SizedBox(height: 8),
            Text(widget.course.title, style: theme.textTheme.displaySmall),
            const SizedBox(height: 6),
            Text(
              'Ship your final project and a moderator will grade it.',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: AppPalette.textSoft, height: 1.5),
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppPalette.primaryWash,
                borderRadius: BorderRadius.circular(AppRadii.card),
                border: Border.all(color: AppPalette.primary),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('THE TASK',
                      style: AppText.eyebrow(context,
                          color: AppPalette.primary)),
                  const SizedBox(height: 6),
                  Text(
                    'Create a simple explanation of an AI use-case you see in your daily life. Describe how it works, what data it might use, and why it matters.',
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(color: AppPalette.text, height: 1.45),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Text('UPLOAD FILE', style: AppText.eyebrow(context)),
            const SizedBox(height: 8),
            InkWell(
              borderRadius: BorderRadius.circular(AppRadii.card),
              onTap: _submitting ? null : _pickFile,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppPalette.surface,
                  borderRadius: BorderRadius.circular(AppRadii.card),
                  border: Border.all(
                    color: _pickedFile != null
                        ? AppPalette.primary
                        : AppPalette.border,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      _pickedFile != null
                          ? Icons.insert_drive_file
                          : Icons.upload_file_outlined,
                      size: 36,
                      color: _pickedFile != null
                          ? AppPalette.primary
                          : AppPalette.textSoft,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _pickedFile?.name ?? 'Tap to choose file',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: _pickedFile != null
                            ? AppPalette.primary
                            : AppPalette.text,
                      ),
                    ),
                    if (_pickedFile == null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Accepted: ${_allowedExtensions.map((e) => ".$e").join(", ")}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppPalette.textSoft,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text('NOTES (OPTIONAL)', style: AppText.eyebrow(context)),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 4,
              enabled: !_submitting,
              decoration: const InputDecoration(
                hintText: 'Anything the moderator should know…',
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Submit project'),
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
      backgroundColor: AppPalette.bg,
      appBar: AppBar(
        title: const SizedBox.shrink(),
        backgroundColor: AppPalette.bg,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isGraded ? 'GRADED' : 'SUBMITTED',
                style: AppText.eyebrow(
                  context,
                  color: isGraded ? Colors.green : AppPalette.cyan,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isGraded ? 'You\'re graded!' : 'Your project is in.',
                style: theme.textTheme.displaySmall,
              ),
              const SizedBox(height: 6),
              Text(
                course.title,
                style: theme.textTheme.bodyLarge
                    ?.copyWith(color: AppPalette.textSoft),
              ),
              const SizedBox(height: 24),
              if (isGraded)
                _GradedScoreCard(
                  score: submission.scoreOutOf80 ?? 0,
                  feedback: submission.moderatorFeedback,
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppPalette.surface,
                    borderRadius: BorderRadius.circular(AppRadii.card),
                    border: Border.all(color: AppPalette.border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.hourglass_top,
                          color: AppPalette.cyan, size: 28),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'A moderator will review your project soon. We\'ll notify you when it\'s graded.',
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: AppPalette.text, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Back to course'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradedScoreCard extends StatelessWidget {
  final int score;
  final String? feedback;

  const _GradedScoreCard({required this.score, required this.feedback});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                    AppPalette.primary.withValues(alpha: 0.5),
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
              Text(
                'YOUR SCORE',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppPalette.cyan,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                ),
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
                      text: ' / 80',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: const Color(0xFFCBD5E1),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (feedback != null && feedback!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('FEEDBACK',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppPalette.cyan,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w600,
                    )),
                const SizedBox(height: 6),
                Text(
                  feedback!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFFE2E8F0),
                    height: 1.5,
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
