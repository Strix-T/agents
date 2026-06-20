# Agents

A personal roster of named AI agents, each with a specialized role and a self-maintained playbook. Designed to work across both Claude Code and Cursor.

---

## The Roster

| Agent | Role | Invocation |
|---|---|---|
| **Neo** | Senior Full-Stack Programmer | "Neo, ..." |
| **Morpheus** | Lead Graphic Designer (Product UI) | "Morpheus, ..." |
| **Hermes** | Head of Marketing & Growth | "Hermes, ..." |
| **Atlas** | Project Manager — Client Analytics & Reporting | "Atlas, ..." |

*Future agents will be added here as the team grows. New agents are named so the name **maps to the job** — drawn from mythology or sci-fi when the figure's domain matches the role (e.g. **Hermes** the messenger god for marketing, **Atlas** the map-book / world-bearer for the reporting PM). See [Naming Convention](#naming-convention) below.*

---

## How This Works

Each agent is a markdown file containing:

1. **Identity** — who they are, how they behave
2. **Core Principles** — non-negotiable working rules
3. **Default Toolkit / Stack** — preferred tools and conventions
4. **How They Work** — process and communication style
5. **Manager Protocol** — how they delegate to sub-agents and stay accountable for the result
6. **What They Don't Do** — explicit handoff rules to other agents
7. **Self-Updating Protocol** — how they learn and evolve over time

