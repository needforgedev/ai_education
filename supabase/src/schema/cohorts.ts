import { pgTable, uuid, text, integer, boolean, timestamp } from 'drizzle-orm/pg-core';

export const cohorts = pgTable('cohorts', {
  id: uuid('id').defaultRandom().primaryKey(),
  name: text('name').notNull(),
  minGrade: integer('min_grade').notNull(),
  maxGrade: integer('max_grade').notNull(),
  isActive: boolean('is_active').notNull().default(true),
  createdAt: timestamp('created_at', { withTimezone: true })
    .notNull()
    .defaultNow(),
});
