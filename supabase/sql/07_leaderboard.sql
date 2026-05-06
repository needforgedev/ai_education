-- ============================================================
-- 07: Leaderboard ranking function
--
-- Aggregates per-student score across course_progress (or per-course
-- if scope=course), then ranks descending. Score uses
-- total_score_out_of_100 when a final submission has been graded,
-- otherwise scales avg_quiz_score (0..20) to 0..100 so the leaderboard
-- still works before any final submissions.
--
-- Scopes:
--   'overall'  — all students
--   'cohort'   — students.cohort_id = p_cohort_id
--   'school'   — students.school_id = p_school_id
--   'course'   — course_progress.course_id = p_course_id
-- ============================================================

CREATE OR REPLACE FUNCTION get_leaderboard(
  p_scope text,
  p_cohort_id uuid default null,
  p_school_id uuid default null,
  p_course_id uuid default null
)
RETURNS TABLE(
  student_id uuid,
  student_name text,
  score numeric,
  "rank" int
) AS $$
  WITH per_student AS (
    SELECT
      s.id AS student_id,
      s.full_name AS student_name,
      ROUND(AVG(
        COALESCE(cp.total_score_out_of_100, cp.avg_quiz_score * 5)
      )::numeric, 1) AS score
    FROM students s
    JOIN course_progress cp ON cp.student_id = s.id
    WHERE cp.completed_module_count > 0
      AND (
        p_scope = 'overall'
        OR (p_scope = 'school' AND s.school_id = p_school_id)
        OR (p_scope = 'cohort' AND s.cohort_id = p_cohort_id)
        OR (p_scope = 'course' AND cp.course_id = p_course_id)
      )
    GROUP BY s.id, s.full_name
  )
  SELECT
    student_id,
    student_name,
    score,
    rank() OVER (ORDER BY score DESC)::int AS "rank"
  FROM per_student
  ORDER BY "rank", student_name;
$$ LANGUAGE sql STABLE SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION get_leaderboard(text, uuid, uuid, uuid) TO authenticated;
