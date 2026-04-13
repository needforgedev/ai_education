import {
  pgTable,
  uuid,
  text,
  integer,
  boolean,
  timestamp,
} from 'drizzle-orm/pg-core';
import { cohorts } from './cohorts';

export const courses = pgTable('courses', {
  id: uuid('id').defaultRandom().primaryKey(),
  cohortId: uuid('cohort_id')
    .notNull()
    .references(() => cohorts.id),
  title: text('title').notNull(),
  description: text('description').notNull(),
  moduleCount: integer('module_count').notNull().default(10),
  icon: text('icon').notNull().default('📚'),
  orderIndex: integer('order_index').notNull().default(0),
  isPublished: boolean('is_published').notNull().default(true),
  createdAt: timestamp('created_at', { withTimezone: true })
    .notNull()
    .defaultNow(),
});
