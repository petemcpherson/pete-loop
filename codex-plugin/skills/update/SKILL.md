---
name: update
description: Update Pete Loop system files (pete.sh, pete-once.sh, README.md) in this project to the latest plugin version. Safe to run anytime — never overwrites your spec, plan, progress, or human-todo files. Asks before touching PROMPT.md.
---

# Pete Loop — Update

Update the Pete Loop system scripts in this project to match the current plugin version. Only safe, non-user-edited files are overwritten automatically. Your spec, plan, progress, human-todo, and PROMPT.md are never touched without asking.

## Step 1: Check that pete/ exists

Run: `test -d pete`

If it does not exist, stop and tell the user:
> ❌ No `pete/` folder found in this project. Run `/pete-loop:setup` first to scaffold Pete Loop.

## Step 2: Update system scripts

Write each file below to its destination path exactly as shown. Do not modify the content.

### pete/pete.sh

```bash
#!/bin/bash

# -----------------------------------------------
# THE PETE LOOP (Codex edition)
# Usage: ./pete/pete.sh <max_iterations> [subfolder]
# Example: ./pete/pete.sh 15
# Example: ./pete/pete.sh 15 v2
# -----------------------------------------------

set -uo pipefail

trap 'echo ""; echo "🛑 Pete Loop interrupted."; kill 0; exit 130' INT

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ -z "${1:-}" ]; then
  echo "Usage: ./pete/pete.sh <max_iterations> [subfolder]"
  echo "Example: ./pete/pete.sh 15"
  echo "Example: ./pete/pete.sh 15 v2"
  exit 1
fi

MAX_ITERATIONS=$1
SUBFOLDER="${2:-}"

if [ -n "$SUBFOLDER" ]; then
  PROMPT_FILE="$SCRIPT_DIR/$SUBFOLDER/PROMPT.md"
else
  PROMPT_FILE="$SCRIPT_DIR/PROMPT.md"
fi

if [ ! -f "$PROMPT_FILE" ]; then
  echo "❌ PROMPT.md not found at: $PROMPT_FILE"
  exit 1
fi

LAST_MSG_FILE=$(mktemp)
trap 'rm -f "$LAST_MSG_FILE"' EXIT

echo ""
if [ -n "$SUBFOLDER" ]; then
  echo "🚀 Pete Loop starting — max $MAX_ITERATIONS iterations [run: $SUBFOLDER]"
else
  echo "🚀 Pete Loop starting — max $MAX_ITERATIONS iterations"
fi
echo "========================================"

for ((i=1; i<=MAX_ITERATIONS; i++)); do
  echo ""
  echo "🔄 Iteration $i of $MAX_ITERATIONS"
  echo "----------------------------------------"

  codex exec \
    --sandbox workspace-write \
    --ask-for-approval never \
    --output-last-message "$LAST_MSG_FILE" \
    "$(cat "$PROMPT_FILE")" || true

  LAST_MSG=$(cat "$LAST_MSG_FILE" 2>/dev/null || echo "")

  if [[ "$LAST_MSG" == *"<promise>COMPLETE</promise>"* ]]; then
    echo ""
    echo "✅ Pete Loop complete after $i iteration(s)!"
    exit 0
  fi

  if [[ "$LAST_MSG" == *"<promise>BLOCKED</promise>"* ]]; then
    echo ""
    echo "⏸️  Pete Loop paused — all remaining tasks need human input."
    echo "   Check pete/human-todo.md, resolve each item, then re-run."
    exit 2
  fi

  echo ""
  echo "--- End of iteration $i ---"
  echo ""
done

echo ""
echo "⛔ Reached max iterations ($MAX_ITERATIONS) without completion."
echo "   Check pete/human-todo.md for blocked tasks."
echo "   Review pete/progress.txt and pete/plan.md, then re-run if needed."
exit 1
```

### pete/pete-once.sh

```bash
#!/bin/bash

# -----------------------------------------------
# PETE ONCE — Human-in-the-loop single iteration (Codex edition)
# Usage: ./pete/pete-once.sh
# Usage: ./pete/pete-once.sh [subfolder]
# Example: ./pete/pete-once.sh
# Example: ./pete/pete-once.sh v2
# -----------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SUBFOLDER="${1:-}"

if [ -n "$SUBFOLDER" ]; then
  PROMPT_FILE="$SCRIPT_DIR/$SUBFOLDER/PROMPT.md"
else
  PROMPT_FILE="$SCRIPT_DIR/PROMPT.md"
fi

if [ ! -f "$PROMPT_FILE" ]; then
  echo "❌ PROMPT.md not found at: $PROMPT_FILE"
  exit 1
fi

echo ""
echo "🔍 Pete Once — single interactive iteration"
if [ -n "$SUBFOLDER" ]; then
  echo "   Run: $SUBFOLDER"
fi
echo "----------------------------------------"

codex "$(cat "$PROMPT_FILE")"
```

