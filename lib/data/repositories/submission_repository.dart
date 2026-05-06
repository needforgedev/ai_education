import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart' show FileOptions;
import '../../core/constants.dart';
import '../../core/supabase/supabase_client.dart';
import '../models/submission.dart';

/// Final submissions: Supabase only (online required).
class SubmissionRepository {
  /// Uploads a file to Supabase Storage under {studentId}/{courseId}/{filename}
  /// and returns the storage path.
  Future<String> uploadFile({
    required String studentId,
    required String courseId,
    required File file,
    required String fileName,
  }) async {
    final path = '$studentId/$courseId/$fileName';
    await supabase.storage.from(Buckets.submissions).upload(
          path,
          file,
          fileOptions: const FileOptions(upsert: true),
        );
    return path;
  }

  /// Creates the final_submission row.
  Future<Submission> createSubmission({
    required String studentId,
    required String courseId,
    required String fileUrl,
    required String fileName,
    required String fileType,
    String notes = '',
  }) async {
    final result = await supabase
        .from(Tables.finalSubmissions)
        .insert({
          'student_id': studentId,
          'course_id': courseId,
          'file_url': fileUrl,
          'file_name': fileName,
          'file_type': fileType,
          'notes': notes,
          'status': 'pending',
        })
        .select()
        .single();

    return Submission.fromJson(result);
  }

  /// Generate a time-limited signed URL so the moderator can open/download
  /// the uploaded file. Bucket is private; signed URLs respect storage policies.
  /// Defaults to a 1-hour window.
  Future<String> createSignedUrl({
    required String storagePath,
    Duration expiresIn = const Duration(hours: 1),
  }) async {
    return supabase.storage
        .from(Buckets.submissions)
        .createSignedUrl(storagePath, expiresIn.inSeconds);
  }

  /// Download the raw bytes of a submission file. Used by the in-app viewer.
  Future<Uint8List> downloadBytes({required String storagePath}) async {
    return supabase.storage.from(Buckets.submissions).download(storagePath);
  }

  /// Every submission this student has made — used by the achievements engine.
  Future<List<Submission>> getAllSubmissionsForStudent(String studentId) async {
    final result = await supabase
        .from(Tables.finalSubmissions)
        .select()
        .eq('student_id', studentId)
        .order('submitted_at', ascending: false);
    return (result as List)
        .map((e) => Submission.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetch the existing submission for this student+course (if any).
  Future<Submission?> getSubmission({
    required String studentId,
    required String courseId,
  }) async {
    final result = await supabase
        .from(Tables.finalSubmissions)
        .select()
        .eq('student_id', studentId)
        .eq('course_id', courseId)
        .maybeSingle();

    if (result == null) return null;
    return Submission.fromJson(result);
  }
}
