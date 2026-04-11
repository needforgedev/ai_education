import 'package:flutter/material.dart';
import '../mock/mock_data.dart';
import '../mock/app_state.dart';

class FinalSubmissionScreen extends StatefulWidget {
  final MockCourse course;

  const FinalSubmissionScreen({super.key, required this.course});

  @override
  State<FinalSubmissionScreen> createState() => _FinalSubmissionScreenState();
}

class _FinalSubmissionScreenState extends State<FinalSubmissionScreen> {
  final _notesController = TextEditingController();
  String? _selectedFileName;
  String _selectedFileType = '.pdf';
  bool _submitted = false;

  final List<String> _fileTypes = ['.pdf', '.txt', '.py', '.js', '.dart'];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_selectedFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file to upload')),
      );
      return;
    }

    AppState().submitProject(
      widget.course.id,
      _selectedFileName!,
      _selectedFileType,
      _notesController.text,
    );

    setState(() => _submitted = true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = AppState();
    final avgScore = state.averageQuizScore(widget.course.id);

    if (_submitted) {
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
                    Icons.cloud_done_outlined,
                    size: 52,
                    color: theme.colorScheme.tertiary,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Submission Received!',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your project for "${widget.course.title}" has been submitted. A moderator will review and grade it soon.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _ScoreRow(label: 'Quiz Average', value: '${avgScore.toStringAsFixed(1)} / 20'),
                      const SizedBox(height: 8),
                      _ScoreRow(label: 'Submission', value: 'Pending / 80'),
                      const Divider(),
                      _ScoreRow(label: 'Total', value: 'Pending / 100'),
                    ],
                  ),
                ),
                const Spacer(flex: 3),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
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
                      'This submission is worth 80 marks and will be graded by a moderator.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onTertiaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Course', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 4),
            Text(widget.course.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.score, size: 18, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Your quiz average: ${avgScore.toStringAsFixed(1)} / 20',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Task', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 4),
            Text(
              'Create a simple explanation of an AI use-case you see in your daily life. Describe how it works, what data it might use, and why it matters.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 28),

            // File type selection
            Text('File Type', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _fileTypes.map((type) {
                final isSelected = _selectedFileType == type;
                return ChoiceChip(
                  label: Text(type),
                  selected: isSelected,
                  onSelected: (val) {
                    setState(() {
                      _selectedFileType = type;
                      if (_selectedFileName != null) {
                        final name = _selectedFileName!.split('.').first;
                        _selectedFileName = '$name$type';
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // File upload area
            Text('Upload File', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                setState(() {
                  _selectedFileName = 'my_ai_project$_selectedFileType';
                });
              },
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
                      _selectedFileName != null
                          ? Icons.insert_drive_file
                          : Icons.cloud_upload_outlined,
                      size: 40,
                      color: _selectedFileName != null
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedFileName ?? 'Tap to choose file',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: _selectedFileName != null
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight: _selectedFileName != null
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    if (_selectedFileName == null)
                      Text(
                        'Accepted: ${_fileTypes.join(", ")}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Notes
            TextField(
              controller: _notesController,
              maxLines: 4,
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
                onPressed: _submit,
                child: const Text('Submit Project'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final String label;
  final String value;

  const _ScoreRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