### pete/README.md

```markdown
# Pete Loop — Quick Start

## Customizing PROMPT.md for your setup

`PROMPT.md` is the instruction set Codex reads on every loop iteration — it's worth tailoring it to your workflow. Common additions:

- **Commit style** — add a line like *"Do NOT add a Co-Authored-By attribution"* if you don't want that in your git history
- **Tech stack context** — reference your `AGENTS.md` for project-specific conventions

See [`Resources/prompt-improvements.md`](https://github.com/petemcpherson/pete-loop/blob/main/Resources/prompt-improvements.md) for concrete examples and copy-paste snippets.

## First time setup
1. Fill in `pete/spec.md` — run `/pete-loop:spec` for AI-guided help
2. Generate `pete/plan.md` — run `/pete-loop:plan` after spec is done
3. Run `./pete/pete.sh 5` to start the loop (low iteration count is a good first run) 🌿

## Files
- `spec.md` — What you're building (fill this in first)
- `plan.md` — Phased task list (one task per loop iteration)
- `PROMPT.md` — The prompt fed to Codex each iteration (don't edit unless tuning)
- `progress.txt` — Rolling log appended by Codex each iteration
- `human-todo.md` — Tasks the loop paused on (needs your input)
- `pete.sh` — The main loop script (`./pete/pete.sh 15`)
- `pete-once.sh` — Single interactive iteration, useful for watching one iteration hands-on

## Pete Runs — Starting a New Build Phase

Each time you use Pete Loop to build something new — a feature, a v2, a new phase — that's a **Pete Run**. Each run lives in its own subfolder with isolated context.

Start one with a single command:

```shell
/pete-loop:new-run
```

It asks for a name, scaffolds the subfolder, and wires up all the paths in `PROMPT.md` automatically. Then:

```shell
/pete-loop:spec   # write the spec (will ask which run)
/pete-loop:plan   # generate the plan (will ask which run)
./pete/pete.sh 15 v2
```

Subfolder is the **second** arg — `./pete/pete.sh 15` still works as normal for the root run.

Full tutorial: see **Pete Runs** section in the [main README](https://github.com/petemcpherson/pete-loop#pete-runs).

## Updating Pete Loop

When you update the pete-loop plugin, your project's scripts (`pete.sh`, `pete-once.sh`) are **not** automatically updated — they were copied here at setup time.

To pull the latest scripts into this project after a plugin update, run:

```shell
/pete-loop:update
```

This updates `pete.sh`, `pete-once.sh`, and this `README.md`. It will ask before touching `PROMPT.md`, and never overwrites your `spec.md`, `plan.md`, `progress.txt`, or `human-todo.md`.

## Tuning tips
- Tasks too big? Split anything with more than 2 acceptance criteria.
- Codex working on multiple tasks? Verify the ⛔ STOP gate in PROMPT.md is intact.
- Loop getting stuck? Check `pete/human-todo.md` for blocked items.
- `progress.txt` too long? Trim old entries after a phase completes — git log is the real history.
```

After writing, run: `chmod +x pete/pete.sh pete/pete-once.sh`

## Step 3: Ask about PROMPT.md

Tell the user:

> **PROMPT.md** is the instruction set fed to Codex on every loop iteration. The latest plugin version may include improvements, but you may also have customized it for your workflow.
>
> Would you like to reset `pete/PROMPT.md` to the latest template? **This will overwrite any customizations you've made.**
>
> Reply **yes** to overwrite, or **no** to keep your current version.

If **yes**: write `pete/PROMPT.md` with the following content:

