# Pete Loop

`pete-loop` is an autonomous build workflow for Claude Code that executes **one task per iteration** using a **fresh context window** each time.

It is designed for vibe coders who want reliable, incremental progress while they are away from the keyboard ("go touch grass mode").

Full tutorial video here: (https://youtu.be/nJscwBE0NA4)[https://youtu.be/nJscwBE0NA4]


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

```shell
/pete-loop:spec
```

Answer the questions carefully. Better input here = better autonomous output later.

### 3) Generate phased tasks

```shell
/pete-loop:plan
```

This creates a single `pete/plan.md` with phases and task objects.

### 4) Test one interactive iteration

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

## Task Model (Version 2)

Each task is a JSON object in `plan.md`:

```json
{
  "id": "1.2",
  "category": "setup|feature|ui|testing",
  "description": "Single sentence: what to build or configure",
  "acceptance": "Observable outcome that proves this is done",
  "passes": false
}
```

`passes` can be:

- `false` - not done
- `true` - completed
- `"blocked"` - requires human action before retrying

Keep tasks small enough to finish in one focused iteration.

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