Lessons themselves live in **per-user sidecar files** under [`lessons/`](lessons/) — one file per (user, agent) pair, named `lessons/<user>--<agent>.md` (e.g. `lessons/Travis--neo.md`). The main agent doc is shared across all users; lessons stay personal. See [Per-User Lessons](#per-user-lessons) below.

The agents update their own lessons files autonomously when they learn something worth remembering. Strict rules prevent doc bloat (see Self-Updating Protocol in each agent file).

---

## Installation

This repo is the canonical source of truth. The actual files used by Claude Code and Cursor live in tool-specific locations. Pick one of the two strategies below.

The canonical agent docs live in [`agents/`](agents/). Both install scripts read from there, so Claude Code and Cursor share the same source of truth — one doc, two install targets. Self-updates from either tool land in the same file.

### Claude Code (global, all projects)

```bash
./install-global.sh
```

This symlinks every doc in `agents/` into `~/.claude/agents/`. Re-run after adding a new agent (it's idempotent).

Equivalent manual symlink:
```bash
ln -s "$(pwd)/agents/neo.md" ~/.claude/agents/neo.md
ln -s "$(pwd)/agents/morpheus.md" ~/.claude/agents/morpheus.md
```

### Cursor (per-project)

Cursor has no global rules folder, so install once per project:
```bash
# Run from inside the project where you want the agents available
/path/to/agents/install-cursor.sh
```

This symlinks `agents/*.md` into `<project>/.cursor/rules/*.mdc`.

Equivalent manual symlink:
```bash
ln -s ~/path/to/agents/agents/neo.md .cursor/rules/neo.mdc
ln -s ~/path/to/agents/agents/morpheus.md .cursor/rules/morpheus.mdc
```

Either install script refuses files without YAML frontmatter, backs up existing non-symlink targets with a timestamp before overwriting, and prints a count of what it installed.

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

## Model Selection

Each agent's `model:` frontmatter (e.g. `model: opus`) is **honored by Claude Code only.** `opus` is an alias for the best current Anthropic model, so it auto-upgrades as newer models ship — no edits needed.

In **Cursor** and **Codex** the `model:` line is ignored. Those tools pick the model their own way (Cursor's model selector, Codex's config/CLI), and each agent simply runs on whatever you've chosen there — Claude, GPT, or anything else. That's by design and harmless; the line is just inert text outside Claude Code.

Because the same docs run under different providers, the agent instructions talk about model choice in **capability tiers** ("most capable" vs "fast/cheap"), never vendor names. This is what makes the Manager Protocol's *"right-size the sub-agent's model"* rule portable: a manager delegates a simple, parallel sub-task to a cheaper tier and reserves the top tier for hard reasoning — and that logic holds no matter which provider's models are actually wired up. Where the host tool supports per-spawn model selection (Claude Code's Task tool does), the manager chooses deliberately; otherwise sub-agents inherit the manager's model.

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

`lessons/<user>--<agent>.md`, e.g. `lessons/Travis--neo.md`.

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

Per-user lesson files (`lessons/<user>--<agent>.md`) are **git-ignored** (see [`.gitignore`](.gitignore)) — they stay local to your machine and are never pushed, because they accumulate project and business specifics and this repo is public. Only the shared [`lessons/README.md`](lessons/README.md) (the format guide) is tracked. If you keep your work in a *private* fork and want lessons version-controlled, delete the `lessons/*--*.md` line from `.gitignore`; per-user filenames mean co-worker forks won't collide either way.

---

## Global vs Project-Local Lessons

When an agent learns something during work:

- **If the lesson is about *you* (your preferences, your style, your workflow):** log it in the user's lessons file in this repo.
- **If the lesson is about *the project* (codebase conventions, domain quirks, project-specific gotchas):** log it in that project's local rules file instead.

Agents should ask themselves: "Would this lesson apply if I were working in a totally different project tomorrow?" If yes → user lessons file. If no → project-local.

---

## Adding a New Agent

1. Copy `_templates/agent-template.md` to `<name>.md` in the repo root (lowercase agent name).
2. **Add YAML frontmatter at the very top of the file** — without it, Claude Code will not register the agent as a subagent. Format:

   ```yaml
   ---
   name: <lowercase-agent-name>     # must match the filename
   description: <one paragraph describing role, triggers, and what NOT to handle>
   ---
   ```

   The `description` is what Claude reads to decide when to invoke the agent. Write it for proactive triggering — lead with the role, list concrete cases ("Use proactively for X, Y, Z"), and state explicit non-responsibilities.
3. Fill in Identity, Principles, Toolkit, How They Work, What They Don't Do, Handoff Rules.
4. Leave the Self-Updating Protocol and Manager Protocol sections as-is — they're standardized across all agents (lightly customize the Manager Protocol's delegate/verify examples to the role). Replace each `[name]` placeholder with the lowercase agent name and each `[Name]` with the capitalized one.
5. Update the Roster table in this README.
6. Install via symlink (see [Installation](#installation)).
7. Run `/agents` in Claude Code to verify the new agent appears as a registered subagent.
8. Commit.

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

**The rule: the name maps to the job.** A name earns its place when the figure's *domain* matches the agent's *role*, so you remember what an agent does from its name alone — no rote memorization as the roster grows. Draw from **Greek/Roman mythology or sci-fi**; the Matrix theme is welcome but no longer the default. The proof this works: **Hermes** (messenger god of commerce and persuasion → marketing) and **Atlas** (the *atlas* book of charts + the Titan who bears the world → the PM who maps performance and holds the engagement together) are instantly memorable, while **Neo** and **Morpheus** you simply have memorized.

The existing three — **Neo**, **Morpheus**, **Hermes** — keep their names for continuity (renaming would orphan their lessons files and break muscle memory). The "maps to the job" rule applies to **new** hires.

Names are also chosen for **low collision risk** — they should not be words you'd accidentally type while describing work. "Pixel" was rejected for the designer role because "make this pixel-perfect" would accidentally trigger him. Avoid heavily brand-colliding common words too (e.g. "Oracle" collides with the database giant and the phrase "oracle of truth").

Suggested names for likely future roles (name → why it maps):

| Likely Role | Suggested Name | Why it maps |
|---|---|---|
| QA / Testing | **Argus** | The hundred-eyed watchman who never blinks — catches every defect. |
| DevOps / Infrastructure | **Vulcan** | God of the forge — builds and maintains the machinery everything runs on (and a nod to Star Trek's engineers). |
| Security | **Aegis** | Athena's shield; "aegis" already means protection in plain English. |
| Deep research / investigation | **Sherlock** | Shorthand for relentless, evidence-driven investigation. |
| Legal / Compliance | **Themis** | Titaness of law, order, and fair judgment. |
| Customer success / retention | **Hestia** | Goddess of the hearth and home — keeping customers warm and loyal. |

These are suggestions, not reservations — pick the name that maps best when the role actually arrives. (*Replaces the old "reserved Matrix slots" table: "Niobe" for project management is retired — that role is now **Atlas** — and "Oracle" is set aside for the collision reason above.*)

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

---

## License

This repository is the proprietary work of STRIX, LLC. It is **published publicly but not open source** — personal forks are allowed, commercial use is not, and redistribution under another name is not. See [LICENSE.md](LICENSE.md) for full terms. For anything beyond personal use, contact **travis@strixstudio.com**.
