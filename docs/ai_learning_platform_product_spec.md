# AI Education Platform - Product Spec

## 1. Product Summary

`AI Education Platform` is a cohort-based learning app for school students from grades `3-12`.

The product is designed to help children learn age-appropriate artificial intelligence concepts through:

- grade-based cohort assignment
- school-aware student registration
- structured AI courses
- module-wise assessments
- project-based final submissions
- moderated peer discussion
- leaderboard-driven motivation

The product should feel like a modern learning platform that is guided, measurable, safe for minors, and engaging enough to sustain repeat usage.

At a high level, the platform includes:

- `2` user roles at launch: `Student` and `Moderator`
- `5` academic cohorts
- up to `5` AI courses per cohort in the full product
- up to `10` modules per course in the full product
- `20` mark MCQ test after each module
- `80` mark final submission after course completion
- final score normalized to `100` per course
- community spaces for doubts and discussion
- leaderboards across multiple academic views

The MVP should focus on cohort placement, learning progression, assessments, moderation, and a lightweight community experience.

## 2. Product Goals

### Primary Goals

- Help students from grades `3-12` start learning AI through a structured, age-appropriate path.
- Make the learning experience organized enough for schools and simple enough for children.
- Ensure every course has measurable outcomes through quizzes and final submissions.
- Give moderators the tools to guide students, review work, and maintain quality.
- Build a safe academic community where students can learn from peers and moderators.

### Secondary Goals

- Create visible progress so students feel momentum.
- Encourage healthy competition through leaderboard systems.
- Support school-level grouping for future partnerships and reporting.
- Create a reusable curriculum framework that can expand cohort by cohort.

### Non-Goals for Initial Versions

- live video classes
- 1:1 student-to-student chat
- open social networking
- marketplace features
- unrestricted user-generated course creation
- complex AI tutoring that replaces the structured curriculum

## 3. Audience

### Primary Users

- students in grades `3-12`
- schools or academic programs onboarding student groups
- moderators managing learning, grading, and community health

### Age Bands

Use five cohorts aligned to school readiness:

- `Cohort 1`: grades `3-4`
- `Cohort 2`: grades `5-6`
- `Cohort 3`: grades `7-8`
- `Cohort 4`: grades `9-10`
- `Cohort 5`: grades `11-12`

### Adult Stakeholders

- moderators
- school coordinators in later phases
- parents or guardians as registration support for younger students

### Usage Context

- students may access learning from home or school
- typical learning sessions may range from `10-25` minutes
- younger cohorts need more guidance and clearer UI structure
- older cohorts can handle longer modules, deeper projects, and richer discussion

## 4. Product Principles

- `Cohort-first learning`: content difficulty and expectations must match student grade bands.
- `Simple progression`: students should always know what to do next.
- `Assessment with purpose`: tests should reinforce learning, not feel like punishment.
- `Moderator-guided safety`: all community interactions must be moderation-aware.
- `School-first model`: schools are onboarded first, then students join through their school.
- `Visible achievement`: students should see scores, completion, and rank in encouraging ways.
- `Low-friction start`: registration to first lesson should be short and clear.

## 5. Product Model

### Core Structure

The product hierarchy should be:

- school
- student
- cohort
- course
- module
- module assessment
- final submission
- leaderboard entries
- community threads

### User Roles

#### Student

- registers and joins the correct cohort
- consumes learning content
- completes module quizzes
- submits final course activities
- participates in moderated discussions
- views progress and leaderboard standings

#### Moderator

- reviews students by cohort and school
- manages course delivery quality
- grades final submissions
- replies to doubts and discussion threads
- moderates or removes unsafe/inappropriate content
- monitors participation and progress

### Future Roles Not Required in MVP

- school admin
- parent viewer
- super admin
- curriculum author

## 6. Cohort Structure

### Launch Cohorts

The platform should support five default cohorts:

- grades `3-4`
- grades `5-6`
- grades `7-8`
- grades `9-10`
- grades `11-12`

### Cohort Logic

