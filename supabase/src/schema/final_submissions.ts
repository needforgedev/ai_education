import {
  pgTable,
  uuid,
  text,
  integer,
  timestamp,
} from 'drizzle-orm/pg-core';
import { submissionStatusEnum } from './enums';
import { students } from './students';
import { courses } from './courses';
import { moderators } from './moderators';

export const finalSubmissions = pgTable('final_submissions', {
  id: uuid('id').defaultRandom().primaryKey(),
  studentId: uuid('student_id')
    .notNull()
    .references(() => students.id),
  courseId: uuid('course_id')
    .notNull()
    .references(() => courses.id),
  fileUrl: text('file_url').notNull(),
  fileName: text('file_name').notNull(),
  fileType: text('file_type').notNull(),
  notes: text('notes').default(''),
  submittedAt: timestamp('submitted_at', { withTimezone: true })
    .notNull()
    .defaultNow(),
  status: submissionStatusEnum('status').notNull().default('pending'),
  scoreOutOf80: integer('score_out_of_80'),
  moderatorId: uuid('moderator_id').references(() => moderators.id),
  moderatorFeedback: text('moderator_feedback'),
  gradedAt: timestamp('graded_at', { withTimezone: true }),
});
