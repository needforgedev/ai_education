import { pgTable, uuid, text, boolean, timestamp } from 'drizzle-orm/pg-core';
import { communityThreads } from './community_threads';

export const communityReplies = pgTable('community_replies', {
  id: uuid('id').defaultRandom().primaryKey(),
  threadId: uuid('thread_id')
    .notNull()
    .references(() => communityThreads.id),
  authorId: uuid('author_id').notNull(), // references auth.users(id)
  authorName: text('author_name').notNull(),
  body: text('body').notNull(),
  isModeratorReply: boolean('is_moderator_reply').notNull().default(false),
  isHidden: boolean('is_hidden').notNull().default(false),
  createdAt: timestamp('created_at', { withTimezone: true })
    .notNull()
    .defaultNow(),
});