Each student should be placed into a cohort automatically based on grade selected during registration.

### School Grouping

Each student profile should also carry school metadata so the system can support:

- school-specific filtering
- school-level reporting later
- school-level leaderboard segmentation
- moderation grouping

### Cohort Design Implications

Different cohorts should allow changes in:

- language complexity
- module depth
- project difficulty
- amount of visual support
- discussion expectations
- rubric strictness

## 7. Curriculum Structure

### Full Product Structure

Each cohort contains:

- `5` AI courses
- `10` modules in each course
- `50` total modules per cohort

Across all cohorts, the full structure would include:

- `25` total courses
- `250` total modules

### Recommended MVP Curriculum Scope

For MVP, do not ship the full curriculum immediately.

Recommended launch scope:

- `1-2` cohorts
- `2` courses per cohort
- `5-8` modules per course

This retains the curriculum model while reducing build and content load.

### Course Design Principles

- each course should teach one clear AI theme
- modules should progress from concept to application
- younger cohorts should use examples, visuals, and activities
- older cohorts can handle more structured concepts and projects

### Example Course Themes

Possible course families:

- Introduction to AI
- AI in Daily Life
- Prompting and Human-AI Interaction
- Responsible AI and Safety
- AI Projects and Problem Solving

The exact themes can vary per cohort while preserving increasing depth.

For MVP, sample course themes and module content will be used as placeholders. Final curriculum content will be authored separately by the platform team.

## 8. Module Structure

Each module should include:

- module title
- learning objective
- short lesson content
- visual examples or cards
- quick recap
- `20` mark MCQ test
- progress status

### Module Content Pattern

Recommended teaching sequence:

1. short introduction
2. concept explanation
3. examples or demonstrations
4. recap points
5. MCQ assessment

### Module Completion Rule

A module is considered complete when:

- lesson content is viewed
- quiz is attempted
- quiz is submitted
- a passing score of at least `50%` (`10 / 20`) is achieved

Students who score below `50%` may retake the quiz to improve their grade. The best score is used for the course average and leaderboard.

### Unlocking Rule

Modules unlock in sequence. A student must pass the current module quiz (minimum `50%`) to unlock the next module.

All `5` courses within a cohort are available from the start, but modules within each course are locked and unlock one by one as the student completes them.

Optional future enhancement:

- allow moderators to unlock modules manually

## 9. Assessment Model

### Per-Module Assessment

After every module, the student takes a quiz scored out of `20`.

Recommended properties:

- MCQ only in MVP
- auto-evaluated instantly
- visible score after submission
- review of incorrect answers in later versions
- minimum passing score: `50%` (`10 / 20`)
- retakes allowed — best score is kept for course average and leaderboard

### Per-Course Final Assessment

After all modules in a course are completed, the student unlocks a final submission-based assessment.

The final submission is graded out of `80`.

### Final Course Score

The overall course score should be:

- average of module quiz scores, normalized to `20`
- final submission score out of `80`
- total course score out of `100`

### Formula

```text
Course Score = Average(Module Quiz Scores) out of 20
             + Final Submission Score out of 80
             = Total out of 100
```

### Assessment Principles

- module quizzes check understanding immediately
- final submissions test synthesis and application
- scoring should feel transparent
- younger cohorts need simpler project formats and clearer rubrics

## 10. Final Submission Model

### Purpose

The final submission should test whether the student can apply concepts learned across the course.

### Possible Submission Types

- text response
- worksheet upload
- image upload
- slide or PDF upload
- short presentation summary
- structured project template

### Allowed File Types

For MVP, the platform will accept:

- `.pdf`
- `.txt`
- code files (e.g. `.py`, `.js`, `.dart`)

### MVP Recommendation

Start with file upload plus optional text note.

### Grading Model

Moderators manually grade submissions in MVP using a rubric.

### Rubric Categories

Suggested categories:

- concept understanding
- correctness
- creativity or application
- clarity of explanation
- completion of task requirements

### Grading Turnaround

