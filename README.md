# Pete Loop

`pete-loop` is an autonomous build workflow for Claude Code that executes **one task per iteration** using a **fresh context window** each time.

It is designed for vibe coders who want reliable, incremental progress while they are away from the keyboard ("go touch grass mode").

Full tutorial video here: https://youtu.be/nJscwBE0NA4


## Keeping Pete Loop Updated

Pete Loop is actively maintained. Claude Code does **not** auto-update plugins by default — enable it so you always get the latest version:

**Via UI:** Run `/plugin` → **Marketplaces** tab → select `petemcpherson-claude-plugins` → enable **Auto-update**

**Or manually update anytime:**
```bash
claude plugin update pete-loop@petemcpherson-claude-plugins
```

Then run `/reload-plugins` to apply the update.

---

## What This Project Includes

- A Claude Code plugin named `pete-loop`
- Three plugin skills:
  - `/pete-loop:setup` - scaffold the loop files into any project
  - `/pete-loop:spec` - guided session to produce a strong `spec.md`
  - `/pete-loop:plan` - generate phased, task-by-task `plan.md` from your spec
- A "version 2" operating model (single `plan.md`, one-task loop, strict stop gate, progress logging)
- Some other resources

---

## How Pete Loop Works

At runtime, the loop script repeatedly:

1. Checks Claude Pro usage and stops if usage is too high
2. Runs Claude with `pete/PROMPT.md` in headless mode
3. Forces Claude to complete exactly one task
4. Requires verification, updates `plan.md`, appends `progress.txt`, and commits
5. Starts next iteration in a fresh context (new run)

This fresh-context-per-iteration model is the core design choice that keeps sessions focused and reduces drift.

---

## Prerequisites

- Claude Code Pro installed and authenticated
- Claude Code v1.0.33+ (plugins support)
- Git repository for your project

---

## Install The Pete Loop Plugin

You can install through the plugin marketplace UI, or directly with commands.

### Option A: Marketplace UI (recommended)

1. Open Claude Code
2. Run `/plugin`
3. Go to the **Marketplaces** tab and add:
   - `petemcpherson/claude-plugins`
4. Go to **Discover**, find `pete-loop`, and install it
5. Choose scope:
   - **User** (all your projects)
   - **Project** (shared in this repo)
   - **Local** (only you, only this repo)

### Option B: Install via commands

Run these commands in Claude Code:

```shell
/plugin marketplace add petemcpherson/claude-plugins
/plugin install pete-loop@petemcpherson-claude-plugins
```

CLI equivalent:

```bash
claude plugin marketplace add petemcpherson/claude-plugins
claude plugin install pete-loop@petemcpherson-claude-plugins
```

After install, available commands are:

- `/pete-loop:setup`
- `/pete-loop:spec`
- `/pete-loop:plan`

### Local development install (from this repo)

If you are developing this plugin locally:

```bash
claude --plugin-dir ./plugin
```

Then run `/reload-plugins` after edits.

---

## Quick Start (Using Pete Loop In A Project)

### 1) Scaffold your project

Inside the target project:

```shell
/pete-loop:setup
```

This creates:

- `pete/PROMPT.md`
- `pete/pete.sh`
- `pete/pete-once.sh`
- `pete/spec.md`
- `pete/plan.md`
- `pete/progress.txt`
- `pete/human-todo.md`
- (and `.claude/settings.json` if it does not already exist)

### 2) Build a real spec

**YOU should spend a good deal of time on this step!**

Create a spec.md file with your notes, preferences, opinions, features, sub-features, everything.

You can also write out a bit and THEN run...

```shell
/pete-loop:spec
```

Claude Code will ask you clarifying questions. Answer the questions carefully. Better input here = better autonomous output later.

### 3) Generate phased tasks

```shell
/pete-loop:plan
```

This creates a single `pete/plan.md` with phases and task objects.

### 4) Test one interactive iteration

**NOTE**: I don't actually do this.

```bash
./pete/pete-once.sh
```

### 5) Run full autonomous loop

```bash
./pete/pete.sh 15
```

Use a small number first (`5`) until you trust the flow for that project.

---

## Core Files You Will Use

- `pete/spec.md` - what you are building
- `pete/plan.md` - all phases + tasks in one file
- `pete/PROMPT.md` - loop policy and hard stop behavior
- `pete/progress.txt` - append-only run history
- `pete/human-todo.md` - tasks blocked on human action
- `pete/pete.sh` - autonomous loop runner
- `pete/pete-once.sh` - single interactive run

---

## Operational Rules (Important)

- One task per iteration, always
- Verify acceptance before marking pass
- No placeholder code / no TODO stubs
- Update task status only; do not restructure plan during loop runs
- Append to `progress.txt` only
- Never `git push` from loop runs
- If a task needs human input, add it to `human-todo.md` and mark blocked

---

## Monitoring While It Runs

In another terminal:

```bash
tail -f pete/progress.txt
```

and optionally:

```bash
watch -n 5 git log --oneline -10
```

---

## Exit Signals

The loop stops early if Claude returns:

- `<promise>COMPLETE</promise>` - all phases complete
- `<promise>BLOCKED</promise>` - all remaining tasks need human input

---

## Troubleshooting

- `/plugin` not available:
  - Update Claude Code and restart your terminal
- Skill not showing:
  - Run `/reload-plugins`
