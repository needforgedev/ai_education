# Stitch UI Generation Prompt - AI Education Platform

## Prompt

Design a complete mobile-first frontend UI system for a Flutter app called `AI Education Platform`, a cohort-based AI learning platform for school students from grades `3-12`.

The goal is to generate a polished, production-ready set of student and moderator app screens, components, layouts, design patterns, and interaction states that can be translated directly into Flutter frontend implementation.

Use this prompt as the source of truth for visual design, UX structure, and frontend coverage.

## Product Context

The app helps students learn artificial intelligence in an age-appropriate, structured format.

The product includes:

- grade-based cohort assignment
- school-aware registration
- cohort-specific AI courses
- module-by-module learning
- MCQ tests after every module
- final course submission activity
- moderated community discussion
- leaderboard-based motivation
- role-based views for students and moderators

There are `2` user roles:

- `Student`
- `Moderator`

There are `5` cohorts:

- grades `3-4`
- grades `5-6`
- grades `7-8`
- grades `9-10`
- grades `11-12`

Each cohort supports up to:

- `5` AI courses
- `10` modules per course

Each module has:

- lesson content
- a `20` mark MCQ quiz

Each course ends with:

- one final submission activity graded out of `80`

Each course score is:

- average module MCQ score normalized to `20`
- plus final submission score out of `80`
- total `100`

## Design Goal

Create a UI that feels:

- modern
- high-trust
- youth-friendly without feeling childish
- educational but not boring
- structured and easy to navigate
- safe and community-aware
- motivating through progress and achievement

The product should feel suitable for children, teens, moderators, and schools.

Avoid generic edtech dashboard visuals. The interface should feel intentional, premium, warm, and alive.

## Platform and Layout Constraints

- primary target is mobile Flutter app
- portrait-first design
- optimize for Android and iPhone first
- support responsive tablet adaptation later
- design should work cleanly for both smaller phones and large phones
- use card-based layouts with strong hierarchy
- use large touch-friendly targets
- reduce clutter for younger users
- preserve information density where needed for moderators

## Visual Direction

Create a visual language that blends:

- academic credibility
- optimistic learning energy
- structured progress
- safe social interaction

### Style Guidance

- Use a bright, confident, contemporary UI
- Avoid default corporate SaaS visuals
- Avoid overly cartoonish children-only styling
- Avoid dark-mode-first presentation for the base concept
- Use warm neutrals plus strong accent colors
- Make the product feel like a next-generation school learning app

### Color System

Define a consistent design token style color palette including:

- primary brand color
- secondary accent
- success
- warning
- danger
- info
- surface
- background
- muted text
- strong text
- leaderboard highlight colors
- cohort or course accent colors if useful

The palette should work for:

- progress bars
- score cards
- badges
- quiz states
- moderation states
- community posts

### Typography

Choose a clear and distinctive type system.

Guidance:

- avoid default system-looking typography
- prioritize readability for children and teens
- use a confident heading font paired with a highly readable body font
- establish hierarchy for titles, sections, cards, scores, and helper text

### Components and Motion

Use:

- rounded cards
- subtle elevation
- progress indicators
- segmented controls
- score chips
- discussion pills
- leaderboard rows
- submission status cards
- cohort badges
- module completion markers

Motion should be:

- subtle
- meaningful
- used for progress, transitions, completion, and feedback
- not distracting or overly playful

## Brand Feel

The app should visually communicate:

- learn
- progress
- compete
- discuss
- achieve

It should feel credible enough for schools, exciting enough for students, and organized enough for moderators.

## Information Architecture

Design the app structure for the following primary navigation areas for students:

- Home
- Courses
- Community
- Leaderboard
- Profile or Settings

Design the moderator navigation for:

- Dashboard
- Students
- Submissions
- Community
- Leaderboard
- Settings

## Student UX Flows to Cover

Generate screens and UI states for the complete student journey:

1. welcome
2. login
3. registration
4. grade selection
5. school selection or entry
6. cohort assignment confirmation
7. student dashboard
8. course listing
9. course detail
10. module lesson screen
11. lesson content sections
12. ask doubt interaction
13. module MCQ quiz
14. quiz result
15. course progress summary
16. final submission upload
17. submission success state
18. course score result
19. community feed
20. discussion thread
21. create new doubt post
22. leaderboard filters and list
23. profile or settings

## Moderator UX Flows to Cover

Generate screens and states for:

1. moderator login
2. moderator dashboard
3. cohort filter
4. school filter
5. student list
6. student progress detail
7. pending submissions queue
8. submission review
9. rubric scoring form
10. publish score state
11. discussion moderation feed
12. thread review
13. reply as moderator
14. hide or flag content action states
15. leaderboard overview
16. moderator settings

## Required Student Screens

Design all of the following:

### 1. Splash Screen

- app branding
- loading state

### 2. Welcome Screen

- student login
- student registration
- moderator login

### 3. Student Registration

Fields:

- full name
- grade
- school
- parent or guardian contact
- email or phone
- password or OTP flow affordance

### 4. Cohort Confirmation

- show assigned cohort based on grade
- explain that content is tailored to the student level
- clear CTA into dashboard

### 5. Student Dashboard

Include:

- welcome header
- current cohort
- school name
- continue learning card
- in-progress courses
- completed modules count
- current rank
- recent scores
- pending final submission or recently graded item if applicable
- quick access to community and leaderboard

### 6. Courses Screen

Include:

- assigned courses
- progress percentage
- locked or unlocked state
- course cards by cohort

