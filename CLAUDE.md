# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Development Commands

```bash
flutter pub get                          # Install dependencies
flutter analyze                          # Run linter (flutter_lints 6.0)
flutter test                             # Run widget tests
flutter run --dart-define-from-file=.env  # Launch app with Supabase credentials
```

### Supabase schema (in `supabase/` directory)

```bash
cd supabase && npm install               # Install Drizzle ORM dependencies
npx drizzle-kit generate                 # Generate migration SQL
npx drizzle-kit push                     # Apply schema to Supabase DB
npx tsx src/seed.ts                      # Seed data (when built)
```

## Architecture

AI education platform for K-12 students (grades 3-12) with two roles: **Student** and **Moderator**.

**Backend:** Supabase (auth, PostgreSQL DB, storage, realtime)
**Schema:** Drizzle ORM (TypeScript) in `supabase/` folder (monorepo)

### State Management

- **Auth & user state:** Riverpod (`AuthNotifier` StateNotifier in `lib/features/auth/providers/`)
- **Mock data (courses, quizzes, progress):** Legacy `AppState` ChangeNotifier singleton (`lib/mock/app_state.dart`) — being migrated to Supabase in Steps 6-13

### Navigation

GoRouter with auth redirect guards (`lib/app/router.dart`). Uses `refreshListenable` bridge pattern to avoid router recreation on auth state changes.

- Unauthenticated → `/welcome`
- Student authenticated → `/` (home with 4-tab bottom nav)
- Moderator authenticated → `/moderator`

### Data Layer

- **Supabase (live):** Auth (sign up, sign in, sign out), student profiles, school code validation, password change
- **Mock (legacy):** Courses, modules, quizzes, submissions, community, leaderboard — still in `lib/mock/`. Being migrated feature-by-feature.
- **Data models:** `lib/data/models/` — Dart classes with `fromJson`/`toJson` for all 14 DB tables
- **Repositories:** `lib/data/repositories/` — Supabase query layer (`auth_repository.dart`, `student_repository.dart`)

### Domain Model

- **Schools** are onboarded by platform team with unique registration codes
- **Cohorts** map to grade ranges (Grades 3-4 through 11-12)
- **Courses** (5 per cohort) contain **Modules** (10 per course) that unlock sequentially
- Each module has a 20-mark MCQ quiz (10 questions x 2 marks); courses have an 80-mark final submission
- Module completion requires: lesson viewed + quiz passed (>=50%)
- Course score = avg(quiz scores)/20 + submission/80 = total/100
- Moderators grade submissions and reply to community posts
- Community is school-scoped — students only see peers from their own school

### Project Structure

```
lib/
  main.dart                    # Supabase.initialize + ProviderScope
  app/
    app.dart                   # MaterialApp.router (ConsumerWidget)
    router.dart                # GoRouter with auth guards
    theme.dart                 # Material 3 theme (Indigo seed)
  core/
    supabase/supabase_client.dart  # Supabase init + client getter
    constants.dart             # Table names, bucket names, RPC names
  data/
    models/                    # 13 Dart model classes (fromJson/toJson)
    repositories/              # Supabase query layer
  features/
    auth/                      # Auth screens + providers (Supabase-backed)
    student/                   # Student dashboard (partially migrated)
    courses/                   # Empty — pending Step 6
    quizzes/                   # Empty — pending Step 7
    submissions/               # Empty — pending Step 8
    community/                 # Empty — pending Step 9
    leaderboard/               # Empty — pending Step 10
    moderator/                 # Empty — pending Step 11
    notifications/             # Empty — pending Step 12
    settings/                  # Empty — pending Step 13
  screens/                     # Legacy screens (still using mock data)
  mock/                        # Legacy mock data (to be removed in Step 14)
supabase/
  src/schema/                  # 14 Drizzle ORM table definitions
  sql/                         # RLS policies, views, storage policies (5 SQL files)
  drizzle/                     # Auto-generated migration SQL
```

### Screen Organization

**Auth screens** (in `lib/features/auth/screens/`, Supabase-backed):
- Welcome → Login (student/moderator) → Registration (school code → profile) → Cohort Confirmation

**Student screens** (in `lib/screens/`, still using mock data):
- Home (4-tab bottom nav: Dashboard, Courses, Community, Leaderboard) → Course Detail → Module Lesson → Quiz → Settings → Change Password

**Moderator screens** (in `lib/screens/`, still using mock data):
- Dashboard → Submission Review → Community → Change Password

### Onboarding Model

- **Schools:** Platform team creates in Supabase Dashboard with registration code
- **Students:** Self-register via app using school code → auto-assigned cohort by grade
- **Moderators:** Platform team creates auth user + moderator row in Supabase Dashboard

### Theming

Material 3 with `ColorScheme.fromSeed()` using Indigo (`0xFF4F46E5`). Supports system light/dark mode.

## Dependencies

```yaml
dependencies:
  flutter, cupertino_icons
  supabase_flutter: ^2.8.0    # Backend, auth, storage
  flutter_riverpod: ^2.6.0    # State management
  go_router: ^14.8.0          # Declarative routing
  file_picker: ^8.1.0         # File uploads for submissions

dev_dependencies:
  flutter_test, flutter_lints: ^6.0.0
```

## Configuration

Supabase credentials are passed via `--dart-define-from-file=.env` (never hardcoded):
```
SUPABASE_URL=https://xxxx.supabase.co
SUPABASE_ANON_KEY=xxxx
```

VS Code launch config (`.vscode/launch.json`) auto-loads the `.env` file.

## Key Files

| File | Purpose |
|------|---------|
| `plan.md` | Build plan with progress tracking |
| `userplan.md` | Developer Supabase setup guide (12 steps) |
| `moderator.md` | Admin guide for onboarding schools + moderators |
| `docs/ai_learning_platform_product_spec.md` | Product spec (source of truth) |
