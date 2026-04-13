import { pgEnum } from 'drizzle-orm/pg-core';

export const userRoleEnum = pgEnum('user_role', ['student', 'moderator']);

export const submissionStatusEnum = pgEnum('submission_status', [
  'pending',
  'graded',
]);

export const courseProgressStatusEnum = pgEnum('course_progress_status', [
  'not_started',
  'in_progress',
  'modules_done',
  'completed',
]);
