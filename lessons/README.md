# Lessons

Per-user lessons files for the agent roster. Each user gets one file per agent, named after their resolved username.

## Why this exists

Lessons Learned used to live inline in each agent's main doc. That worked for one user. With multiple people forking and using the same agents, two problems showed up:

1. **Merge conflicts.** If two users both let agents auto-update the shared `neo.md`, every pull from upstream becomes a conflict to resolve.
2. **Preference bleed.** Lessons reflect what an *individual* user wants. They're not portable. Merging another developer's Lessons Learned into your fork actively makes the agent worse for you.

Per-user sidecar files solve both: the main agent doc (identity, principles, toolkit) stays shared and merges cleanly; lessons go into files only that user reads or writes.

## File naming

Files are named after the user's resolved identity. Agents resolve the name like this:

1. **`git config user.name`** — if it returns a non-empty value, use `lessons/<that name>.md`.
2. **`whoami`** — if git config is blank, fall back to the system username and warn the user once that they should set `git config --global user.name`.
3. **Refuse** — if even `whoami` fails (essentially impossible), agents do not log and tell the user.

Spaces in names are preserved (`lessons/Travis Uhle.md`). Filename matches the resolved string exactly.

## Schema

Each lessons file looks like this:

```markdown
# Lessons — <agent name> (for <user>)

<!-- Max 15 entries. See the Self-Updating Protocol in <agent>.md. -->

YYYY-MM-DD — Lesson, one or two sentences max.
  Why log: One sentence — why future-<agent> wouldn't figure this out on their own.

YYYY-MM-DD — ...
  Why log: ...
```

One file per (agent, user) pair. So Travis using Neo gets `lessons/Travis Uhle.md` scoped to Neo (the agent reads only its own entries — see the per-agent file convention below).

## Per-agent vs. per-user

The simplest model is **one file per user, all agents share it** — but that conflates lessons across roles. A better split: **one file per agent per user**, named `lessons/<user>--<agent>.md` (e.g. `lessons/Travis Uhle--neo.md`).

Agents follow this convention: when resolving their lessons file, they look for `lessons/<resolved name>--<agent>.md`. If that file doesn't exist, they create it silently on the first lesson and announce: "Creating your personal lessons file at `lessons/<name>--<agent>.md` since this looks like your first session."

## Git policy

This folder **is committed**, not gitignored. Reasons:
- Lessons sync across the user's own machines via git.
- The per-user filename means co-worker forks never collide.
- History is useful — `git log lessons/Travis\ Uhle--neo.md` shows how Neo's understanding of Travis evolved.

If you'd rather keep lessons local-only, add `lessons/` to `.gitignore` in your fork. The agents don't care.