There is no fixed SLA for moderator grading in MVP. Moderators grade submissions as they are able. A future version may introduce turnaround targets or notifications for pending reviews.

### Operational Note

Manual grading is feasible for MVP but will become a scaling bottleneck later. The system should be designed so rubric-assisted or AI-assisted review can be added in a future phase.

## 11. Community and Discussion

### Community Goal

Provide a safe space for students to:

- ask doubts
- discuss module topics
- learn from peers
- receive moderator guidance

### Community Structure

Communities are school-scoped. Students only see and interact with peers from their own school — the same classmates they learn with in school are their peers on the platform.

Recommended MVP structure:

- school-level community space
- course discussion threads within the school community
- module-specific question threads
- moderator announcements

### What Students Can Do

- create a discussion post
- reply in threads
- ask doubts from module pages
- react lightly in later versions

### What Moderators Can Do

- reply to questions
- pin useful posts
- delete or hide unsafe posts
- lock threads if needed

### Community Scope

- each school has its own isolated community
- students cannot see or interact with students from other schools
- this mirrors the real-world classroom dynamic and keeps the environment familiar and safe

### Community Safety Rules

- no direct messaging in MVP
- all content is moderation-visible
- reporting tools should exist from day one
- younger student safety takes priority over social richness

## 12. Leaderboards

### Purpose

Leaderboards should create motivation and measurable progress without becoming discouraging.

### Core Leaderboard Views

Recommended MVP leaderboard filters:

- by course
- by cohort
- by school
- overall performance

### Later Leaderboard Views

- by module
- by improvement
- by consistency
- by submission excellence

### Ranking Inputs

Leaderboard ranking can use:

- course score
- quiz completion rate
- overall average score
- number of completed modules

### Design Principles

- younger students should not feel punished for lower rank
- highlight personal progress alongside rank
- consider badges and achievement labels later

## 13. Registration and Onboarding

### Onboarding Model

The platform follows a school-first onboarding model. Schools are onboarded onto the platform first by the platform team. Once a school is onboarded, students can self-register using a school-specific registration code.

Students cannot self-register independently — they must have a valid school registration code.

### School Onboarding Flow

1. platform team contacts and onboards a school
2. platform team creates the school record in the database with a unique registration code (e.g. `SUNRISE-2026`)
3. platform team shares the registration code with the school admin
4. school admin distributes the code to students

Schools are created directly in the Supabase database by the platform team (no admin UI in MVP). Each school record includes:

- school name
- registration code (unique, human-readable)
- active status

### Student Registration Fields

Recommended launch fields:

- school registration code (validated against `schools` table — school name auto-populated, not editable)
- full name
- grade
- parent or guardian contact
- email
- password (minimum 8 characters)

### Registration Outcome

After registration:

- student account is created under the onboarded school (linked via registration code)
- cohort is assigned automatically based on grade
- school association is set from the validated registration code
- dashboard opens with the first recommended course

### First-Time Student Onboarding Flow

1. welcome screen
2. enter school registration code
3. app validates code and displays school name
4. complete profile (name, grade, email, password, guardian contact)
5. confirm assigned cohort
6. open dashboard

### Moderator Onboarding

Moderators are provisioned manually by the platform team. No self-serve signup.

Moderator onboarding flow:

1. platform team creates an auth user in Supabase (email + password)
2. platform team inserts a row in the `moderators` table with the user's id, name, and email
3. platform team shares login credentials with the moderator
4. moderator logs in via the app's login screen

Role detection at login:

- app checks if the authenticated user's id exists in the `moderators` table
- if yes: route to moderator dashboard
- if no: check `students` table and route to student dashboard

### Post-MVP Onboarding Enhancements

- admin panel for bulk school and moderator creation
- invite-by-email flow for moderators
- school admin role for managing students within a school
- bulk student import via CSV upload

## 14. Core Product Loop

