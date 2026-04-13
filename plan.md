# AI Education Platform — Build Plan & Progress Tracker

> **Last updated:** 2026-04-13
> **Overall progress:** Phase 2 done, starting Phase 3 (Step 3 of 16)

---

## Tech Stack

| Layer | Choice |
|-------|--------|
| Backend / Auth / DB | Supabase (project already created) |
| Schema & Migrations | Drizzle ORM (TypeScript), monorepo `supabase/` folder |
| State Management | Riverpod |
| Routing | GoRouter (declarative, auth-guarded) |
| File Uploads | Supabase Storage |
| Realtime | Supabase Realtime (community feature) |
| Architecture | Feature-based folders (differs from spec's 4-layer recommendation — chosen for better scalability at this project size) |

---

## Progress Overview

| Phase | Description | Status |
|-------|-------------|--------|
| Phase 1 | Drizzle Schema + Supabase Database | IN PROGRESS |
| Phase 2 | Flutter Project Restructure | DONE |
| Phase 3 | Feature Implementation | NOT STARTED |
| Phase 4 | Polish & Cleanup | NOT STARTED |

---

## Phase 1 — Drizzle Schema + Supabase Database

### 1.1 Schema project setup
> `supabase/` folder at project root

- [x] Create `package.json` with drizzle-orm, drizzle-kit, postgres, dotenv
- [x] Create `tsconfig.json`
- [x] Create `drizzle.config.ts`
- [x] Create `.env.example` with DATABASE_URL template
- [x] Add `supabase/.env`, `supabase/node_modules/` to `.gitignore`
- [x] Run `npm install`

### 1.2 Schema files
> `supabase/src/schema/` — 14 tables total

- [x] `enums.ts` — user_role, submission_status, course_progress_status
- [x] `schools.ts` — id, name, registration_code (unique), is_active, created_at
- [x] `cohorts.ts` — id, name, min_grade, max_grade, is_active
- [x] `students.ts` — id (FK auth.users), full_name, email, grade, school_id, cohort_id, guardian_contact, joined_at
- [x] `moderators.ts` — id (FK auth.users), full_name, email
- [x] `courses.ts` — id, cohort_id, title, description, module_count, icon, order_index, is_published
- [x] `modules.ts` — id, course_id, title, objective, content_blocks (jsonb), order_index
- [x] `quiz_questions.ts` — id, module_id, question, options (jsonb), correct_index, order_index
- [x] `quiz_attempts.ts` — id, student_id, module_id, score_out_of_20, answers, attempted_at (indexed)
- [x] `module_progress.ts` — id, student_id, module_id, lesson_viewed_at, quiz_passed_at, best_quiz_score, completed_at (unique constraint on student+module)
- [x] `final_submissions.ts` — id, student_id, course_id, file_url, file_name, file_type, notes, status (pending/graded), score_out_of_80, moderator_id, moderator_feedback, graded_at
- [x] `community_threads.ts` — id, school_id, course_id, module_id (nullable), author_id, author_name, title, body, is_moderator_post, is_pinned, is_hidden, created_at
- [x] `community_replies.ts` — id, thread_id, author_id, author_name, body, is_moderator_reply, is_hidden, created_at
- [x] `notifications.ts` — id, user_id, type, title, body, data (json), is_read, created_at (indexed)
- [x] `index.ts` — barrel export

### 1.3 Apply to Supabase
> Blocked — needs DATABASE_URL in `supabase/.env`

- [ ] Create `supabase/.env` with real DATABASE_URL
- [ ] Run `npx drizzle-kit generate` to create migration SQL
- [ ] Run `npx drizzle-kit push` to apply schema to Supabase DB
- [ ] Verify all 14 tables in Supabase dashboard

### 1.4 RLS policies
> Apply after schema is pushed

- [ ] Students: read own profile, read all courses/modules/questions, read/write own quiz_attempts & module_progress & submissions, read/write community scoped to own school, read own notifications
- [ ] Moderators: read all students, read/write all submissions (grading), read/write all community (moderation), read all quiz_attempts, insert notifications for students
- [ ] Public: no access
- [ ] Enable RLS on all tables

### 1.5 Supabase database views/functions
> Needed for CourseProgress + Leaderboard (spec S9, S12, S20)

- [ ] Create `course_progress` view — per student per course: completed_module_count, avg_quiz_score (best scores, normalized to 20), final_submission_score, total_score_out_of_100, completion_status
- [ ] Create `leaderboard_ranked` function/view — ranked by total_score, filterable by course_id, cohort_id, school_id

### 1.6 Storage
- [ ] Create `submissions` bucket in Supabase dashboard
- [ ] Set policy: students upload to `{student_id}/{course_id}/`, moderators read all

### 1.7 Seed data
> Curriculum content is placeholder — final content authored separately

- [ ] Create `supabase/src/seed.ts`
- [ ] Seed 5 cohorts (Grades 3-4 through 11-12)
- [ ] Seed sample schools
- [ ] Seed courses per cohort (placeholder content from current mock data)
- [ ] Seed modules per course (placeholder content)
- [ ] Seed quiz questions per module (placeholder content)
- [ ] Run `npx tsx src/seed.ts` and verify data

---

## Phase 2 — Flutter Project Restructure

### 2.1 Dependencies
- [x] Add `supabase_flutter` to pubspec.yaml
- [x] Add `flutter_riverpod` to pubspec.yaml
- [x] Add `go_router` to pubspec.yaml
- [x] Add `file_picker` to pubspec.yaml
- [x] Run `flutter pub get`

### 2.2 App shell
- [x] Create `lib/app/theme.dart` — extract theme from current `main.dart`
- [x] Create `lib/app/app.dart` — MaterialApp with theme (router wired in Step 5)
- [x] Create `lib/core/supabase/supabase_client.dart` — Supabase init helper
- [x] Create `lib/core/constants.dart` — table names, bucket names, Supabase URL/key via --dart-define
- [x] Update `lib/main.dart` — async Supabase.initialize + ProviderScope wrapping App

### 2.3 Directory structure
- [x] Create `lib/data/models/`
- [x] Create `lib/data/repositories/`
- [x] Create `lib/features/` with subfolders: auth, student, courses, quizzes, submissions, community, leaderboard, moderator, settings, notifications
- [x] Each feature has `screens/` and `providers/` subfolders

---

## Phase 3 — Feature Implementation

### Step 3: Data models
> `lib/data/models/` — Dart classes with fromJson/toJson

- [ ] `student.dart`
- [ ] `cohort.dart`
- [ ] `course.dart`
- [ ] `module.dart`
- [ ] `quiz_question.dart`
- [ ] `quiz_attempt.dart`
- [ ] `module_progress.dart`
- [ ] `submission.dart`
- [ ] `community_thread.dart`
- [ ] `community_reply.dart`
- [ ] `leaderboard_entry.dart`
- [ ] `app_notification.dart`

### Step 4: Auth
> `lib/data/repositories/auth_repository.dart` + `lib/features/auth/`
>
> **School-first model (spec S13):** Students register under an onboarded school. Registration flow:
> 1. Student enters a school registration code (provided by school admin)
> 2. Code validates against `schools` table and pre-selects the school
> 3. Student fills remaining fields (name, grade, guardian contact, email, password)
> 4. Cohort auto-assigned from grade
>
> Moderator accounts created via admin invite, not self-serve signup.

- [ ] `auth_repository.dart` — signUp, signIn, signOut, onAuthStateChange stream
- [ ] `student_repository.dart` — create/fetch student profile, validate school code
- [ ] `auth_provider.dart` — Riverpod provider for auth state + current user
- [ ] Migrate `welcome_screen.dart` to use Supabase auth
- [ ] Create `login_screen.dart` (new — email/password, role selection)
- [ ] Migrate `registration_screen.dart` — school code entry + real signUp + insert student row
- [ ] Migrate `cohort_confirmation_screen.dart` — read cohort from DB

### Step 5: Router
> `lib/app/router.dart`

- [ ] Define all routes (auth, student, courses, quiz, community, leaderboard, moderator, settings)
- [ ] Auth redirect guard — unauthenticated to `/auth/welcome`, authenticated skip auth pages
- [ ] Role-based routing — student vs moderator dashboards
- [ ] Wire GoRouter into `app.dart`

### Step 6: Courses + Modules
> `lib/data/repositories/` + `lib/features/courses/`

- [ ] `course_repository.dart` — getCoursesForCohort(cohortId)
- [ ] `module_repository.dart` — getModulesForCourse(courseId), getModuleProgress(studentId, moduleId)
- [ ] `course_provider.dart` — FutureProvider for courses
- [ ] `module_provider.dart` — FutureProvider for modules + progress
- [ ] Migrate `course_list_screen.dart` — fetch from Supabase
- [ ] Migrate `course_detail_screen.dart` — real module list + progress from module_progress table
- [ ] Migrate `module_lesson_screen.dart` — content_blocks from DB, mark lesson_viewed_at on view

### Step 7: Quizzes
> `lib/data/repositories/quiz_repository.dart` + `lib/features/quizzes/`

- [ ] `quiz_repository.dart` — getQuestionsForModule, submitAttempt, getBestScore
- [ ] `quiz_provider.dart` — quiz state management
- [ ] Migrate `quiz_screen.dart` — fetch questions from DB, submit to quiz_attempts
- [ ] Migrate `quiz_result_screen.dart` — show score, update module_progress (quiz_passed_at, best_quiz_score, completed_at), unlock next module

### Step 8: Submissions
> `lib/data/repositories/submission_repository.dart` + `lib/features/submissions/`

- [ ] `submission_repository.dart` — uploadFile (Storage), createSubmission, getSubmission
- [ ] `submission_provider.dart`
- [ ] Migrate `final_submission_screen.dart` — file picker + upload to Supabase Storage + notes field

### Step 9: Community
> `lib/data/repositories/community_repository.dart` + `lib/features/community/`

- [ ] `community_repository.dart` — getThreads (school-scoped), createThread, addReply, hidePost, pinThread
- [ ] `community_provider.dart` — with Supabase Realtime subscription
- [ ] Migrate `community_screen.dart` — real threads/replies, school isolation, moderator badges

### Step 10: Leaderboard
> `lib/data/repositories/leaderboard_repository.dart` + `lib/features/leaderboard/`

- [ ] `leaderboard_repository.dart` — getLeaderboard with filters (course, cohort, school, overall)
- [ ] `leaderboard_provider.dart`
- [ ] Migrate `leaderboard_screen.dart` — real ranked data from course_progress view, highlight current student

### Step 11: Moderator
> `lib/features/moderator/`

- [ ] `moderator_provider.dart` — pending submissions count, open threads, active students
- [ ] Migrate `moderator_dashboard_screen.dart` — real stats from DB, cohort/school filters
- [ ] Migrate `submission_review_screen.dart` — grade + publish score to DB + trigger notification

### Step 12: Notifications
> `lib/features/notifications/` (spec S18)
>
> MVP types: submission_graded, moderator_reply, continue_reminder

- [ ] `notification_repository.dart` — getNotifications(userId), markAsRead, createNotification
- [ ] `notification_provider.dart` — unread count, notification list
- [ ] Add notification bell icon to student dashboard header
- [ ] Notification list screen or bottom sheet
- [ ] Trigger notifications: on submission graded, on moderator reply

### Step 13: Settings + Student Dashboard
> `lib/features/settings/` + `lib/features/student/`

- [ ] `dashboard_provider.dart` — aggregate progress from course_progress view
- [ ] Migrate `student_dashboard_screen.dart` — real progress, continue learning, notification bell
- [ ] Migrate `student_home_screen.dart` — wire tabs to new feature screens
- [ ] Migrate `settings_screen.dart` — real logout via Supabase, profile from DB

---

## Phase 4 — Polish & Cleanup

### Step 14: Remove legacy code
- [ ] Delete `lib/mock/mock_data.dart`
- [ ] Delete `lib/mock/app_state.dart`
- [ ] Delete `lib/mock/` directory
- [ ] Delete `test/widget_test.dart`
- [ ] Remove old screen files from `lib/screens/` (now in `lib/features/`)

### Step 15: Remove unused platform folders
- [ ] Delete `windows/`
- [ ] Delete `linux/`
- [ ] Delete `macos/`
- [ ] Delete `web/`
- [ ] Delete `.idea/`
- [ ] Delete `*.iml` files

### Step 16: Documentation
- [ ] Update `CLAUDE.md` with new architecture, dependencies, folder structure
- [ ] Update `README.md` with project description and setup instructions
- [ ] Add Supabase setup instructions to README

---

## Content Block Schema (spec S21)
> Structure for `modules.content_blocks` JSONB field

Each block is an object with a `type` and type-specific fields:

```json
[
  { "type": "heading", "text": "What is AI?", "level": 1 },
  { "type": "paragraph", "text": "AI is the ability of..." },
  { "type": "bullet_list", "items": ["Point 1", "Point 2"] },
  { "type": "image", "url": "https://...", "caption": "An AI robot" },
  { "type": "example_card", "title": "Daily life example", "text": "..." },
  { "type": "recap_card", "points": ["Key idea 1", "Key idea 2"] }
]
```

MVP block types: `heading`, `paragraph`, `bullet_list`, `example_card`, `recap_card`
Future: `image`, `illustration`, `video_embed`

---

## Module Completion Rule (spec S8)
> A module is complete when ALL of these are true:

1. `lesson_viewed_at` is set in `module_progress` (student opened and viewed lesson content)
2. At least one `quiz_attempt` exists for this student+module
3. Best quiz score >= 10/20 (50% passing threshold)
4. `completed_at` is set in `module_progress`

Students may retake quizzes — best score is kept for course average and leaderboard.

---

## Course Score Formula (spec S9)

```
Course Score = Average(best module quiz scores) normalized to 20
             + Final Submission Score out of 80
             = Total out of 100
```

Implemented via `course_progress` Supabase view.

---

## Onboarding Flows (spec S13)

### School Onboarding (admin-side, no in-app UI)

Schools are provisioned by the platform team. No self-serve school signup.

| Step | Who | Action |
|------|-----|--------|
| 1 | Platform team | Creates school in Supabase Dashboard (Table Editor → `schools` → Insert Row) |
| 2 | Platform team | Sets `name`, `registration_code` (e.g. `SUNRISE-2026`), `is_active = true` |
| 3 | Platform team | Shares the registration code with the school admin (email, phone, etc.) |
| 4 | School admin | Distributes the code to students for self-registration |

The `registration_code` is a unique, human-readable string per school. It acts as the gate — only students with a valid code can register.

### Student Registration (in-app)

```
Student opens app → Register
  → Enters school registration code
    → App validates code against `schools` table
      → School name shown (read-only, not editable)
        → Student fills: name, grade, email, password, guardian contact
          → Cohort auto-assigned from grade
            → Cohort confirmation screen → Dashboard
```

Students cannot self-register without a valid school code. This enforces the school-first model.

### Moderator Onboarding (admin-side, no in-app signup)

Moderators are provisioned manually by the platform team. No self-serve signup.

| Step | Who | Action |
|------|-----|--------|
| 1 | Platform team | Creates auth user in Supabase Dashboard (Authentication → Add User → email + password) |
| 2 | Platform team | Inserts row in `moderators` table with the new user's `id`, `full_name`, `email` |
| 3 | Platform team | Shares login credentials with the moderator (email, Slack, etc.) |
| 4 | Moderator | Logs in via the app's Login screen with email + password |

The app determines the role at login by checking if the user's `id` exists in the `moderators` table. If yes → moderator dashboard. If no → check `students` table → student dashboard.

### Post-MVP Onboarding Enhancements

- Admin panel for bulk school/moderator creation
- Invite-by-email flow for moderators (Supabase `auth.admin.inviteUserByEmail()` via Edge Function)
- School admin role for managing their own students
- Bulk student import (CSV upload by school admin)

---

## Spec Contradictions (resolved)

| Section | Issue | Resolution |
|---------|-------|------------|
| S11 vs S20 | S11 says community is school-scoped; S20's CommunityThread originally used cohortId | Fixed — S20 updated to use `schoolId`. Schema uses `school_id`. |

---

## Verification Checklist

| # | Test | How to verify | Status |
|---|------|---------------|--------|
| 1 | Schema applied | All 14 tables visible in Supabase dashboard | [ ] |
| 2 | Seed data | Query `courses` table — rows present | [ ] |
| 3 | Student registration | School code -> register -> row in `students` + `auth.users` | [ ] |
| 4 | Student login | Login -> dashboard with real cohort/school | [ ] |
| 5 | Course listing | Courses filtered by student's cohort | [ ] |
| 6 | Lesson viewed | Open module -> `lesson_viewed_at` set in module_progress | [ ] |
| 7 | Quiz submission | Score in `quiz_attempts`, best score in module_progress | [ ] |
| 8 | Module completion | Lesson viewed + quiz passed -> `completed_at` set, next unlocks | [ ] |
| 9 | Course score | Avg quiz (normalized/20) + submission (/80) = total /100 | [ ] |
| 10 | File upload | Submission file in Storage bucket | [ ] |
| 11 | Moderator grading | Grade -> student sees score + notification | [ ] |
| 12 | Community isolation | School A can't see School B threads | [ ] |
| 13 | Leaderboard | Rankings match course_progress view | [ ] |
| 14 | Notifications | Submission graded + moderator reply trigger notifications | [ ] |
| 15 | RLS enforcement | Student A can't access Student B's data | [ ] |
| 16 | Logout | Clears session, redirects to welcome | [ ] |
| 17 | `flutter analyze` | Zero issues | [ ] |

---

## Blockers & Notes

| Date | Item | Status |
|------|------|--------|
| 2026-04-13 | Need DATABASE_URL in `supabase/.env` to run migrations | OPEN |
| 2026-04-13 | Curriculum content is placeholder — final content authored separately | NOTED |
| 2026-04-13 | Offline caching (spec S19) deferred to post-MVP | NOTED |
