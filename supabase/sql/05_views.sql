-- ============================================================
-- 05: Database views for CourseProgress and Leaderboard
--
-- course_progress: aggregates module completion + quiz scores
--   + final submission into a per-student per-course summary
--
-- Used by: student dashboard, course detail, leaderboard
-- ============================================================

CREATE OR REPLACE VIEW course_progress AS
SELECT
  s.id AS student_id,
  c.id AS course_id,
  c.cohort_id,
  s.school_id,
  s.full_name AS student_name,
  COUNT(mp.id) FILTER (WHERE mp.completed_at IS NOT NULL)::int AS completed_module_count,
  c.module_count AS total_module_count,
  ROUND(
    COALESCE(
      AVG(mp.best_quiz_score) FILTER (WHERE mp.best_quiz_score IS NOT NULL),
      0
    )::numeric,
    1
  ) AS avg_quiz_score,
  fs.score_out_of_80 AS final_submission_score,
  CASE
    WHEN fs.score_out_of_80 IS NOT NULL THEN
      ROUND(
        COALESCE(
          AVG(mp.best_quiz_score) FILTER (WHERE mp.best_quiz_score IS NOT NULL),
          0
        )::numeric,
        1
      ) + fs.score_out_of_80
    ELSE NULL
  END AS total_score_out_of_100,
  CASE
    WHEN fs.score_out_of_80 IS NOT NULL THEN 'completed'
    WHEN COUNT(mp.id) FILTER (WHERE mp.completed_at IS NOT NULL) = c.module_count
      THEN 'modules_done'
    WHEN COUNT(mp.id) FILTER (WHERE mp.completed_at IS NOT NULL) > 0
      THEN 'in_progress'
    ELSE 'not_started'
  END AS status
FROM students s
CROSS JOIN courses c
LEFT JOIN modules m ON m.course_id = c.id
LEFT JOIN module_progress mp ON mp.module_id = m.id AND mp.student_id = s.id
LEFT JOIN final_submissions fs
  ON fs.course_id = c.id
  AND fs.student_id = s.id
  AND fs.status = 'graded'
WHERE c.is_published = true
GROUP BY s.id, c.id, c.cohort_id, s.school_id, s.full_name,
         c.module_count, fs.score_out_of_80;

-- Grant access to authenticated users
-- (RLS on underlying tables still applies)
GRANT SELECT ON course_progress TO authenticated;


-- ============================================================
-- FUNCTION: validate_school_code
--
-- Called during student registration (before auth).
-- Returns school id + name if the code is valid and school is active.
-- Returns empty if invalid. Does NOT expose registration codes.
-- ============================================================

CREATE OR REPLACE FUNCTION validate_school_code(code text)
RETURNS TABLE(school_id uuid, school_name text) AS $$
  SELECT id, name
  FROM schools
  WHERE registration_code = code
    AND is_active = true
  LIMIT 1;
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- Allow anon (unauthenticated) users to call this during registration
GRANT EXECUTE ON FUNCTION validate_school_code(text) TO anon;
GRANT EXECUTE ON FUNCTION validate_school_code(text) TO authenticated;
