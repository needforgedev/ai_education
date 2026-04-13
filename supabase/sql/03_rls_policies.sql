-- ============================================================
-- 03: RLS Policies for all tables
-- Run AFTER 01_enable_rls.sql and 02_helper_functions.sql
-- ============================================================


-- ============================================================
-- SCHOOLS
-- ============================================================

-- Authenticated users can read all active schools
CREATE POLICY "Authenticated users can read schools"
  ON schools FOR SELECT
  TO authenticated
  USING (true);

-- Anon users can read active schools (needed for registration code validation
-- before the student has an account). Only exposes id, name, and is_active
-- via a Supabase RPC function — this policy enables the function to query.
CREATE POLICY "Anon can read active schools for registration"
  ON schools FOR SELECT
  TO anon
  USING (is_active = true);


-- ============================================================
-- COHORTS (read-only for all users, including anon during registration)
-- ============================================================

CREATE POLICY "Authenticated users can read cohorts"
  ON cohorts FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Anon can read active cohorts for registration"
  ON cohorts FOR SELECT
  TO anon
  USING (is_active = true);


-- ============================================================
-- STUDENTS
-- ============================================================

CREATE POLICY "Students can read own profile"
  ON students FOR SELECT
  TO authenticated
  USING (id = auth.uid());

CREATE POLICY "Students can insert own profile on registration"
  ON students FOR INSERT
  TO authenticated
  WITH CHECK (id = auth.uid());

CREATE POLICY "Students can update own profile"
  ON students FOR UPDATE
  TO authenticated
  USING (id = auth.uid())
  WITH CHECK (id = auth.uid());

CREATE POLICY "Moderators can read all students"
  ON students FOR SELECT
  TO authenticated
  USING (is_moderator());


-- ============================================================
-- MODERATORS
-- ============================================================

CREATE POLICY "Moderators can read own profile"
  ON moderators FOR SELECT
  TO authenticated
  USING (id = auth.uid());


-- ============================================================
-- COURSES (read-only, published only)
-- ============================================================

CREATE POLICY "Authenticated users can read published courses"
  ON courses FOR SELECT
  TO authenticated
  USING (is_published = true);


-- ============================================================
-- MODULES (read-only for all authenticated)
-- ============================================================

CREATE POLICY "Authenticated users can read modules"
  ON modules FOR SELECT
  TO authenticated
  USING (true);


-- ============================================================
-- QUIZ QUESTIONS (read-only for all authenticated)
-- ============================================================

CREATE POLICY "Authenticated users can read quiz questions"
  ON quiz_questions FOR SELECT
  TO authenticated
  USING (true);


-- ============================================================
-- QUIZ ATTEMPTS
-- ============================================================

CREATE POLICY "Students can read own quiz attempts"
  ON quiz_attempts FOR SELECT
  TO authenticated
  USING (student_id = auth.uid());

CREATE POLICY "Students can insert own quiz attempts"
  ON quiz_attempts FOR INSERT
  TO authenticated
  WITH CHECK (student_id = auth.uid());

CREATE POLICY "Moderators can read all quiz attempts"
  ON quiz_attempts FOR SELECT
  TO authenticated
  USING (is_moderator());


-- ============================================================
-- MODULE PROGRESS
-- ============================================================

CREATE POLICY "Students can read own module progress"
  ON module_progress FOR SELECT
  TO authenticated
  USING (student_id = auth.uid());

CREATE POLICY "Students can insert own module progress"
  ON module_progress FOR INSERT
  TO authenticated
  WITH CHECK (student_id = auth.uid());

CREATE POLICY "Students can update own module progress"
  ON module_progress FOR UPDATE
  TO authenticated
  USING (student_id = auth.uid())
  WITH CHECK (student_id = auth.uid());

CREATE POLICY "Moderators can read all module progress"
  ON module_progress FOR SELECT
  TO authenticated
  USING (is_moderator());


-- ============================================================
-- FINAL SUBMISSIONS
-- ============================================================

CREATE POLICY "Students can read own submissions"
  ON final_submissions FOR SELECT
  TO authenticated
  USING (student_id = auth.uid());

CREATE POLICY "Students can insert own submissions"
  ON final_submissions FOR INSERT
  TO authenticated
  WITH CHECK (student_id = auth.uid());

CREATE POLICY "Moderators can read all submissions"
  ON final_submissions FOR SELECT
  TO authenticated
  USING (is_moderator());

CREATE POLICY "Moderators can update submissions for grading"
  ON final_submissions FOR UPDATE
  TO authenticated
  USING (is_moderator())
  WITH CHECK (is_moderator());


-- ============================================================
-- COMMUNITY THREADS (school-scoped for students)
-- ============================================================

CREATE POLICY "Students can read threads from own school"
  ON community_threads FOR SELECT
  TO authenticated
  USING (
    is_hidden = false
    AND school_id = (SELECT school_id FROM students WHERE id = auth.uid())
  );

CREATE POLICY "Students can create threads in own school"
  ON community_threads FOR INSERT
  TO authenticated
  WITH CHECK (
    school_id = (SELECT school_id FROM students WHERE id = auth.uid())
    AND author_id = auth.uid()
    AND is_moderator_post = false
  );

CREATE POLICY "Moderators can read all threads"
  ON community_threads FOR SELECT
  TO authenticated
  USING (is_moderator());

CREATE POLICY "Moderators can create threads"
  ON community_threads FOR INSERT
  TO authenticated
  WITH CHECK (is_moderator() AND author_id = auth.uid());

CREATE POLICY "Moderators can update threads (pin/hide)"
  ON community_threads FOR UPDATE
  TO authenticated
  USING (is_moderator())
  WITH CHECK (is_moderator());


-- ============================================================
-- COMMUNITY REPLIES (scoped via thread's school)
-- ============================================================

CREATE POLICY "Students can read replies on visible threads"
  ON community_replies FOR SELECT
  TO authenticated
  USING (
    is_hidden = false
    AND thread_id IN (
      SELECT id FROM community_threads
      WHERE school_id = (SELECT school_id FROM students WHERE id = auth.uid())
    )
  );

CREATE POLICY "Students can create replies on own school threads"
  ON community_replies FOR INSERT
  TO authenticated
  WITH CHECK (
    author_id = auth.uid()
    AND is_moderator_reply = false
    AND thread_id IN (
      SELECT id FROM community_threads
      WHERE school_id = (SELECT school_id FROM students WHERE id = auth.uid())
    )
  );

CREATE POLICY "Moderators can read all replies"
  ON community_replies FOR SELECT
  TO authenticated
  USING (is_moderator());

CREATE POLICY "Moderators can create replies"
  ON community_replies FOR INSERT
  TO authenticated
  WITH CHECK (is_moderator() AND author_id = auth.uid());

CREATE POLICY "Moderators can update replies (hide)"
  ON community_replies FOR UPDATE
  TO authenticated
  USING (is_moderator())
  WITH CHECK (is_moderator());


-- ============================================================
-- NOTIFICATIONS
-- ============================================================

CREATE POLICY "Users can read own notifications"
  ON notifications FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can update own notifications (mark read)"
  ON notifications FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());
