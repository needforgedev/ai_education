-- ============================================================
-- 04: Storage bucket policies for file uploads
--
-- BEFORE running this:
-- 1. Go to Supabase Dashboard → Storage → New Bucket
-- 2. Name: "submissions"
-- 3. Public: OFF
-- 4. File size limit: 10MB
-- 5. Allowed MIME types:
--    application/pdf, text/plain, text/x-python,
--    application/javascript, application/x-dart
-- ============================================================

-- Students can upload files to their own folder: {student_id}/{course_id}/filename
CREATE POLICY "Students upload own submissions"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (
    bucket_id = 'submissions'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

-- Students can read their own uploaded files
CREATE POLICY "Students read own submissions"
  ON storage.objects FOR SELECT
  TO authenticated
  USING (
    bucket_id = 'submissions'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

-- Moderators can read all submission files for grading
CREATE POLICY "Moderators read all submissions"
  ON storage.objects FOR SELECT
  TO authenticated
  USING (
    bucket_id = 'submissions'
    AND is_moderator()
  );