1. Student registers.
2. System assigns cohort by grade.
3. Student lands on dashboard.
4. Student opens an available course.
5. Student studies the next unlocked module.
6. Student completes module quiz.
7. Progress updates immediately.
8. After all modules, final submission unlocks.
9. Moderator grades the submission.
10. Student receives final course score.
11. Leaderboard and progress views refresh.
12. Student participates in community discussion or starts the next course.

## 15. Screen-by-Screen Product Wireframes

These are low-fidelity planning wireframes for scope clarity, not final UI design.

### 15.1 Splash Screen

Purpose: branding and app initialization

```text
+--------------------------------------------------+
|                 AI EDUCATION APP                 |
|                 [logo animation]                 |
|                                                  |
|                  Loading...                      |
+--------------------------------------------------+
```

### 15.2 Welcome Screen

Purpose: product introduction and role entry

```text
+--------------------------------------------------+
| Learn AI Step by Step                            |
| Join your cohort and start learning              |
|                                                  |
|              [Student Login]                     |
|              [Student Register]                  |
|              [Moderator Login]                   |
+--------------------------------------------------+
```

### 15.3 Student Registration

Purpose: create student account

```text
+--------------------------------------------------+
| Create Student Account                           |
| Name:    [____________________]                  |
| Grade:   [ 7 v ]                                 |
| School:  [____________________]                  |
| Parent:  [____________________]                  |
| Email:   [____________________]                  |
|                                                  |
|                  [Continue]                      |
+--------------------------------------------------+
```

### 15.4 Cohort Confirmation

Purpose: confirm grade-based placement

```text
+--------------------------------------------------+
| You are in Cohort 3                              |
| Grades 7-8                                       |
|                                                  |
| Courses prepared for your level are ready.       |
|                                                  |
|                  [Go to Dashboard]               |
+--------------------------------------------------+
```

### 15.5 Student Dashboard

Purpose: primary learning hub

```text
+--------------------------------------------------+
| Hello, Aarav                                     |
| Cohort: Grades 7-8     School: Sunrise School    |
|--------------------------------------------------|
| Continue Learning                                |
| [AI Basics - Module 3 ready]                     |
|                                                  |
| Progress                                         |
| Courses In Progress: 2                           |
| Completed Modules: 6                             |
| Rank in Cohort: 14                               |
|                                                  |
| Nav: Home | Courses | Community | Leaderboard    |
+--------------------------------------------------+
```

### 15.6 Course List

Purpose: show cohort-assigned courses

```text
+--------------------------------------------------+
| My Courses                                       |
| [1] AI Basics                  60%               |
| [2] AI in Everyday Life        20%               |
| [3] Responsible AI             Locked            |
|                                                  |
|                  [Open Course]                   |
+--------------------------------------------------+
```

### 15.7 Course Detail

Purpose: show module list and course score structure

```text
+--------------------------------------------------+
| AI Basics                                        |
| Modules Completed: 4/10                          |
| Quiz Weight: 20      Final Project: 80           |
|--------------------------------------------------|
| Module 1  Complete                               |
| Module 2  Complete                               |
| Module 3  Complete                               |
| Module 4  Complete                               |
| Module 5  Ready                                  |
|                                                  |
|                [Start Module 5]                  |
+--------------------------------------------------+
```

### 15.8 Module Learning Screen

Purpose: deliver lesson content

```text
+--------------------------------------------------+
| Module 5: What Is Machine Learning?              |
| Objective: Understand how AI learns from data    |
|--------------------------------------------------|
| [illustration/video/card content]                |
| Key idea 1                                       |
| Key idea 2                                       |
| Example from daily life                          |
|                                                  |
|      [Ask Doubt]            [Next Section]       |
+--------------------------------------------------+
```

### 15.9 Module Quiz Screen

Purpose: MCQ assessment after the lesson

```text
+--------------------------------------------------+
| Quiz: Module 5                                   |
| Question 3 of 10                                 |
|                                                  |
| Which example best uses machine learning?        |
|                                                  |
| [A] Option A                                     |
| [B] Option B                                     |
| [C] Option C                                     |
| [D] Option D                                     |
|                                                  |
|                 [Submit Answer]                  |
+--------------------------------------------------+
```