### 7. Course Detail Screen

Include:

- course title and summary
- score weight breakdown
- module list
- module completion states
- current average quiz score
- unlock state for final submission

### 8. Module Lesson Screen

Include:

- module title
- objective
- lesson sections
- illustrations or content cards
- recap box
- ask doubt CTA
- next action CTA

### 9. Module Quiz Screen

Include:

- question count
- progress indicator
- MCQ options
- selected state
- submitted state
- timer only if appropriate, but default to untimed in MVP visuals

### 10. Quiz Result Screen

Include:

- score out of 20
- correct vs incorrect feel
- encouragement
- next module unlock

### 11. Final Submission Screen

Include:

- assignment title
- instructions block
- upload area
- optional notes area
- status chip
- score weight indicator

### 12. Submission Status Screens

Design states for:

- not started
- uploaded and pending review
- reviewed and scored

### 13. Community Feed

Include:

- posts by students and moderators
- course or cohort filters
- ask a doubt composer
- pinned posts
- moderator identity markers

### 14. Discussion Thread

Include:

- original post
- threaded replies
- moderator replies highlighted
- reply composer
- report action

### 15. Leaderboard Screen

Include:

- filter tabs or chips
- by course
- by cohort
- by school
- overall
- ranked list
- current user highlight
- score display

### 16. Profile / Settings

Include:

- student info
- cohort
- school
- notification preferences
- help
- logout

## Required Moderator Screens

### 1. Moderator Login

- clean professional entry

### 2. Moderator Dashboard

Include:

- pending submissions count
- open doubts count
- active students
- cohort and school quick filters
- action cards

### 3. Students List

Include:

- searchable list
- cohort filters
- school filters
- progress snapshot per student

### 4. Student Detail View

Include:

- enrolled courses
- module progress
- quiz averages
- submission history
- discussion participation

### 5. Submission Review Queue

Include:

- pending items
- student name
- course name
- submission timestamp
- status

### 6. Submission Review Screen

Include:

- student metadata
- submission preview area
- rubric score inputs
- feedback notes
- publish score button

### 7. Community Moderation Screen

Include:

- flagged or recent posts
- moderator response actions
- hide or resolve actions

### 8. Moderator Leaderboard View

Include:

- cohort filter
- school filter
- performance comparisons

## Important UI States to Include

Design every major screen with realistic states:

- loading
- empty
- success
- error
- locked
- completed
- pending review
- graded
- no discussions yet
- no leaderboard data yet

## Components to Design

Create reusable design components for:

- cohort badge
- course card
- module list row
- progress bar
- quiz option card
- result card
- submission status chip
- file upload panel
- leaderboard row
- student avatar or identity tile
- moderator badge
- discussion post card
- reply bubble
- filter chips
- tab bars
- notification card
- stats card

## Product Logic to Reflect in the UI

The frontend must visually reflect these rules:

- students are assigned to cohorts by grade
- courses belong to cohorts
- modules are sequential
- each module ends in a quiz out of 20
- quizzes contribute an average out of 20 toward the course score
- final submission contributes 80 toward the course score
- the total course score is always out of 100
- final submission is unlocked only after all modules are completed
- moderators review final submissions
- community is moderated
- leaderboards can be filtered by multiple criteria

## UX Tone by Age Range

The same product serves grades `3-12`, so make the design system flexible enough that:

- younger cohorts feel guided and approachable
- older cohorts feel respected and not treated like very young children
- the shared system still looks unified

You may show this by using:

- adaptable illustrations
- content density variations
- scalable card designs
- subtle cohort accent treatments

## Screen Content Style

Use realistic placeholder content related to AI education such as:

- What is AI?
- AI in daily life
- How machines learn from examples
- Safe use of AI tools
- Bias and fairness basics
- Prompting basics

Do not use lorem ipsum.

## Community Safety Design Requirements

The community UI should visibly support safety:

- moderator labels on official replies
- report button on posts
- no private chat UI
- clear thread ownership
- safe, academic discussion tone

## Leaderboard Design Requirements

Leaderboard designs should:

- feel motivating, not harsh
- highlight the current student
- show filters clearly
- work for course, cohort, school, and overall views
- support score-based ranking

Optional enhancements:

- achievement icons
- upward or downward movement indicators

## Frontend Output Expectations

Generate a comprehensive design system and frontend screen set that includes:

- visual direction
- color palette
- typography system
- spacing rules
- UI components
- navigation patterns
- complete student screens
- complete moderator screens
- state variations
- mobile-ready layouts
- polished educational branding

## Implementation Intent

The output should be suitable for handoff to Flutter frontend development.

Favor:

- reusable components
- clean hierarchy
- implementable layouts
- clear interaction states
- consistent styling patterns

Do not create only a few hero screens. Generate a complete app frontend concept that covers the main product experience end to end.

## Reference Product Scope

Use the product scope described in this product spec as the functional source of truth:

- [ai_learning_platform_product_spec.md](/Users/nabeelshaikh/Documents/OCG/mobile-flutter-apps/ai_education/docs/ai_learning_platform_product_spec.md)

The generated UI should reflect the structure, flows, roles, assessment model, moderation model, and MVP priorities from that document.

## Final Instruction

Design this as if it is a real launchable edtech mobile app:

- ambitious but implementable
- beautiful but structured
- friendly but credible
- safe for minors
- optimized for learning, progression, and moderation

Generate the complete frontend UI direction and key screens for both student and moderator experiences.
