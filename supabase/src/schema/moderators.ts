import { pgTable, uuid, text, timestamp } from 'drizzle-orm/pg-core';

export const moderators = pgTable('moderators', {
  id: uuid('id').primaryKey(), // references auth.users(id)
  fullName: text('full_name').notNull(),
  email: text('email').notNull(),
  createdAt: timestamp('created_at', { withTimezone: true })
    .notNull()
    .defaultNow(),
});