### 15.10 Quiz Result Screen

Purpose: instant assessment feedback

```text
+--------------------------------------------------+
| Module Complete                                  |
| Score: 16 / 20                                   |
|                                                  |
| Great work. Module 6 is now unlocked.            |
|                                                  |
|                [Continue]                        |
+--------------------------------------------------+
```

### 15.11 Final Submission Screen

Purpose: collect course-end project work

```text
+--------------------------------------------------+
| Final Course Activity                            |
| Score Weight: 80                                 |
|--------------------------------------------------|
| Task: Create a simple AI use-case explanation    |
| Upload file: [Choose File]                       |
| Notes:       [__________________________]        |
|                                                  |
|                  [Submit Project]                |
+--------------------------------------------------+
```

### 15.12 Community Feed

Purpose: course or cohort discussion

```text
+--------------------------------------------------+
| Community - AI Basics                            |
| [Ask a doubt...]                                 |
|--------------------------------------------------|
| Riya: Can someone explain training data?         |
| Moderator: Training data is what AI learns from. |
| Omar: Is this like examples for the computer?    |
|                                                  |
|                [Open Thread]                     |
+--------------------------------------------------+
```

### 15.13 Leaderboard

Purpose: motivate through visible ranking

```text
+--------------------------------------------------+
| Leaderboard                                      |
| Filter: [Course v] [Cohort v] [School v]         |
|--------------------------------------------------|
| 1. Riya            92                            |
| 2. Aarav           89                            |
| 3. Meera           87                            |
|                                                  |
| Your Rank: 2                                     |
+--------------------------------------------------+
```

### 15.14 Moderator Dashboard

Purpose: operational hub for teaching staff

```text
+--------------------------------------------------+
| Moderator Dashboard                              |
| Cohort: Grades 7-8                               |
| Pending Submissions: 12                          |
| Open Doubts: 18                                  |
| Active Students Today: 46                        |
|                                                  |
| [Review Submissions] [Open Community]            |
+--------------------------------------------------+
```

### 15.15 Submission Review Screen

Purpose: rubric-based grading workflow

```text
+--------------------------------------------------+
| Review Submission                                |
| Student: Aarav                                   |
| Course: AI Basics                                |
|--------------------------------------------------|
| [Open uploaded file]                             |
| Understanding: [ /20 ]                           |
| Accuracy:      [ /20 ]                           |
| Application:   [ /20 ]                           |
| Clarity:       [ /20 ]                           |
|                                                  |
|               [Publish Score]                    |
+--------------------------------------------------+
```

### 15.16 Settings

Purpose: account and app preferences

```text
+--------------------------------------------------+
| Settings                                         |
| Profile                                          |
| Password → Change Password screen               |
| Notifications                                    |
| Help                                             |
| About                                            |
| Logout                                           |
+--------------------------------------------------+
```

The Change Password screen allows students and moderators to update their password in-app using `supabase.auth.updateUser()`. Requires new password (min 8 chars) + confirmation.

## 16. Moderator Experience

### Moderator Responsibilities

- monitor student activity
- answer academic doubts
- review and grade final submissions
- maintain healthy discussion behavior
- identify struggling students

### Moderator Workflow

1. log in
2. choose cohort and school filter
3. view pending submissions
4. grade and publish results
5. review unresolved discussion threads
6. moderate flagged content

### Moderator Efficiency Needs

The product should support:

- quick filtering by cohort and school
- fast access to pending grading queues
- clear student progress summaries
- basic moderation actions from discussion lists

## 17. Progression and Motivation Systems

### Core Progress Signals

- modules completed
- courses completed
- course scores
- rank in cohort
- streaks in later versions

### MVP Motivation Layer

The MVP does not need a complex game economy, but it should include:

- progress bars
- completion states
- rank visibility
- simple badges for course completion

### Later Motivation Ideas

- badges
- streak rewards
- school challenges
- cohort milestones
- certificates

## 18. Notifications and Reminders

### Useful Notification Types

