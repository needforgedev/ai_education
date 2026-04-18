-- ============================================================
-- 06: Add missing INSERT policy on notifications
--
-- Problem: 03_rls_policies.sql originally defined only SELECT + UPDATE
-- policies on `notifications`, which silently blocked moderators from
-- creating "submission graded" rows.
-- Run this once against the Supabase SQL Editor.
-- ============================================================

CREATE POLICY "Moderators can create notifications"
  ON notifications FOR INSERT
  TO authenticated
  WITH CHECK (is_moderator());