```
<!-- PROMPT.md -->

@pete/plan.md @pete/progress.txt @pete/human-todo.md

⚠️ YOU WILL IMPLEMENT EXACTLY ONE TASK THIS SESSION. ONE. After committing it, you STOP. The loop handles everything else.

---

You are working autonomously on a software project. Follow these steps exactly.

---

## Step 1: Orient

Read `pete/progress.txt` to understand what has already been done.
Read `pete/human-todo.md` to see what tasks are currently blocked on human input.
Read `.env.example` to understand what environment variables are available. Assume all variables listed there are populated with real values in `.env`. Do NOT ask the user to provide credentials that appear in `.env.example`.

---

## Step 2: Choose One Task

Read `pete/plan.md`. Find the active phase (the first phase NOT marked ✅ complete). Within that phase's task list, find the single task where `"passes": false` that is most foundational or blocking other tasks.

**Do NOT choose a task listed in `pete/human-todo.md` — skip blocked tasks entirely.**

⚠️ You are choosing ONE task. Commit to that choice before moving on.

---

## Step 3: Implement

Before starting, search the codebase to understand what already exists.
Do NOT assume something is not implemented — verify first.

A well-sized task typically touches ≤5 files. If you find yourself touching many more files than expected, check whether you are over-scoping — implement only what the `acceptance` criteria describes, nothing more.

Implement the chosen task fully:

- No placeholder code
- No TODO stubs
- Complete implementations only

---

## Step 4: Verify

Check `pete/spec.md` and `AGENTS.md` for the project's tech stack and any documented build/test commands. Run the appropriate verification checks for this stack — typically build, lint, and test. Common examples:

- Web (npm/bun): `npm run build` / `bun run build`, lint, test
- iOS/Xcode: `xcodebuild build`, `xcodebuild test`
- Flutter: `flutter analyze`, `flutter test`
- Other: derive from `spec.md`, `AGENTS.md`, or package manifests in the project root

Fix any errors before continuing — even if the bug is unrelated to your current task.

Confirm the task's `acceptance` criteria are visibly met before proceeding.

---

## Step 5: Update plan.md

Update the completed task's `"passes"` field from `false` to `true` in `pete/plan.md`.
Do NOT rewrite task descriptions, reorder tasks, or restructure the file in any way.

---

## Step 6: Update pete/progress.txt

Append a new dated entry using APPEND only — do not rewrite existing entries:

` `` `
[X.Y done YYYY-MM-DD] Brief description. ⚠️  Learning: [only if there's a genuine gotcha,
else omit]
` `` `

---

## Step 7: Git Commit

Make a single git commit for this task only.
Format: `[PhaseX] Brief description of what was implemented`

Do NOT run `git init`, change remotes, or `git push`.

---

⛔ STOP. Your implementation work is complete. Do NOT read ahead to the next task. Do NOT begin any additional implementation. The loop will start a fresh context window for the next task. Only proceed below to handle bookkeeping.

---

## Step 8: Check for Blocked Tasks

Check if the task you would have chosen next requires human input (missing credentials, external service setup, manual configuration, unclear requirements).

If yes → add it to `pete/human-todo.md` using this format:

` `` `
- [ ] **Task X.Y** — [What the human needs to do]
      (Context: why this is needed / what it unblocks)
` `` `

Mark that task `"passes": "blocked"` in `pete/plan.md` so it is not chosen again.

---

## Step 9: Check Phase Completion

Check if ALL tasks in the current phase have `"passes": true` OR `"passes": "blocked"`.

If yes → mark the phase ✅ complete in the Phase Overview table in `pete/plan.md`.

---

## Step 10: Check Project Completion

If ALL phases are marked ✅ complete, output exactly:

<promise>COMPLETE</promise>

If all remaining tasks across ALL phases are blocked, output exactly:

<promise>BLOCKED</promise>

Otherwise, output nothing. The next iteration will handle the next task.

---

## IMPORTANT RULES

- ⚠️ ONE task per iteration. This is non-negotiable.
- Full implementations only. No placeholders, no stubs.
- Search the codebase before assuming something isn't implemented.
- Verify `acceptance` criteria are met before marking a task passing.
- Never modify task descriptions or restructure plan.md.
- Never push to remote.
- If a task requires human action, document it in `pete/human-todo.md` and move on.
  Do NOT loop asking the same question — write it down and skip it.
```

If **no**: leave `pete/PROMPT.md` untouched.

## Step 4: Confirm and summarize

Tell the user:

- ✅ `pete/pete.sh` — updated to latest version
- ✅ `pete/pete-once.sh` — updated to latest version
- ✅ `pete/README.md` — updated to latest version
- (If PROMPT.md was reset): ✅ `pete/PROMPT.md` — reset to latest template
- (If PROMPT.md was kept): ℹ️ `pete/PROMPT.md` — kept as-is (your customizations preserved)
- ℹ️ `spec.md`, `plan.md`, `progress.txt`, and `human-todo.md` were not touched

Then add this note:
> **Pete Runs** (subfolders like `pete/v2/`) each have their own `PROMPT.md`. Those were not updated — they were generated from your root `PROMPT.md` when the run was created, and may contain your customizations. If you reset your root `PROMPT.md` above and want the same changes in a run subfolder, re-run `/pete-loop:new-run` for that subfolder, or edit the paths manually.