- module unlocked
- quiz completed
- submission graded
- moderator replied to doubt
- leaderboard movement
- inactivity reminder

### MVP Recommendation

Limit to high-value notifications:

- submission graded
- new moderator reply
- reminder to continue course

## 19. Flutter Technical Spec

### Target Platforms

- Android phones
- iPhone
- tablets in later optimization passes

### Orientation

- portrait-first for students
- optional tablet-optimized moderator layouts later

### App Architecture

Use a clean layered architecture:

- `presentation`
- `application`
- `domain`
- `data`

### Suggested Project Structure

```text
lib/
  app/
    app.dart
    router.dart
    theme/
  core/
    auth/
    network/
    storage/
    analytics/
    widgets/
    utils/
  features/
    onboarding/
    student_dashboard/
    courses/
    modules/
    quizzes/
    submissions/
    community/
    leaderboard/
    moderator/
    settings/
  data/
    models/
    repositories/
    services/
```

### State Strategy

Keep feature state isolated and predictable:

- auth state
- user profile state
- cohort and course state
- module progress state
- quiz session state
- submission state
- community feed state
- leaderboard state
- moderator queue state

### Backend Expectations

The app will likely require backend services for:

- authentication
- cohort assignment
- user management
- course and module delivery
- quiz storage and scoring
- file upload for submissions
- leaderboard aggregation
- moderated discussion

### Offline Strategy

MVP can be online-first, but should cache:

- profile info
- course list
- recent module content
- latest progress state

## 20. Recommended Runtime Data Objects

### School

- id
- name
- registrationCode (unique, human-readable, e.g. `SUNRISE-2026`)
- isActive
- createdAt

### StudentProfile

- id
- fullName
- email
- grade
- cohortId
- schoolId
- guardianContact
- joinedAt

### Cohort

- id
- name
- minGrade
- maxGrade
- isActive

### Course

- id
- cohortId
- title
- description
- moduleCount
- isPublished
- orderIndex

### Module

- id
- courseId
- title
- objective
- contentBlocks[]
- quizId
- orderIndex

### ModuleQuizAttempt

- id
- studentId
- moduleId
- scoreOutOf20
- attemptedAt
- answers[]

### ModuleProgress

- id
- studentId
- moduleId
- lessonViewedAt
- quizPassedAt
- bestQuizScore
- completedAt

### FinalSubmission

- id
- studentId
- courseId
- fileUrl
- fileName
- fileType
- notes
- submittedAt
- status (pending, graded)
- scoreOutOf80
- moderatorId
- moderatorFeedback
- gradedAt

### Moderator

- id
- fullName
- email
- createdAt

### CourseProgress

- studentId
- courseId
- completedModuleCount
- averageQuizScoreOutOf20
- finalSubmissionScoreOutOf80
- totalScoreOutOf100
- completionStatus

### CommunityThread

- id
- schoolId (community is school-scoped per Section 11)
- courseId
- moduleId optional
- authorId
- authorName
- title
- body
- isModeratorPost
- isPinned
- isHidden
- createdAt

### CommunityReply

- id
- threadId
- authorId
- body
- createdAt
- isModeratorReply

### LeaderboardEntry

- studentId
- cohortId
- schoolId optional
- courseId optional
- metricType
- score
- rank

### Notification

- id
- userId
- type (submission_graded, moderator_reply, continue_reminder)
- title
- body
- data (contextual JSON — courseId, threadId, etc.)
- isRead
- createdAt

## 21. Content Management Requirements

### Content Needs

The curriculum system should support:

- multiple cohorts
- multiple courses per cohort
- multiple modules per course
- rich lesson content blocks
- per-module quiz authoring
- final submission instructions and rubric definitions

### Content Block Types

Recommended lesson block support:

- heading
- paragraph
- bullet list
- image
- illustration
- video embed in later versions
- example card
- recap card

### Authoring Needs

Even if a full internal CMS is not built for MVP, the data model should allow external content seeding and later admin publishing workflows.

## 22. Accessibility

