# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Development Commands

```bash
flutter pub get          # Install dependencies
flutter analyze          # Run linter (flutter_lints 6.0)
flutter test             # Run widget tests
flutter run              # Launch app in debug mode
flutter test test/widget_test.dart  # Run a single test file
```

## Architecture

This is an AI education platform for K-12 students (grades 3-12) with two roles: **Student** and **Moderator**. Fully offline/mock-based with no backend.

### State Management

Single `AppState` ChangeNotifier singleton (`lib/mock/app_state.dart`) holds all application state: user registration, quiz scores, module completion, project submissions, community posts, and leaderboard data. Screens observe it via `ListenableBuilder`.

### Navigation

Imperative `Navigator` push/replace with `MaterialPageRoute` — no routing package or named routes.

### Data Layer

All data is mock/in-memory (`lib/mock/mock_data.dart`). Models use `const` constructors. No persistence, no HTTP client, no code generation.

### Domain Model

- **Cohorts** map to grade ranges (Grades 3-4 through 11-12)
- **Courses** (5 per cohort) contain **Modules** (10 per course) that unlock sequentially
- Each module has a 20-mark MCQ quiz (10 questions x 2 marks); courses have an 80-mark final submission
- Moderators grade submissions and reply to community posts

### Screen Organization

`lib/screens/` contains 16 StatefulWidget screens covering:
- Student flow: Welcome → Registration → Cohort Confirmation → Home (4-tab bottom nav: Dashboard, Courses, Community, Leaderboard) → Course Detail → Module Lesson → Quiz
- Moderator flow: Login → Dashboard → Submission Review → Community moderation

### Theming

Material 3 with `ColorScheme.fromSeed()` using Indigo (`0xFF4F46E5`). Supports system light/dark mode.

## Dependencies

Minimal: only `flutter`, `cupertino_icons`, and `flutter_lints`. No external state management, routing, networking, or code generation packages.
