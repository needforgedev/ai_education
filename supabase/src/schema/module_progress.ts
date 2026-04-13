import { pgTable, uuid, integer, timestamp, index, unique } from 'drizzle-orm/pg-core';
import { students } from './students';
import { modules } from './modules';

export const moduleProgress = pgTable(
  'module_progress',
  {
    id: uuid('id').defaultRandom().primaryKey(),
    studentId: uuid('student_id')
      .notNull()
      .references(() => students.id),
    moduleId: uuid('module_id')
      .notNull()
      .references(() => modules.id),
    lessonViewedAt: timestamp('lesson_viewed_at', { withTimezone: true }),
    quizPassedAt: timestamp('quiz_passed_at', { withTimezone: true }),
    bestQuizScore: integer('best_quiz_score'), // tracked for quick reads
    completedAt: timestamp('completed_at', { withTimezone: true }),
  },
  (table) => [
    unique('module_progress_student_module_uniq').on(
      table.studentId,
      table.moduleId
    ),
    index('module_progress_student_idx').on(table.studentId),
  ]
);
