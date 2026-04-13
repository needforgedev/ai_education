import { pgTable, uuid, text, boolean, timestamp, index } from 'drizzle-orm/pg-core';

export const notifications = pgTable(
  'notifications',
  {
    id: uuid('id').defaultRandom().primaryKey(),
    userId: uuid('user_id').notNull(), // references auth.users(id)
    type: text('type').notNull(), // 'submission_graded' | 'moderator_reply' | 'continue_reminder'
    title: text('title').notNull(),
    body: text('body').notNull(),
    data: text('data'), // JSON string with contextual info (courseId, threadId, etc.)
    isRead: boolean('is_read').notNull().default(false),
    createdAt: timestamp('created_at', { withTimezone: true })
      .notNull()
      .defaultNow(),
  },
  (table) => [
    index('notifications_user_idx').on(table.userId),
    index('notifications_unread_idx').on(table.userId, table.isRead),
  ]
);
