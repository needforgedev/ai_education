import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../../../data/models/submission.dart';
import '../providers/submission_providers.dart';

/// In-app viewer for a submitted file.
/// PDFs render inline via `flutter_pdfview`.
/// Text / code files render as a selectable monospace block.
class SubmissionFileViewerScreen extends ConsumerStatefulWidget {
  final Submission submission;

  const SubmissionFileViewerScreen({super.key, required this.submission});

  @override
  ConsumerState<SubmissionFileViewerScreen> createState() =>
      _SubmissionFileViewerScreenState();
}

class _SubmissionFileViewerScreenState
    extends ConsumerState<SubmissionFileViewerScreen> {
  Future<_LoadedFile>? _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = _load();
  }

  Future<_LoadedFile> _load() async {
    final repo = ref.read(submissionRepositoryProvider);
    final bytes = await repo.downloadBytes(
      storagePath: widget.submission.fileUrl,
    );
    final ext = widget.submission.fileType.replaceFirst('.', '').toLowerCase();

    if (ext == 'pdf') {
      final dir = await getTemporaryDirectory();
      final file = File(
          '${dir.path}/submission_${widget.submission.id}.pdf');
      await file.writeAsBytes(bytes, flush: true);
      return _LoadedFile.pdf(localPath: file.path);
    }

    return _LoadedFile.text(_decodeText(bytes));
  }

  String _decodeText(Uint8List bytes) {
    try {
      return utf8.decode(bytes);
    } catch (_) {
      return latin1.decode(bytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.submission.fileName, overflow: TextOverflow.ellipsis),
      ),
      body: FutureBuilder<_LoadedFile>(
        future: _loadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _ErrorState(error: snapshot.error);
          }
          final loaded = snapshot.data!;
          if (loaded.isPdf) {
            return PDFView(
              filePath: loaded.localPath!,
              enableSwipe: true,
              swipeHorizontal: false,
              autoSpacing: true,
              pageFling: true,
              fitPolicy: FitPolicy.BOTH,
            );
          }
          return _TextViewer(content: loaded.text!);
        },
      ),
    );
  }
}

class _LoadedFile {
  final bool isPdf;
  final String? localPath;
  final String? text;

  const _LoadedFile._({required this.isPdf, this.localPath, this.text});

  factory _LoadedFile.pdf({required String localPath}) =>
      _LoadedFile._(isPdf: true, localPath: localPath);
  factory _LoadedFile.text(String content) =>
      _LoadedFile._(isPdf: false, text: content);
}

class _TextViewer extends StatelessWidget {
  final String content;
  const _TextViewer({required this.content});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: SelectableText(
          content,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 13,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final Object? error;
  const _ErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            Text('Could not load file',
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              '$error',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
