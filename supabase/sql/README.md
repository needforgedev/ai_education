# Supabase SQL Setup

Run these files **in order** in the Supabase SQL Editor after `drizzle-kit push` has created the tables.

| Order | File | What it does |
|-------|------|-------------|
| 1 | `01_enable_rls.sql` | Enables Row Level Security on all 13 tables |
| 2 | `02_helper_functions.sql` | Creates `is_moderator()` helper used by policies |
| 3 | `03_rls_policies.sql` | Creates all RLS policies (read/write rules per role) |
| 4 | `04_storage_policies.sql` | Creates storage policies for `submissions` bucket |
| 5 | `05_views.sql` | Creates `course_progress` view for dashboards and leaderboard |

## Manual steps (Supabase Dashboard)

Before running `04_storage_policies.sql`:

1. **Storage** → New Bucket → name: `submissions`, public: OFF, size limit: 10MB
2. **Authentication** → Providers → Enable Email, set min password length to 8
