import { pgTable, uuid, integer, jsonb, timestamp, index } from 'drizzle-orm/pg-core';
import { students } from './students';
import { modules } from './modules';

export const quizAttempts = pgTable(
  'quiz_attempts',
  {
    id: uuid('id').defaultRandom().primaryKey(),
    studentId: uuid('student_id')
      .notNull()
      .references(() => students.id),
    moduleId: uuid('module_id')
      .notNull()
      .references(() => modules.id),
    scoreOutOf20: integer('score_out_of_20').notNull(),
    answers: jsonb('answers').notNull().$type<number[]>(),
    attemptedAt: timestamp('attempted_at', { withTimezone: true })
      .notNull()
      .defaultNow(),
  },
  (table) => [
    index('quiz_attempts_student_module_idx').on(
      table.studentId,
      table.moduleId
    ),
  ]
);
