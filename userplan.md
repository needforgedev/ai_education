# Developer Setup — Supabase Steps

> Step-by-step guide for the developer to configure Supabase for the AI Education platform.
> Complete these in order.

---

## Prerequisites

- Supabase project created (you should have a project URL and API keys)
- Node.js installed (for running Drizzle migrations)
- `supabase/` folder in the repo has dependencies installed (`cd supabase && npm install`)

---

## Step 1: Get your credentials

### Database URL

1. Open Supabase Dashboard → **Settings** → **Database**
2. Under **Connection string**, select **URI** tab
3. Copy the connection string (starts with `postgresql://`)
4. Create the file `supabase/.env`:

```
DATABASE_URL=postgresql://postgres.[project-ref]:[your-password]@aws-0-[region].pooler.supabase.com:6543/postgres
```

### API Keys (needed later for Flutter app)

1. Open Supabase Dashboard → **Settings** → **API**
2. Note down:
   - **Project URL** — e.g. `https://xxxx.supabase.co`
   - **anon / public key** — safe for client-side, used in the Flutter app
   - **service_role key** — NEVER put this in the Flutter app, server-side only

---

## Step 2: Push database schema

Run these commands from the `supabase/` directory:

```bash
cd supabase

# Generate migration SQL from Drizzle schema files
npx drizzle-kit generate

# Push schema to your Supabase database
npx drizzle-kit push
```

### Verify

1. Open Supabase Dashboard → **Table Editor**
2. You should see these 14 tables:
   - `schools`
   - `cohorts`
   - `students`
   - `moderators`
   - `courses`
   - `modules`
   - `quiz_questions`
   - `quiz_attempts`
   - `module_progress`
   - `final_submissions`
   - `community_threads`
   - `community_replies`
   - `notifications`

---

## Step 3: Enable Row Level Security

1. Open Supabase Dashboard → **SQL Editor**
2. Open the file `supabase/sql/01_enable_rls.sql` from the repo
3. Paste the contents into the SQL Editor and click **Run**

This enables RLS on all 13 tables. Without this, the anon key has full access to everything.

---

## Step 4: Create helper functions

1. In the **SQL Editor**, open `supabase/sql/02_helper_functions.sql`
2. Paste and **Run**

This creates the `is_moderator()` function used by all RLS policies.

---

## Step 5: Apply RLS policies

1. In the **SQL Editor**, open `supabase/sql/03_rls_policies.sql`
2. Paste and **Run**

This creates all read/write policies for every table, scoped by role (student, moderator, anon).

---

## Step 6: Create the submissions storage bucket

1. Open Supabase Dashboard → **Storage**
2. Click **New Bucket**
3. Configure:
   - **Name:** `submissions`
   - **Public:** OFF
   - **File size limit:** 10 MB
   - **Allowed MIME types:** `application/pdf, text/plain, text/x-python, application/javascript, application/x-dart`
4. Click **Create**

---

## Step 7: Apply storage policies

1. In the **SQL Editor**, open `supabase/sql/04_storage_policies.sql`
2. Paste and **Run**

This restricts file uploads so students can only write to their own folder and moderators can read all files.

---

## Step 8: Create database views and functions

1. In the **SQL Editor**, open `supabase/sql/05_views.sql`
2. Paste and **Run**

This creates:
- `course_progress` view — aggregates quiz scores + submission scores per student per course
- `validate_school_code()` function — safely validates school registration codes during signup

---

## Step 9: Configure authentication

1. Open Supabase Dashboard → **Authentication** → **Providers**
2. Ensure **Email** provider is enabled
3. Set **Minimum password length** to `8`
4. Decide on email confirmation:
   - **For development:** Disable "Confirm email" (faster testing)
   - **For production:** Enable "Confirm email"

5. Open **Authentication** → **URL Configuration**
6. Set **Site URL** to your app's scheme (e.g. `io.supabase.aieducation://`)

---

## Step 10: Seed initial data

### Seed schools

Open **Table Editor** → `schools` → **Insert Row** for each school:

| name | registration_code | is_active |
|------|------------------|-----------|
| Sunrise Public School | `SUNRISE-2026` | true |
| Delhi International Academy | `DIA-2026` | true |
| Greenfield High School | `GREENFIELD-2026` | true |

Share the registration codes with the respective school admins.

### Seed cohorts

Open **Table Editor** → `cohorts` → **Insert Row** for each:

| name | min_grade | max_grade | is_active |
|------|-----------|-----------|-----------|
| Grades 3-4 | 3 | 4 | true |
| Grades 5-6 | 5 | 6 | true |
| Grades 7-8 | 7 | 8 | true |
| Grades 9-10 | 9 | 10 | true |
| Grades 11-12 | 11 | 12 | true |

### Seed courses, modules, and quiz questions

> These will be seeded via the seed script once it's built (`npx tsx src/seed.ts`).
> Curriculum content is placeholder for now — final content will be authored separately.

---

## Step 11: Create the first moderator

See [moderator.md](moderator.md) for detailed instructions on onboarding moderators.

Quick version:
1. **Authentication** → **Add User** → enter moderator's email + password
2. Copy the user's UUID from the user list
3. **Table Editor** → `moderators` → **Insert Row** with that UUID, name, and email
4. Share credentials with the moderator

---

## Step 12: Verify the setup

Run through this checklist:

| # | Check | How |
|---|-------|-----|
| 1 | Tables exist | Table Editor shows all 14 tables |
| 2 | RLS is on | Each table shows "RLS enabled" badge |
| 3 | Storage bucket | Storage shows `submissions` bucket |
| 4 | Auth works | Authentication → Add User → create a test user → user appears in list |
| 5 | School code works | SQL Editor → `SELECT * FROM validate_school_code('SUNRISE-2026');` → returns school id and name |
| 6 | Cohorts seeded | SQL Editor → `SELECT * FROM cohorts;` → 5 rows |
| 7 | Moderator exists | SQL Editor → `SELECT * FROM moderators;` → at least 1 row |

---

## Quick Reference — SQL file run order

| Order | File | What it does |
|-------|------|-------------|
| 1 | `supabase/sql/01_enable_rls.sql` | Enables RLS on all tables |
| 2 | `supabase/sql/02_helper_functions.sql` | Creates `is_moderator()` helper |
| 3 | `supabase/sql/03_rls_policies.sql` | All read/write policies per role |
| 4 | `supabase/sql/04_storage_policies.sql` | Submission file upload/read policies |
| 5 | `supabase/sql/05_views.sql` | `course_progress` view + `validate_school_code()` function |

---

## Security Reminders

- **Never** put the `service_role` key in the Flutter app — it bypasses all RLS
- **Always** use the `anon` key in client-side code
- **Never** disable RLS on production tables
- **Never** create DELETE policies — data is hidden (soft delete), not removed
- Store Supabase URL and anon key via `--dart-define` or a gitignored `.env`, not hardcoded in source