- Loop pauses as blocked:
  - Check `pete/human-todo.md`, resolve items, set affected tasks back to `false`, rerun
- Tasks too big / Claude over-scoping:
  - Split large tasks in `plan.md` so acceptance is singular and observable
- Usage threshold hit:
  - Wait for your 5-hour window reset, then rerun `./pete/pete.sh <N>`

---

## Security Notes

Plugins can execute code with your user privileges. Install only from trusted marketplaces.

The default Pete Loop setup is intended to run with Claude sandbox mode enabled in `.claude/settings.json`.

---

## Repository Layout

This repository has two main areas:

- `version 2/` - reference docs and setup prompts for the current methodology
- `plugin/` - the distributable Claude Code plugin (`pete-loop`)

---

## License

MIT - see `LICENSE`.

---

## Adding Features to an Existing Pete Loop Project

Once you've used Pete Loop to build a project, you'll eventually want to come back and add new features. The naive approach — deleting everything and regenerating from scratch — works, but it has a real cost: all the context from the original build (completed tasks, progress notes, learnings) gets fed into the agent's context window on every iteration, even though none of it is relevant to the new work.

A cleaner pattern: **one subfolder per build run**. Each feature addition gets its own isolated directory inside `pete/`, with its own spec, plan, and loop files. The shared scripts at the root of `pete/` are parameterized to point at whichever subfolder you're working on.

This keeps context tight and focused, preserves history naturally, and makes it easy to run or review any past build.

### Folder Structure

```
pete/
├── pete.sh               ← updated to accept a subfolder arg
├── pete-once.sh          ← same
├── initial-build/        ← your original run (archived, never touched again)
│   ├── spec.md
│   ├── plan.md
│   ├── progress.txt
│   ├── human-todo.md
│   └── PROMPT.md
└── user-auth/            ← new feature run
    ├── spec.md
    ├── plan.md
    ├── progress.txt
    ├── human-todo.md
    └── PROMPT.md
```

### Step-by-Step: Adding a Feature

**Step 1: Update `pete.sh` and `pete-once.sh` to accept a subfolder argument**

Open `pete/pete.sh` and change the script to accept a subfolder as the first argument (with max iterations as the second). Replace the hardcoded `PROMPT.md` path with a dynamic one:

```bash
# Usage: ./pete/pete.sh <subfolder> <max_iterations>
# Example: ./pete/pete.sh user-auth 15

SUBFOLDER=$1
MAX_ITERATIONS=$2

# ...then in the loop:
result=$(claude -p "$(cat "$SCRIPT_DIR/$SUBFOLDER/PROMPT.md")" --output-format text 2>&1) || true
```

Update `pete-once.sh` similarly:

```bash
# Usage: ./pete/pete-once.sh <subfolder>
# Example: ./pete/pete-once.sh user-auth

SUBFOLDER=$1
claude "$(cat "pete/$SUBFOLDER/PROMPT.md")"
```

**Step 2: (Optional) Rename your original files into a subfolder**

If you want to keep the original build archived cleanly:

```bash
mkdir pete/initial-build
mv pete/spec.md pete/plan.md pete/progress.txt pete/human-todo.md pete/PROMPT.md pete/initial-build/
```

This is optional — you can leave the original files in place and just create subfolders going forward.

**Step 3: Create a subfolder for the new feature**

```bash
mkdir pete/user-auth
```

**Step 4: Write a focused `spec.md` for just the new feature**

Create `pete/user-auth/spec.md`. This spec only needs to cover the new feature — not the whole app. You can reference what already exists for context, but keep it scoped.

Use `/pete-loop:spec` if you want a guided session, or write it directly.

**Step 5: Generate a `plan.md` for the new feature**

Open a fresh Claude conversation (outside the loop). Share:
- `pete/user-auth/spec.md`
- Brief context about what's already built (or point Claude at the existing codebase)

Ask Claude to generate a `plan.md` using the standard task format. The generated plan should only cover tasks for the new feature — Claude will search the existing codebase during the loop to avoid re-implementing anything.

Save the output to `pete/user-auth/plan.md`.

**Step 6: Create the remaining loop files**

```bash
# progress.txt
echo "# progress.txt
# Pete Loop — Progress & Learnings Log
# Agent appends dated entries here. Do not manually edit.

[Project started]
" > pete/user-auth/progress.txt

# human-todo.md — copy the header from the original or paste it fresh
```

**Step 7: Create `PROMPT.md` for this subfolder**

Copy `pete/PROMPT.md` (or `pete/initial-build/PROMPT.md`) into `pete/user-auth/PROMPT.md`, then update the `@` file references at the top to point to the subfolder:

```
@pete/user-auth/plan.md @pete/user-auth/progress.txt @pete/user-auth/human-todo.md
```

Everything else in PROMPT.md stays the same.

**Step 8: Run the loop**

```bash
./pete/pete.sh user-auth 15
```

Monitor progress:

```bash
tail -f pete/user-auth/progress.txt
```

### Why This Works

- The agent only loads context relevant to the current feature — no completed tasks, no stale progress entries from months ago
- The original build is preserved and human-readable in its own subfolder
- Each future feature addition follows the same pattern: new subfolder, new spec, new plan, run the loop
- You can always go back and read `pete/initial-build/progress.txt` to see the learnings from the original build
