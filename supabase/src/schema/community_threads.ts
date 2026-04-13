import {
  pgTable,
  uuid,
  text,
  boolean,
  timestamp,
} from 'drizzle-orm/pg-core';
import { schools } from './schools';
import { courses } from './courses';
import { modules } from './modules';

export const communityThreads = pgTable('community_threads', {
  id: uuid('id').defaultRandom().primaryKey(),
  schoolId: uuid('school_id')
    .notNull()
    .references(() => schools.id),
  courseId: uuid('course_id').references(() => courses.id),
  moduleId: uuid('module_id').references(() => modules.id),
  authorId: uuid('author_id').notNull(), // references auth.users(id)
  authorName: text('author_name').notNull(),
  title: text('title').notNull(),
  body: text('body').notNull(),
  isModeratorPost: boolean('is_moderator_post').notNull().default(false),
  isPinned: boolean('is_pinned').notNull().default(false),
  isHidden: boolean('is_hidden').notNull().default(false),
  createdAt: timestamp('created_at', { withTimezone: true })
    .notNull()
    .defaultNow(),
});
