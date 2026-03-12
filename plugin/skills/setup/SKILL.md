---
name: setup
description: Set up the Pete Loop scaffold in this project. Creates the pete/ folder with all required files (PROMPT.md, pete.sh, pete-once.sh, spec.md, plan.md, progress.txt, human-todo.md). Run this once before starting the loop.
disable-model-invocation: true
allowed-tools: Read, Write, Bash(chmod *), Bash(mkdir *), Bash(test *), Bash(ls *)
---

# Pete Loop — Project Setup

Set up the Pete Loop scaffold for this project. The templates directory is at `${CLAUDE_SKILL_DIR}/templates/`.

## Step 1: Create the pete/ directory

Run: `mkdir -p pete`

## Step 2: Copy template files

Read each file from `${CLAUDE_SKILL_DIR}/templates/` and write it to the project at the destination path shown:

| Source (read from) | Destination (write to) |
|---|---|
| `${CLAUDE_SKILL_DIR}/templates/PROMPT.md` | `pete/PROMPT.md` |
| `${CLAUDE_SKILL_DIR}/templates/pete.sh` | `pete/pete.sh` |
| `${CLAUDE_SKILL_DIR}/templates/pete-once.sh` | `pete/pete-once.sh` |
| `${CLAUDE_SKILL_DIR}/templates/spec.md` | `pete/spec.md` |
| `${CLAUDE_SKILL_DIR}/templates/plan.md` | `pete/plan.md` |
| `${CLAUDE_SKILL_DIR}/templates/progress.txt` | `pete/progress.txt` |
| `${CLAUDE_SKILL_DIR}/templates/human-todo.md` | `pete/human-todo.md` |

## Step 3: Create pete/README.md

Write this content to `pete/README.md`:

```markdown
# Pete Loop — Quick Start

> ⚠️ **Sandbox mode is enabled** via `.claude/settings.json` — this is required for safe AFK execution. If you already had a settings.json, verify it includes `"sandbox": { "enabled": true }`.

## First time setup
1. Fill in `pete/spec.md` — run `/pete-loop:spec` for AI-guided help
2. Generate `pete/plan.md` — run `/pete-loop:plan` after spec is done
3. Run `./pete/pete.sh 5` to start the loop (low iteration count is a good first run) 🌿

## Files
- `spec.md` — What you're building (fill this in first)
- `plan.md` — Phased task list (one task per loop iteration)
- `PROMPT.md` — The prompt fed to Claude each iteration (don't edit unless tuning)
- `progress.txt` — Rolling log appended by Claude each iteration
- `human-todo.md` — Tasks the loop paused on (needs your input)
- `pete.sh` — The main loop script (`./pete/pete.sh 15`)
- `pete-once.sh` — Single interactive iteration, useful for watching one iteration hands-on

## Tuning tips
- Tasks too big? Split anything with more than 2 acceptance criteria.
- Claude working on multiple tasks? Verify the ⛔ STOP gate in PROMPT.md is intact.
- Loop getting stuck? Check `pete/human-todo.md` for blocked items.
- `progress.txt` too long? Trim old entries after a phase completes — git log is the real history.
```

## Step 4: Create .claude/settings.json (only if it doesn't exist)

First check: `test -f .claude/settings.json`

- If the file **does NOT exist**: run `mkdir -p .claude`, then read `${CLAUDE_SKILL_DIR}/templates/settings.json` and write it to `.claude/settings.json`.
- If the file **already exists**: leave it untouched. Warn the user with this message:
  > ⚠️ `.claude/settings.json` already exists — it was not overwritten. **Pete Loop requires sandbox mode to be enabled** for safe AFK execution. Make sure your settings.json includes `"sandbox": { "enabled": true }`. See the template at `${CLAUDE_SKILL_DIR}/templates/settings.json` for the full recommended config.

## Step 5: Make scripts executable

Run: `chmod +x pete/pete.sh pete/pete-once.sh`

## Step 6: Confirm and guide next steps

Tell the user:
- ✅ Pete Loop scaffold created successfully
- ✅ `.claude/settings.json` created with sandbox mode enabled — safe for AFK execution
- Next: open `pete/spec.md` and fill it in, or run `/pete-loop:spec` for a guided spec-building session
- Then run `/pete-loop:plan` to generate the phased task list from the spec
- Then run `./pete/pete.sh <N>` to start the loop (e.g. `./pete/pete.sh 5` for a short first run)
