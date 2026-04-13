import { pgTable, uuid, text, integer, timestamp } from 'drizzle-orm/pg-core';
import { schools } from './schools';
import { cohorts } from './cohorts';

export const students = pgTable('students', {
  id: uuid('id').primaryKey(), // references auth.users(id)
  fullName: text('full_name').notNull(),
  email: text('email').notNull(),
  grade: integer('grade').notNull(),
  schoolId: uuid('school_id')
    .notNull()
    .references(() => schools.id),
  cohortId: uuid('cohort_id')
    .notNull()
    .references(() => cohorts.id),
  guardianContact: text('guardian_contact'),
  joinedAt: timestamp('joined_at', { withTimezone: true })
    .notNull()
    .defaultNow(),
});
