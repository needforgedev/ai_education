-- ============================================================
-- 02: Helper functions used by RLS policies
-- ============================================================

-- Check if the current authenticated user is a moderator
CREATE OR REPLACE FUNCTION is_moderator()
RETURNS boolean AS $$
  SELECT EXISTS (
    SELECT 1 FROM moderators WHERE id = auth.uid()
  );
$$ LANGUAGE sql SECURITY DEFINER STABLE;
