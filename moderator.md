# Onboarding Guide — Schools & Moderators

> This document describes how the platform team onboards schools and moderators onto the AI Education platform.
> These are admin-side operations — there is no self-serve signup for schools or moderators in MVP.

---

## Onboarding a School

### When to do this

Before students from a school can register on the platform, the school must be onboarded. Each school gets a unique registration code that students use to sign up.

### Steps

#### 1. Create the school record

1. Open **Supabase Dashboard** → **Table Editor** → select the `schools` table
2. Click **Insert Row**
3. Fill in the fields:

| Field | Value | Example |
|-------|-------|---------|
| `name` | Full school name | `Sunrise Public School` |
| `registration_code` | Unique, human-readable code | `SUNRISE-2026` |
| `is_active` | `true` | `true` |

4. Click **Save**

> Leave the `id` and `created_at` fields empty — they are auto-generated.

#### 2. Choose a registration code

The registration code should be:
- **Unique** — no two schools can share a code (the database enforces this)
- **Human-readable** — easy to type and share (e.g. `SUNRISE-2026`, `DIA-DELHI`, `GHS-2026`)
- **Not guessable** — avoid generic codes like `SCHOOL1` or `TEST`
- **Uppercase** — for consistency (the app should normalize to uppercase on input)

#### 3. Share the code with the school

Send the registration code to the school admin via email, phone, or any secure channel. Include:

- The registration code
- A brief instruction: *"Share this code with your students. They will enter it during registration on the AI Education app to join your school."*

#### 4. Verify

Run in the **SQL Editor**:

```sql
SELECT * FROM validate_school_code('SUNRISE-2026');
```

Should return the school's `id` and `name`.

---

### Deactivating a school

To prevent new registrations from a school without deleting existing data:

1. **Table Editor** → `schools` → find the school row
2. Set `is_active` to `false`
3. Click **Save**

Existing students remain unaffected. New students entering this school's code will be rejected.

---

## Onboarding a Moderator

### When to do this

Moderators are platform staff who grade submissions, moderate community discussions, and monitor student progress. They are created manually — there is no self-serve moderator signup.

### Steps

#### 1. Create the auth user

1. Open **Supabase Dashboard** → **Authentication** → **Users**
2. Click **Add User** → **Create User**
3. Fill in:

| Field | Value |
|-------|-------|
| Email | Moderator's email address |
| Password | A strong temporary password (min 8 characters) |
| Auto Confirm User | Check this box (skips email verification) |

4. Click **Create User**
5. The new user appears in the list — **copy the user's UUID** (the `id` column)

#### 2. Create the moderator profile

1. Open **Table Editor** → select the `moderators` table
2. Click **Insert Row**
3. Fill in:

| Field | Value | Example |
|-------|-------|---------|
| `id` | The UUID copied from step 1 | `a1b2c3d4-...` |
| `full_name` | Moderator's full name | `Priya Sharma` |
| `email` | Same email used in step 1 | `priya@example.com` |

4. Click **Save**

> The `id` must exactly match the auth user's UUID. This is how the app knows the user is a moderator.

#### 3. Share credentials

Send the moderator their login details:

- **Email:** the email used in step 1
- **Password:** the temporary password
- **Instruction:** *"Log in to the AI Education app using the Moderator Login option. Please change your password after first login."*

#### 4. Verify

Run in the **SQL Editor**:

```sql
SELECT * FROM moderators;
```

The new moderator should appear in the results.

---

### How role detection works

When a user logs in, the app determines their role:

```
User logs in with email + password
  → App checks: does user ID exist in `moderators` table?
    → YES → Route to Moderator Dashboard
    → NO  → Check `students` table
      → YES → Route to Student Dashboard
      → NO  → Show error (orphan auth user — no profile)
```

This means:
- A user is a **moderator** if their auth user ID has a row in the `moderators` table
- A user is a **student** if their auth user ID has a row in the `students` table
- If neither → the user has no profile and should be prompted to complete registration

---

### Removing a moderator

To remove a moderator's access:

1. **Table Editor** → `moderators` → delete the moderator's row
2. Optionally: **Authentication** → **Users** → find the user → **Delete User**

Deleting the `moderators` row is sufficient — the user will no longer be recognized as a moderator. Deleting the auth user prevents all login access.

---

## Quick Reference

### Onboard a school

```
Dashboard → Table Editor → schools → Insert Row
  → name: "School Name"
  → registration_code: "CODE-2026"
  → is_active: true
  → Save
  → Share code with school admin
```

### Onboard a moderator

```
Dashboard → Authentication → Add User
  → email + password
  → Copy UUID

Dashboard → Table Editor → moderators → Insert Row
  → id: [paste UUID]
  → full_name: "Name"
  → email: "email"
  → Save
  → Share credentials with moderator
```

---

## FAQs

**Q: Can a user be both a student and a moderator?**
A: No. The app checks the `moderators` table first. If the user exists there, they are routed as a moderator. Do not add the same user to both tables.

**Q: What if a moderator forgets their password?**
A: Go to **Authentication** → **Users** → find the user → use the "Send password reset" option. Or manually update their password.

**Q: Can I create multiple moderators?**
A: Yes. Repeat the onboarding steps for each moderator. There is no limit.

**Q: Can I assign a moderator to specific schools or cohorts?**
A: Not in MVP. All moderators have access to all students, submissions, and community threads. School/cohort-scoped moderator access is a post-MVP feature.

**Q: What happens if I enter a wrong UUID in the moderators table?**
A: The moderator won't be able to log in as a moderator. The `id` must exactly match the auth user's UUID. Delete the wrong row and re-insert with the correct UUID.
