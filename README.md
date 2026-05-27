# Agents

A personal roster of named AI agents, each with a specialized role and a self-maintained playbook. Designed to work across both Claude Code and Cursor.

---

## The Roster

| Agent | Role | Invocation |
|---|---|---|
| **Neo** | Senior Full-Stack Programmer | "Neo, ..." |
| **Morpheus** | Lead Graphic Designer (Product UI) | "Morpheus, ..." |

*Future agents will be added here as the team grows. Naming follows the Matrix theme — see [Naming Convention](#naming-convention) below.*

---

## How This Works

Each agent is a markdown file containing:

1. **Identity** — who they are, how they behave
2. **Core Principles** — non-negotiable working rules
3. **Default Toolkit / Stack** — preferred tools and conventions
4. **How They Work** — process and communication style
5. **What They Don't Do** — explicit handoff rules to other agents
6. **Self-Updating Protocol** — how they learn and evolve over time

Lessons themselves live in **per-user sidecar files** under [`lessons/`](lessons/) — one file per (user, agent) pair, named `lessons/<user>--<agent>.md` (e.g. `lessons/Travis Uhle--neo.md`). The main agent doc is shared across all users; lessons stay personal. See [Per-User Lessons](#per-user-lessons) below.

The agents update their own lessons files autonomously when they learn something worth remembering. Strict rules prevent doc bloat (see Self-Updating Protocol in each agent file).

---

## Installation

This repo is the canonical source of truth. The actual files used by Claude Code and Cursor live in tool-specific locations. Pick one of the two strategies below.

### Option A: Symlinks (recommended)

Symlinks mean edits sync instantly across all projects — you only ever edit the file here in this repo.

**Claude Code (global, all projects):**
```bash
# From the repo root
ln -s "$(pwd)/neo.md" ~/.claude/agents/neo.md
ln -s "$(pwd)/morpheus.md" ~/.claude/agents/morpheus.md
```

**Cursor (per-project, since Cursor has no global rules folder):**
```bash
# Run inside each project where you want the agents available
ln -s ~/path/to/agents/neo.md .cursor/rules/neo.mdc
ln -s ~/path/to/agents/morpheus.md .cursor/rules/morpheus.mdc
```

### Option B: Copy + sync script

If symlinks give you trouble (Windows, some sync tools), copy the files instead and use a script to re-sync when this repo updates. See [`scripts/sync.sh`](#) (create as needed).

---

## Project-Specific Overrides

The agents in this repo are **global** — they follow you everywhere. When a specific project needs different behavior, do **not** fork the global agent. Instead, add a project-local context file:

- **Claude Code:** `.claude/CLAUDE.md` in the project root (auto-loaded per-project)
- **Cursor:** `.cursor/rules/project-context.mdc` in the project root

Put project-specific stuff there:
- Stack overrides ("this codebase uses Vue, not React")
- Naming conventions ("we use snake_case here")
- Project-specific gotchas
- Domain context

The global agents read these and treat them as overrides. This keeps the global agents clean and stops project quirks from polluting the global "brain."

---

## Self-Updating Rules (Summary)

Each agent maintains a personal Lessons Learned file for the current user. The rules:

- **Autonomous updates, no per-entry approval** — agents write directly
- **Mandatory pre-flight check** — re-read the whole doc before any update; flag contradictions
- **15-entry hard cap per user, forever** — when full, must consolidate, propose promotion to Principles, demote (delete), or decline
- **"Why log" justification required** — if the agent can't explain why future-self wouldn't figure it out unprompted, don't log it
- **End-of-session summary** — one line on what changed
- **Monthly audit** — propose promoting recurring lessons to shared Principles, prune stale ones

Full protocol lives inside each agent's doc.

---

## Per-User Lessons

Lessons are personal. They reflect *your* preferences and *your* working style — they're not portable to other users. To prevent merge conflicts and preference bleed across users sharing this repo, each agent writes to a per-user sidecar file under [`lessons/`](lessons/).

### File naming

`lessons/<user>--<agent>.md`, e.g. `lessons/Travis Uhle--neo.md`.

### Username resolution (fallback chain)

When an agent starts a session, it resolves which lessons file is yours:

1. **`git config user.name`** — if non-empty, used as `<user>`.
2. **`whoami`** — fallback if git config is blank. Agent warns you once and suggests setting `git config --global user.name`.
3. **Refuse** — if even `whoami` fails (essentially impossible), agent does not log and tells you.

Agents never write to a malformed filename like `lessons/--neo.md`. If the resolved name is empty, they stop and surface the problem.

### First run

When you're a new user and `lessons/<your name>--<agent>.md` doesn't exist yet, the agent creates it on the first lesson and announces it once. No silent file creation.

### Username changes

If you change your `git config user.name` mid-stream and an old lessons file exists for the previous name, the agent notices, tells you, and asks whether to rename. It does not silently orphan or merge.

### Git policy

The `lessons/` folder **is committed**. Per-user filenames mean co-worker forks never collide. If you'd rather keep lessons local-only on your machine, add `lessons/` to `.gitignore` in your fork — agents don't care either way.

---

## Global vs Project-Local Lessons

When an agent learns something during work:

- **If the lesson is about *you* (your preferences, your style, your workflow):** log it in the user's lessons file in this repo.
- **If the lesson is about *the project* (codebase conventions, domain quirks, project-specific gotchas):** log it in that project's local rules file instead.

Agents should ask themselves: "Would this lesson apply if I were working in a totally different project tomorrow?" If yes → user lessons file. If no → project-local.

---

## Adding a New Agent

1. Copy `agent-template.md` to `<name>.md` in the repo root (lowercase agent name).
2. Fill in Identity, Principles, Toolkit, How They Work, What They Don't Do, Handoff Rules.
3. Leave the Self-Updating Protocol section as-is — it's standardized across all agents. Replace each `[name]` placeholder with the lowercase agent name and each `[Name]` with the capitalized one.
4. Update the Roster table in this README.
5. Install via symlink (see [Installation](#installation)).
6. Commit.

---

## Sharing With a Co-Worker

These agents are meant to be forkable. The recommended workflow for someone else picking them up:

```bash
# Fork Strix-T/agents on GitHub, then:
git clone https://github.com/<their-user>/agents.git
cd agents
git remote add upstream https://github.com/Strix-T/agents.git

# Pull structural updates from upstream when wanted:
git fetch upstream
git merge upstream/main          # lessons files stay isolated; no conflicts

./install-global.sh              # pick up any new agents
```

Why this works without conflicts: the main agent docs (identity, principles, toolkit) are shared, so they merge cleanly from upstream. Lessons live in `lessons/<their name>--<agent>.md`, so each user only ever edits their own file. Pulling upstream never touches their lessons; pushing changes never touches the original's.

---

## Naming Convention

The roster follows a **Matrix** theme. Reserved future slots:

| Name | Likely Role |
|---|---|
| Trinity | QA / Testing |
| Oracle | Research / Analytics |
| Niobe | Project management / coordination |
| Tank or Dozer | DevOps / Infrastructure |
| Seraph | Security |
| Switch | Context-switching utility |

Names are chosen for **low collision risk** — they should not be words you'd accidentally type while describing work. "Pixel" was rejected for the designer role because "make this pixel-perfect" would accidentally trigger him.

---

## Version Control

This repo is the source of truth. Commit early, commit often. The agents will suggest commits after meaningful self-updates — accept them. `git revert` is the safety net for any self-update that turns out wrong.

Suggested commit message conventions:
- `feat(neo): add lesson on X`
- `chore(morpheus): consolidate entries 3 and 7`
- `audit: monthly review, promoted 2 lessons to Principles`
- `new: add Trinity (QA agent)`

---

## Maintenance Cadence

- **Per-session:** Agents log lessons autonomously. You skim their end-of-session summaries.
- **Monthly:** Trigger a full audit ("Neo, run your monthly review"). Agents promote/demote/consolidate. Commit the result.
- **Quarterly:** Skim the whole roster. Retire agents you never use to `_archive/`. Add agents for gaps you keep hitting.
