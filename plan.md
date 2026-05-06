# AI Education Platform — Build Plan & Progress Tracker

> **Last updated:** 2026-05-06
> **Overall progress:** Phase 3 in progress. Steps 1-11 + 13 done; Teen "builder energy" design system applied across all major screens (Indigo + Cyan + Space Grotesk via google_fonts); profile screen with 20-achievement engine; editable profile + email; Step 12 (notifications) is the only remaining Phase 3 item.

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
| Local Cache | Hive (offline learning content — courses, modules, lesson blocks) |
| Architecture | Feature-based folders (differs from spec's 4-layer recommendation — chosen for better scalability at this project size) |

---

## Offline Strategy (in-scope for MVP)

> **Rule:** Reads work offline, writes require internet.

| Feature | Offline? | Source |
|---------|----------|--------|
| Course list | Yes | Local cache (Hive) |
| Module lesson content | Yes | Local cache (Hive) |
| Module list + order | Yes | Local cache (Hive) |
| Quiz (questions, submit attempt) | No | Supabase (online only) |
| Final submission (file upload) | No | Supabase Storage (online only) |
| Community (threads, replies) | No | Supabase (online only) |
| Leaderboard | No | Supabase view (online only) |
| Notifications | No | Supabase (online only) |
| `lesson_viewed_at` / progress writes | No | Supabase (online only) |
| Auth (login, register, password) | No | Supabase (online only) |

**Sync model:** download-once. On login, fetch all courses + modules for the student's cohort into Hive. Re-sync on explicit pull-to-refresh or on next login. No background sync queue, no conflict resolution needed (cache is read-only).

**UI requirement:** quiz, submission, and community screens must check connectivity and show a friendly "Connect to internet" message when offline.

---

## Progress Overview

| Phase | Description | Status |
|-------|-------------|--------|
| Phase 1 | Drizzle Schema + Supabase Database | DONE |
| Phase 2 | Flutter Project Restructure | DONE |
| Phase 3 | Feature Implementation | IN PROGRESS |
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

- [x] Create `supabase/.env` with real DATABASE_URL
- [x] Run `npx drizzle-kit generate` to create migration SQL
- [x] Run `npx drizzle-kit push` to apply schema to Supabase DB
- [x] Verify all 14 tables in Supabase dashboard

### 1.4 RLS policies

- [x] Enable RLS on all tables (01_enable_rls.sql)
- [x] Create `is_moderator()` helper function (02_helper_functions.sql)
- [x] All RLS policies applied (03_rls_policies.sql) — includes anon read on schools + cohorts for registration
- [x] Storage policies applied (04_storage_policies.sql)
- [x] **Fix:** Added missing INSERT policy on `notifications` (`06_fix_notifications_insert.sql`) — original 03 only had SELECT + UPDATE, blocking moderator grading writes with 42501. Also patched into 03 for fresh setups.

### 1.5 Supabase database views/functions

- [x] Create `course_progress` view (05_views.sql)
- [x] Create `validate_school_code()` RPC function (05_views.sql)
- [x] Create `get_leaderboard` SQL function (`07_leaderboard.sql`) — ranks students by avg score across course_progress; supports cohort/school/course/overall scopes

### 1.6 Storage
- [x] Create `submissions` bucket in Supabase dashboard
- [x] Set policy: students upload to `{student_id}/{course_id}/`, moderators read all

### 1.7 Seed data
> Curriculum content is placeholder — final content authored separately

- [x] Seed 5 cohorts (Grades 3-4 through 11-12) — done via Table Editor
- [x] Seed sample schools with registration codes — done via Table Editor
- [x] Create `supabase/src/seed.ts` for repeatable seeding (idempotent per cohort+title)
- [x] Seed Grades 3-4 course "Introduction to AI" (5 modules, 50 quiz questions) — trial scope
- [ ] Seed remaining cohorts (Grades 5-6 through 11-12) — post-trial

---

## Phase 2 — Flutter Project Restructure

### 2.1 Dependencies
- [x] Add `supabase_flutter` to pubspec.yaml
- [x] Add `flutter_riverpod` to pubspec.yaml
- [x] Add `go_router` to pubspec.yaml
- [x] Add `file_picker` to pubspec.yaml
- [x] Add `hive` + `hive_flutter` to pubspec.yaml (offline learning cache)
- [x] Add `connectivity_plus` to pubspec.yaml (detect online/offline for quiz/submission/community gates)
- [x] Add `url_launcher` to pubspec.yaml (kept for potential future external opens; in-app viewer is now primary)
- [x] Add `flutter_pdfview` + `path_provider` to pubspec.yaml (in-app PDF rendering for submission review)
- [x] Add `google_fonts` to pubspec.yaml (Space Grotesk for the Teen design system)
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

- [x] `school.dart`
- [x] `student.dart`
- [x] `cohort.dart`
- [x] `course.dart`
- [x] `module.dart` (class name: `CourseModule` to avoid Dart keyword conflict)
- [x] `quiz_question.dart`
- [x] `quiz_attempt.dart`
- [x] `module_progress.dart`
- [x] `submission.dart`
- [x] `community_thread.dart`
- [x] `community_reply.dart`
- [x] `leaderboard_entry.dart` (maps to `course_progress` view)
- [x] `app_notification.dart`

### Step 4: Auth
> `lib/data/repositories/auth_repository.dart` + `lib/features/auth/`
>
> **School-first model (spec S13):** Students register under an onboarded school. Registration flow:
> 1. Student enters a school registration code (provided by school admin)
> 2. Code validates against `schools` table via `validate_school_code()` RPC
> 3. Student fills remaining fields (name, grade, guardian contact, email, password)
> 4. Cohort auto-assigned from grade
>
> Moderator accounts created via admin invite, not self-serve signup.

- [x] `auth_repository.dart` — signUp, signIn, signOut, onAuthStateChange, getUserRole
- [x] `student_repository.dart` — createProfile, getProfile, validateSchoolCode, getCohortForGrade
- [x] `auth_provider.dart` — AuthNotifier StateNotifier with AuthState (user, role, studentProfile)
- [x] Migrate `welcome_screen.dart` — routes to Login or Registration
- [x] Create `login_screen.dart` — email/password, isModerator flag, role validation
- [x] Migrate `registration_screen.dart` — 2-step flow: validate school code, then register
- [x] Migrate `cohort_confirmation_screen.dart` — uses Cohort model instead of MockCohort

### Step 5: Router
> `lib/app/router.dart`

- [x] Define all routes (auth: welcome, login, moderator-login, register, cohort-confirmation; student: home, course detail, module lesson, quiz, quiz result, submission, settings; moderator: dashboard, review)
- [x] Auth redirect guard — unauthenticated to `/welcome`, authenticated skip auth pages
- [x] Role-based routing — moderator → `/moderator`, student → `/`
- [x] Wire GoRouter into `app.dart` (MaterialApp.router + ConsumerWidget)
- [x] Migrate all auth screens from Navigator.push to context.push/context.go

### Bug fixes (post Step 5)

- [x] Fix `AuthState` name collision with Supabase's `AuthState` — prefixed with `supa.`
- [x] Fix router redirect race condition — router was recreated on every auth change, destroying nav stack. Fixed with `refreshListenable` bridge pattern.
- [x] Fix logout not clearing Supabase session — settings + moderator dashboard now call `signOut()` via Riverpod + navigate with GoRouter
- [x] Fix old `lib/screens/welcome_screen.dart` being loaded after logout — all logouts now use `context.go(AppRoutes.welcome)` to reach new welcome screen
- [x] Fix wrong creds showing no error — login screen stays on screen, shows error inline
- [x] Fix anon RLS on `cohorts` — added anon read policy for registration flow
- [x] Fix student dashboard showing "Hello, Student" — now reads real name from `authProvider`
- [x] Add `change_password_screen.dart` — available from student settings + moderator dashboard
- [x] Explicit `SignOutScope.local` on signOut + try/catch to clear state even on failure
- [x] Add `schoolName` + `cohortName` to `AuthState` — fetched from DB via `getSchoolName`/`getCohortName`
- [x] Student dashboard, community, leaderboard screens show real school/cohort names
- [x] Moderator dashboard community link → new drill-down `ModeratorCommunityScreen` (schools → threads → replies)
- [x] Router updated to pass `Course` + `CourseModule` via `extra` (replaces legacy MockCourse/MockModule types)

### Step 6: Courses + Modules (offline-first learning) — DONE
> `lib/data/repositories/` + `lib/core/cache/` + `lib/features/courses/`
>
> **Offline-first:** Course list + module list + lesson content_blocks work without internet. Progress writes (`lesson_viewed_at`) require internet — writes are online-only. Module progress cache falls back when offline so unlock state is preserved.

#### 6.1 Local cache infrastructure
- [x] Initialize Hive in `main.dart` (before runApp)
- [x] Create `lib/core/cache/learning_cache.dart` — boxes: `courses_by_cohort`, `modules_by_course`, `module_progress_by_student_course`, `learning_meta`
- [x] Create `lib/core/cache/learning_cache_provider.dart` — Riverpod provider
- [x] Create `lib/core/connectivity/connectivity_provider.dart` — `isOnlineProvider` via `connectivity_plus`
- [x] Create `lib/core/sync/learning_sync_service.dart` + provider — orchestrates sync

#### 6.2 Sync-on-login
- [x] `student_home_screen.dart` triggers `syncCohort(cohortId)` on first render when cache is empty
- [x] "Downloading your courses..." overlay during sync via `_SyncOverlay`
- [x] Gracefully handles partial sync (returns null on failure, UI falls back to empty state)

#### 6.3 Repositories (cache-first reads, online writes)
- [x] `course_repository.dart` — getCoursesForCohort reads cache-first; fetchRemoteCoursesForCohort used by sync
- [x] `module_repository.dart` — getModulesForCourse reads cache-first; markLessonViewed online-only
- [x] `module_repository.dart` — getProgressForCourseModules caches to Hive on success, falls back to cache on offline (fixes module unlock offline)

#### 6.4 Providers + screens
- [x] `course_providers.dart` — `myCoursesProvider`, `modulesForCourseProvider`, `moduleProgressForCourseProvider`
- [x] Migrate `course_list_screen.dart` — ConsumerWidget + pull-to-refresh + loading/empty/error states
- [x] Migrate `course_detail_screen.dart` — ConsumerWidget, real module list, cohort progress from Supabase (cache fallback), unlock via `quiz_passed_at`
- [x] Migrate `module_lesson_screen.dart` — content_blocks from cache; `lesson_viewed_at` written to Supabase only if online

#### 6.5 Offline auth persistence (post-Step 6)
- [x] Create `lib/core/cache/user_cache.dart` — caches userId + role + studentProfile + schoolName + cohortName
- [x] Update `auth_provider.dart` — cold start hydrates from Hive instantly; background refresh from Supabase when online; clears cache on signOut
- [x] Returning user opens app offline → routed straight to dashboard (Supabase session + app-level user state both persisted)

### Step 7: Quizzes (online only) — DONE
> `lib/data/repositories/quiz_repository.dart` + `lib/features/quizzes/`
>
> **Online-only:** Quiz questions and attempts are never cached. Screen gates entry on connectivity.

- [x] `quiz_repository.dart` — getQuestionsForModule, submitAttempt (inserts quiz_attempt + upserts module_progress: best score, quiz_passed_at, completed_at); returns `QuizSubmitResult` with isNewBest / previousBest
- [x] `quiz_providers.dart` — `quizQuestionsProvider` (FutureProvider.family)
- [x] Migrate `quiz_screen.dart` — ConsumerWidget, fetches questions online, connectivity gate with friendly offline message, submit button with loading state
- [x] Migrate `quiz_result_screen.dart` — score display, new-best banner, unlock messaging, retake flow
- [x] Fix race condition: quiz submission always guarantees `lesson_viewed_at` is set (defaults to now), eliminating dependency on fire-and-forget markLessonViewed
- [x] Fix invalidation: quiz_screen invalidates `moduleProgressForCourseProvider` immediately after successful submit (replaces unreliable invalidate-after-push pattern in course_detail)

### Step 8: Submissions (online only) — DONE
> `lib/data/repositories/submission_repository.dart` + `lib/features/submissions/`
>
> **Online-only:** File uploads require internet. Screen gates entry on connectivity.

- [x] `submission_repository.dart` — uploadFile to `{studentId}/{courseId}/{filename}` in Supabase Storage, createSubmission, getSubmission
- [x] `submission_repository.dart` — `createSignedUrl(storagePath, expiresIn)` for time-limited access; `downloadBytes(storagePath)` for in-app viewer
- [x] `submission_providers.dart` — `submissionRepositoryProvider`, `submissionForCourseProvider`
- [x] Migrate `final_submission_screen.dart` — real `file_picker` (pdf/txt/py/js/dart), upload to Storage, notes field, offline gate, "already submitted" view with grade display

### Step 9: Community (online only)
> `lib/data/repositories/community_repository.dart` + `lib/features/community/`
>
> **Online-only:** Threads, replies, and realtime updates require internet.

- [x] `community_repository.dart` — getThreads (school-scoped), getAllThreads (moderator), getSchoolsList, createThread, addReply, getReplies
- [x] `community_provider.dart` — AsyncNotifier with Supabase Realtime subscription for new threads
- [x] Migrate `community_screen.dart` — real threads/replies from Supabase, school isolation, moderator badges, pull-to-refresh, loading/empty/error states
- [x] Create `moderator_community_screen.dart` — drill-down: Schools list → School threads → Thread detail with reply
- [x] Fix `CommunityThread.fromJson` crash on aggregate count data
- [x] `AuthState` extended with `schoolName` + `cohortName` (fetched from DB on login)
- [x] Community + Leaderboard + Dashboard screens show real school/cohort names from auth provider
- [x] Add connectivity gate to community screens — reusable `OfflineGate` widget in `lib/core/connectivity/`, applied to `community_screen.dart` + `moderator_community_screen.dart`

### Step 10: Leaderboard (online only) — DONE
> `lib/data/repositories/leaderboard_repository.dart` + `lib/features/leaderboard/`
>
> **Online-only:** Rankings require server-side aggregation via SQL function.

- [x] `supabase/sql/07_leaderboard.sql` — `get_leaderboard(scope, cohort_id, school_id, course_id)` function that aggregates per-student score from `course_progress`, ranks via window function, returns `(student_id, student_name, score, rank)` rows. Score = avg of total_score_out_of_100 (falls back to avg_quiz_score × 5 when no graded submission yet).
- [x] `lib/data/models/leaderboard_rank.dart` — model for ranked rows
- [x] `leaderboard_repository.dart` — `getLeaderboard()` with `LeaderboardScope` enum (cohort/school/course/overall); also returns the current user's entry pre-extracted
- [x] `leaderboard_providers.dart` — `leaderboardProvider` family keyed by `LeaderboardQuery`; resolves cohort/school IDs from auth profile automatically
- [x] Migrate `leaderboard_screen.dart` — real ranked data from `get_leaderboard`, scope chips (Cohort/School/Course/Overall), dark "YOUR RANK" card with score + position out of total, TOP 3 cards, list of remaining ranks with current-user highlight, empty + error states, pull-to-refresh
- [x] Removed all references to `lib/mock/mock_data.dart` from the leaderboard screen — fully wired to Supabase

### Step 11: Moderator — DONE
> `lib/data/repositories/moderator_repository.dart` + `lib/features/moderator/`
>
> **Online-only:** All moderator operations hit Supabase live — no caching. Connectivity gate on dashboard, submission review, and community.

- [x] `lib/data/models/submission_detail.dart` — wraps `Submission` with joined `student.full_name` + `Course` from embedded PostgREST select
- [x] `moderator_repository.dart` — `getAllSubmissions`, `getPendingSubmissions` (both with embedded `students(full_name), courses(*)` joins), `getOpenDoubtsCount` (threads with no replies), `gradeSubmission` (updates `final_submissions` + inserts `notifications` row for student)
- [x] `moderator_providers.dart` — `allSubmissionsProvider`, `pendingSubmissionsProvider`, `openDoubtsCountProvider`, aggregated `moderatorStatsProvider`
- [x] Migrate `moderator_dashboard_screen.dart` — real stats (pending/graded/open doubts), pull-to-refresh, offline gate, real submission list, navigates to review screen + invalidates on return
- [x] Migrate `submission_review_screen.dart` — takes `SubmissionDetail`, publishes grade + feedback + `moderator_id` + `graded_at`, triggers `submission_graded` notification insert, offline gate, loading state
- [x] **In-app file viewer:** new `lib/features/submissions/screens/submission_file_viewer_screen.dart` — PDFs render inline via `flutter_pdfview` (downloaded bytes → temp file), text/code files (`.txt/.py/.js/.dart`) shown as monospace `SelectableText`. Replaces external URL launch.
- [x] **Real grading:** rubric fields start empty (no pre-filled values); 0–20 validation per category; "Publish Score" disabled until all four scores valid
- [x] Router updated — `submissionReview` route takes `detail: SubmissionDetail` (replaces legacy submission+course args)
- [ ] Cohort/school filters on dashboard — deferred post-trial (only 1 course for Grades 3-4 right now)

### Step 11.5: Design System Overhaul (Teen "builder energy") — DONE
> Indigo + Cyan + Space Grotesk · `lib/app/theme.dart` rewrite + per-screen polish

- [x] `theme.dart` rebuilt: `AppPalette` (indigo / cyan / ink / textSoft / border / primaryWash) + `AppRadii` + `AppText` helpers + Space Grotesk via `google_fonts`
- [x] Welcome screen — bold "Master AI. One module at a time." headline, chunky indigo icon
- [x] Login + Registration (4-step) screens — eyebrow labels, hint-styled inputs, indigo accents
- [x] Cohort confirmation — "COHORT ASSIGNED" eyebrow + ink-black stats card
- [x] Onboarding (3 slides) — `lib/features/onboarding/screens/onboarding_screen.dart`, "01/02/03" mono tag, indigo gradient hero with `step.N → loaded` caption, animated dot indicator, Next/Enter button
- [x] Student dashboard — dark "Continue Learning" hero card + radial blob + cyan progress bar + indigo Resume pill, 3-stat grid, course rows
- [x] Course list — colored card headers (top section indigo/cyan), bottom progress bar, scope chips (All / In progress / Completed / Not started)
- [x] Course detail — Progress card with avg score, module list with circle status indicators (indigo done / cyan NOW / lock), final-project tile
- [x] Module lesson — header progress bar, MODULE eyebrow, indigo-wash objective callout, content card
- [x] Quiz — square A/B/C/D markers, indigo selection border
- [x] Quiz result — dark hero score card with cyan accent + "NEW BEST" pill, retake/continue layout
- [x] Final submission — indigo-wash task callout, file picker tile, dark graded score card with feedback
- [x] Community + moderator community — connectivity gates, real threads/replies (already on Teen design via theme)
- [x] Profile — settings gear top-right, big indigo avatar, stat strip, achievements grid, activity bar chart
- [x] Settings — Account / Learning / Privacy sections, indigo toggle pills, "Sign out" red tile
- [x] Edit field screen + Change password — match the rest of the auth/settings flow (eyebrow labels, Spacer-pinned CTA)
- [x] Bottom nav: 5 tabs (Home, Courses, Discuss, Ranks, Profile), `indicatorColor: Colors.transparent` so selected tab shows colored icon + label without a pill

### Step 12: Notifications
> `lib/features/notifications/` (spec S18)
>
> MVP types: submission_graded, moderator_reply, continue_reminder

- [ ] `notification_repository.dart` — getNotifications(userId), markAsRead, createNotification
- [ ] `notification_provider.dart` — unread count, notification list
- [ ] Add notification bell icon to student dashboard header
- [ ] Notification list screen or bottom sheet
- [ ] Trigger notifications: on submission graded, on moderator reply

### Step 13: Settings + Student Dashboard + Profile — DONE
> `lib/features/student/providers/` + `lib/features/settings/` + `lib/features/student/screens/profile_screen.dart`

- [x] `dashboard_provider.dart` — aggregates myCoursesProvider + moduleProgressForCourseProvider into `DashboardData` with `modulesCompleted`, `coursesInProgress`, `coursesDone`, `totalCourses`, `averageQuizScore`, `streakDays`, `activityByDay`, `continueCourse`, `continueNextModuleIndex`
- [x] Migrate `student_dashboard_screen.dart` — Teen design (dark "Continue Learning" hero with cyan accent + radial blob, 3-stat grid, course rows with side bars), pull-to-refresh
- [x] Notification bell **removed** from dashboard header (Step 12 deferred — bell will return when notifications feature lands)
- [x] Build `lib/features/student/screens/profile_screen.dart` — big indigo avatar (2-letter initials), "Grade X · School", "COHORT N · NAME" eyebrow, 4-tile stat strip (modules / courses / avg / streak), 4×2 achievements grid, 30-day activity chart driven by real `quiz_attempts.attempted_at` dates
- [x] Build 20-achievement engine: `lib/data/models/achievement.dart` + `lib/features/student/providers/achievements_provider.dart`. Pulls from `quiz_attempts`, `final_submissions`, `community_threads`, `community_replies`. Each tile is tappable → bottom sheet with "How to unlock" / "How you earned it" copy.
- [x] Repo additions for achievements: `QuizRepository.getAllAttemptsForStudent`, `SubmissionRepository.getAllSubmissionsForStudent`, `CommunityRepository.getAuthorActivity` (threadCount + distinctRepliedThreads + activeDays)
- [x] Migrate `settings_screen.dart` — Account / Learning / Privacy sections, indigo toggle pills, red "Sign out" tile, "< Profile" back link
- [x] Editable Profile + Email: `lib/features/settings/screens/edit_field_screen.dart` (single-field editor with name vs email validation). Wired Profile + Email tiles in Settings to push the editor.
- [x] Repo additions for editing: `StudentRepository.updateFullName`, `AuthRepository.updateEmail`, `AuthNotifier.refreshProfile()` (re-pulls profile + cohort/school names + updates UserCache)
- [x] Create `change_password_screen.dart` — Supabase `updateUser` for password change (now restyled to match the Teen design)
- [x] Wire `student_home_screen.dart` — 5-tab nav (Home, Courses, Discuss, Ranks, Profile), no pill indicator behind selected tab

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
| 1 | Schema applied | All 14 tables visible in Supabase dashboard | [x] |
| 2 | Seed data | Query `courses` table — Grades 3-4 "Introduction to AI" present with 5 modules + 50 questions | [x] |
| 3 | Student registration | School code -> register -> row in `students` + `auth.users` | [x] |
| 4 | Student login | Login -> dashboard with real name | [x] |
| 5 | Course listing | Courses filtered by student's cohort (cache-first) | [x] |
| 6 | Lesson viewed | Open module -> `lesson_viewed_at` set in module_progress (online) | [x] |
| 7 | Quiz submission | Score in `quiz_attempts`, best score in module_progress | [x] |
| 8 | Module completion | Lesson viewed + quiz passed -> `completed_at` set, next unlocks | [x] |
| 9 | Course score | Avg quiz (normalized/20) + submission (/80) = total /100 | [ ] |
| 10 | File upload | Submission file in Storage bucket | [x] |
| 11 | Moderator grading | Grade -> `final_submissions.status=graded` + score + `notifications` row | [x] (RLS fix applied via 06_fix_notifications_insert.sql; full flow verified) |
| 12 | Community isolation | School A can't see School B threads | [x] |
| 13 | Leaderboard | Rankings match `get_leaderboard` RPC, scope chips work, current user highlighted | [x] (RPC needs to be deployed via 07_leaderboard.sql) |
| 14 | Notifications | Submission graded + moderator reply trigger notifications | [ ] |
| 15 | RLS enforcement | Student A can't access Student B's data | [ ] |
| 16 | Logout | Clears session, redirects to welcome | [x] |
| 17 | `flutter analyze` | Zero issues (except test/widget_test.dart — cleanup step) | [x] |
| 18 | Password change | Student + moderator can change password in-app | [x] |
| 19 | Community threads | Student can create thread + view replies from Supabase | [x] |
| 20 | Community replies | Student can reply to thread, reply saved in Supabase | [x] |
| 21 | Moderator community | Moderator sees schools list → school threads → can reply | [x] |
| 22 | School/cohort names | Dashboard, community, leaderboard show real names | [x] |
| 23 | Offline course list | Airplane mode after login → course list still loads from cache | [ ] |
| 24 | Offline lesson | Airplane mode → open module lesson → content renders from cache | [ ] |
| 25 | Offline quiz blocked | Airplane mode → tap Start Quiz → friendly "Connect to internet" message | [ ] |
| 26 | Offline submission blocked | Airplane mode → final submission → blocked with message | [ ] |
| 27 | Offline community blocked | Airplane mode → community → blocked with message | [x] (gate in place) |
| 28 | Sync on login | Fresh login → Hive populated with all cohort courses + modules | [x] |
| 29 | Manual re-sync | Pull-to-refresh on course list → Hive re-populated | [x] |
| 30 | Offline cold start | Kill app while logged in, airplane mode, reopen → lands on dashboard (no welcome) | [ ] |
| 31 | Offline module unlock | Pass quiz online → go offline → next module still unlocked in course detail | [ ] |
| 32 | Completion race | Take quiz immediately after viewing lesson → `completed_at` set correctly on first submit | [ ] |
| 33 | Invalidation after quiz | Pass quiz → pop to course detail → module shows "Done" without reopening app | [ ] |
| 34 | Dashboard stats | "Your Progress" shows real counts + per-course progress bars (no phantom courses) | [ ] |
| 35 | Module order | Course detail shows modules 1→5 in ascending order | [ ] |
| 36 | Offline dashboard | Dashboard renders instantly from cache when offline (no network timeout) | [ ] |
| 37 | Moderator offline gate | Moderator dashboard + review screen show OfflineGate when offline | [x] (gate in place) |
| 38 | Submission grading notification | Graded submission → student sees score on final submission screen + notifications row exists | [ ] |
| 39 | In-app PDF viewer | Moderator taps "Open submission file" on a PDF → renders inline via flutter_pdfview | [ ] |
| 40 | In-app text viewer | Moderator opens a `.py/.txt/.js/.dart` submission → contents render as selectable monospace text | [ ] |
| 41 | Rubric validation | Publish disabled until all 4 categories have valid 0–20 scores; helper text explains why | [ ] |
| 42 | Onboarding flow | After registration → cohort confirmation → 3 onboarding slides → home | [ ] |
| 43 | Profile screen | Tab loads real avatar/initials, real stats from dashboard, real activity chart from quiz_attempts dates | [ ] |
| 44 | Achievements engine | All 20 unlock predicates fire correctly; tap any tile shows modal with how-to-unlock or how-you-earned-it | [ ] |
| 45 | Edit profile | Settings → Profile → edit name → saves to `students.full_name` and refreshes auth state | [ ] |
| 46 | Edit email | Settings → Email → edit → triggers Supabase confirmation flow, snackbar instructs user to confirm | [ ] |
| 47 | Bottom nav 5 tabs | Home / Courses / Discuss / Ranks / Profile, no pill behind selected tab | [x] (in code) |
| 48 | Design system | All major screens render in Indigo + Cyan + Space Grotesk (Teen "builder energy") | [x] |

---

## Blockers & Notes

| Date | Item | Status |
|------|------|--------|
| 2026-04-13 | Need DATABASE_URL in `supabase/.env` to run migrations | DONE |
| 2026-04-13 | Curriculum content is placeholder — final content authored separately | NOTED |
| 2026-04-17 | Offline-first learning brought IN-SCOPE for MVP — course/module content cached via Hive; quiz/submission/community remain online-only | DECISION |
| 2026-04-14 | Supabase setup complete (tables, RLS, storage, auth, cohorts, schools, moderator) | DONE |
| 2026-04-14 | Student registration + login + logout working end-to-end with Supabase | DONE |
| 2026-04-14 | Moderator login + logout working end-to-end with Supabase | DONE |
| 2026-04-14 | Password change available for both students and moderators | DONE |
| 2026-04-14 | Courses/modules/quizzes still use mock data — need seed data or Steps 6-7 | DONE (2026-04-17) |
| 2026-04-14 | Community fully migrated to Supabase (student + moderator views) | DONE |
| 2026-04-14 | School/cohort names populated from DB on login | DONE |
| 2026-04-17 | Grades 3-4 trial course seeded (Introduction to AI, 5 modules, 50 questions) via `supabase/src/seed.ts` | DONE |
| 2026-04-17 | Steps 6-8 complete: offline course/module cache, quiz flow, submission flow | DONE |
| 2026-04-17 | Offline auth persistence: cached profile/role/school/cohort in Hive → app opens to dashboard offline | DONE |
| 2026-04-17 | Module progress cached in Hive → module unlock state preserved offline | DONE |
| 2026-04-17 | Fixed race: quiz submit always sets `lesson_viewed_at` → `completed_at` reliably set | DONE |
| 2026-04-17 | Fixed invalidation: quiz_screen invalidates progress provider after submit → UI updates without reopen | DONE |
| 2026-04-17 | Leaderboard, moderator grading, notifications, dashboard polish still use mock data | PARTIAL (Steps 11 + dashboard polish now done; leaderboard + notifications remain) |
| 2026-04-17 | Step 9 final task closed: reusable `OfflineGate` widget gates community + moderator community screens offline | DONE |
| 2026-04-17 | Step 11 complete: moderator dashboard + submission review migrated to Supabase; grading inserts `notifications` row | DONE |
| 2026-04-17 | Step 13 dashboard migrated: real `DashboardData` from Supabase, no more mock courses on student home | DONE (notification bell deferred to Step 12) |
| 2026-04-17 | Fixed module order bug (`.order()` defaulted to descending) across all repos; bumped `LearningCache` schema to v2 to purge reversed caches on next launch | DONE |
| 2026-04-17 | Offline UX: `moduleProgressForCourseProvider` short-circuits to cache when offline (no network timeout wait) via `preferCacheOnly` flag | DONE |
| 2026-04-17 | RLS bug fixed: notifications table had no INSERT policy → moderator grading 42501 errors. Added "Moderators can create notifications" policy (`06_fix_notifications_insert.sql` + patch in 03) | DONE |
| 2026-04-17 | In-app file viewer for moderator: PDFs render via `flutter_pdfview`, text/code files shown as `SelectableText` (replaces external URL launch) | DONE |
| 2026-04-17 | Real grading: rubric fields start empty, validate 0–20, "Publish Score" disabled until all four are valid | DONE |
| 2026-05-06 | Teen "builder energy" design system applied: Indigo + Cyan + Space Grotesk via google_fonts; all major screens (welcome, login, register, cohort, onboarding, dashboard, courses, course detail, lesson, quiz, quiz result, submission, leaderboard, profile, settings, edit field, change password) match the design | DONE |
| 2026-05-06 | Onboarding flow added: 3 info slides between cohort confirmation and home (only on registration path; returning login still goes straight to home) | DONE |
| 2026-05-06 | Profile tab built: avatar, stats, 20-achievement engine, 30-day activity bar chart driven by real `quiz_attempts.attempted_at` data | DONE |
| 2026-05-06 | 20-achievement engine: data sourced from `quiz_attempts`, `module_progress`, `final_submissions`, community thread+reply counts. Tappable tiles show "how to unlock" / "how you earned it" via modal bottom sheet | DONE |
| 2026-05-06 | Editable Profile + Email in Settings: pushes generic `EditFieldScreen`, validates client-side, calls `StudentRepository.updateFullName` / `AuthRepository.updateEmail`, refreshes cached auth state | DONE |
| 2026-05-06 | Step 10 (Leaderboard) complete: `get_leaderboard` SQL function in `07_leaderboard.sql`, repo + provider, screen wired to real data with scope chips, your-rank card, top 3, ranked list with current-user highlight, empty + error states | DONE |
| 2026-05-06 | 5-tab bottom nav (Home/Courses/Discuss/Ranks/Profile) with `indicatorColor: Colors.transparent` so selected tab matches design (no pill behind icon) | DONE |
| 2026-05-06 | Notification bell removed from dashboard header — Step 12 deferred; bell will return when notifications feature ships | DONE |
| 2026-05-06 | Cleanup: deleted 3 dead duplicate auth screens (`lib/screens/welcome_screen.dart`, `registration_screen.dart`, `cohort_confirmation_screen.dart`). Real ones live in `lib/features/auth/screens/` | DONE |
| 2026-05-06 | Curriculum mock kept on purpose — final content not yet authored. `lib/mock/` still contains `mockLeaderboardEntries` (no longer imported anywhere) and `app_state.dart` (legacy, unused). Safe to delete in Phase 4 | NOTED |