- readable typography for children
- large tap targets
- clear progress indicators
- strong color contrast
- support for mixed reading levels
- audio support in later cohorts if needed
- reduced cognitive overload on lesson screens

## 23. Safety and Privacy

### Minor Safety

Because the users are children, the product must prioritize:

- moderated communication
- no direct private chat in MVP
- content reporting tools
- minimal profile exposure
- restricted personal information sharing

### Data Privacy

Collect only essential information:

- student name
- grade
- school
- login credentials
- guardian contact where needed

### Moderation Requirements

- all community content visible to moderators
- ability to hide or remove content quickly
- ability to suspend posting privileges later

## 24. Analytics to Track

### Acquisition and Onboarding

- registration completion rate
- onboarding drop-off by step
- cohort assignment distribution
- school distribution

### Learning Analytics

- active students per day
- modules started
- modules completed
- quiz completion rate
- average quiz score by module
- course completion rate
- submission completion rate

### Community Analytics

- doubts posted
- moderator response time
- thread resolution rate
- flagged posts count

### Leaderboard and Engagement

- leaderboard page visits
- return frequency after rank changes
- top-performing cohorts
- engagement by school

## 25. MVP Definition

### MVP Scope

Recommended MVP should include:

- student registration
- grade-based cohort assignment
- school capture during registration
- student dashboard
- `1-2` cohorts
- `2` courses per cohort
- `5-8` modules per course
- lesson content delivery
- module MCQ quiz after each module
- final submission upload
- moderator grading flow
- score calculation out of `100`
- basic course and cohort leaderboard
- basic community discussion by course
- moderator dashboard

### Not in MVP

- all `5` cohorts with full curriculum
- all `25` courses at once
- advanced gamification systems
- direct messaging
- live classes
- AI auto-grading
- school admin dashboards
- parent dashboards

## 26. Build Order

### Phase 1 - Foundations

- auth and role setup
- student registration
- grade-to-cohort assignment
- core data models
- app shell and navigation

### Phase 2 - Learning Core

- course listing
- module rendering
- progress tracking
- quiz engine

### Phase 3 - Assessment

- final submission flow
- moderator review queue
- score calculation logic

### Phase 4 - Community and Ranking

- course discussion spaces
- moderation controls
- leaderboard aggregation and display

### Phase 5 - Polish and Expansion

- notifications
- badges or certificates
- more cohorts
- more courses
- school-level reporting

## 27. Initialization Checklist

To start product development, prioritize:

- define cohort constants for grades `3-12`
- create student and moderator auth flows
- model courses, modules, quizzes, and submissions
- implement dashboard and course navigation
- build one end-to-end module flow
- build one quiz flow
- build one submission review flow
- build one leaderboard view
- build one discussion thread flow

## 28. Open Product Questions

These should be resolved early:

- ~~Will students choose their school from a managed list or enter it manually?~~ Resolved: schools are onboarded first, students are registered under their school.
- ~~Will the product launch direct-to-consumer, school-first, or both?~~ Resolved: school-first. Schools are onboarded, then schools register students.
- ~~What exact course themes belong in each cohort?~~ Resolved: sample content for MVP, final curriculum authored separately.
- ~~What file types are allowed for final submissions?~~ Resolved: `.pdf`, `.txt`, and code files (`.py`, `.js`, `.dart`).
- ~~How quickly should moderators be expected to grade submissions?~~ Resolved: no fixed SLA for MVP, moderators grade as they are able.
- ~~What happens if a student fails a module quiz or performs poorly overall?~~ Resolved: minimum passing score is `50%`. Students can retake quizzes, best score is kept.

## 29. Final Recommendation

The strongest MVP is not the full platform at once.

The recommended launch version is:

- `1-2` cohorts only
- `2` carefully designed AI courses per cohort
- strong module and assessment flow
- manual moderator grading
- simple moderated community
- clear leaderboard structure

This gives the product a real academic core while keeping scope manageable, measurable, and ready for expansion into the full cohort-based learning platform.
