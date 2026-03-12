# 🔁 The Pete Loop — Complete Setup Files

A personalized variation of the Ralph Wiggum technique for Claude Code.
Built for Pro subscription users. Uses a fresh context window every iteration.

## 🛠️ PROMPTS FOR USER

### 1 - Initial Setup

Load this file into Claude Code and run this prompt to scaffold everything instantly:

```
I've loaded pete-loop-setup.md. Please set up the Pete Loop scaffold for this project.

Create a /pete folder in the project root with this structure:
- pete/README.md (condensed quick-start instructions)
- pete/spec.md (blank spec template from this file)
- pete/plan.md (blank plan template from this file)
- pete/progress.txt (empty, just the header comment)
- pete/human-todo.md (header only, from this file)
- pete/PROMPT.md (fully populated, ready to use)
- pete/pete.sh (fully populated, ready to use)
- pete/pete-once.sh (fully populated, ready to use)

Also create .claude/settings.json using the sandbox config from this file,
but ONLY if that file doesn't already exist.

Make pete.sh and pete-once.sh executable with chmod +x.
Do NOT create a phases/ folder — all tasks live inside plan.md directly.

Once done, tell me to open pete/spec.md and fill it out before continuing.
```

Once the scaffold is created, open `pete/spec.md` and fill it in (with AI help if you want — see the Pre-Loop Spec Session section below). Then run the spec-to-plan prompt to generate your phase content inside `plan.md`.

---
### 2 - Build spec.md

The user will run this in a **fresh Claude conversation** (not inside the loop).

```
I'm building [brief description of your app].

Please help me flesh out a spec.md file for this project.

First, ask me clarifying questions — especially around:
1. Tech stack choices (and any constraints I have)
2. Core features vs nice-to-haves
3. User flows and key screens
4. Data models and any third-party integrations
5. Anything that might affect how we structure the build phases

Ask me all your questions before writing anything. Once I've answered,
generate a complete spec.md using the template format I'll paste below.

[paste spec.md template here]
```

### 3 - Generate plan.md

Once `spec.md` is solid, run this prompt to generate your plan content.
The output goes directly into `pete/plan.md`, replacing the placeholder phases.

```
Based on our spec.md, please generate a complete pete/plan.md file with all phases and tasks inline (one file for everything).

Use this task format for every task:
{
  "id": "X.Y",
  "category": "setup|feature|ui|testing",
  "description": "Single sentence describing what to build or configure",
  "acceptance": "Observable outcome that proves this task is done",
  "passes": false
}

Rules for task design:
- Use "acceptance" (observable outcome), NOT "steps" (implementation checklist)
- Each task should be completable in one focused AI session
- Each task typically touches ≤5 files — if it would touch many more, split it
- If you'd write more than 2 acceptance criteria, split the task
- Aim for 12–20 tasks per phase — smaller is better than larger
- Order tasks within each phase by dependency (blocking tasks first)
- Flag tasks that need human input (credentials, manual service setup, etc.)
  with a note in the description and a reminder that "passes" should be set
  to "blocked" if the human prerequisite isn't done yet

Before finalizing, review every task and ask: "Can Claude complete this
fully autonomously, or does it need the human to do something first?"
Flag any that need human input with a note in the description.
```

## How to Use This File

Each section below is a file you need to create in your project.
The file path is shown at the top of each code block as a comment.

**Setup order:**
1. Create `.claude/settings.json` (sandbox config)
2. Create `spec.md` (fill this in with AI help, outside the loop)
3. Run the pre-loop spec session (see bottom of this file)
4. Generate `plan.md` with all phases and tasks (AI generates from spec)
5. Create `progress.txt` and `human-todo.md`
6. Create `PROMPT.md`
7. Create `pete.sh` + `pete-once.sh`
8. `chmod +x pete.sh pete-once.sh`
9. Run `./pete/pete-once.sh` first to watch one iteration, then `./pete/pete.sh 15` to go AFK

---

## File 1: `pete.sh`

The main bash loop. Pass max iterations as an argument.

```bash
#!/bin/bash

# -----------------------------------------------
# THE PETE LOOP
# Usage: ./pete/pete.sh <max_iterations>
# Example: ./pete/pete.sh 15
# -----------------------------------------------

set -uo pipefail

trap 'echo ""; echo "🛑 Pete Loop interrupted."; kill 0; exit 130' INT

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ -z "${1:-}" ]; then
  echo "Usage: ./pete/pete.sh <max_iterations>"
  echo "Example: ./pete/pete.sh 15"
  exit 1
fi

MAX_ITERATIONS=$1

# -----------------------------------------------
# USAGE CHECK
# Queries your Claude Pro subscription limits
# before each iteration. Stops the loop if your
# 5-hour session usage exceeds 85%.
# -----------------------------------------------
check_usage() {
  TOKEN=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null | \
    python3 -c "import sys,json; print(json.load(sys.stdin)['claudeAiOauth']['accessToken'])" 2>/dev/null) || true

  if [ -z "${TOKEN:-}" ]; then
    echo "⚠️  Could not retrieve token — skipping usage check."
    return 0
  fi

  UTILIZATION=$(curl -s "https://api.anthropic.com/api/oauth/usage" \
    -H "Authorization: Bearer $TOKEN" \
    -H "anthropic-beta: oauth-2025-04-20" \
    -H "User-Agent: claude-code/2.0.32" | \
    python3 -c "import sys,json; d=json.load(sys.stdin); print(d['five_hour']['utilization'])" 2>/dev/null) || true

  if [ -z "${UTILIZATION:-}" ]; then
    echo "⚠️  Could not parse usage data — skipping usage check."
    return 0
  fi

  echo "📊 5-hour session usage: ${UTILIZATION}%"

  if (( $(echo "$UTILIZATION > 85" | bc -l) )); then
    echo ""
    echo "🛑 Usage at ${UTILIZATION}% — stopping Pete Loop to avoid hitting limit."
    echo "   Wait for your 5-hour window to reset, then re-run."
    exit 1
  fi
}

# -----------------------------------------------
# MAIN LOOP
# -----------------------------------------------
echo ""
echo "🚀 Pete Loop starting — max $MAX_ITERATIONS iterations"
echo "========================================"

for ((i=1; i<=MAX_ITERATIONS; i++)); do
  echo ""
  echo "🔄 Iteration $i of $MAX_ITERATIONS"
  echo "----------------------------------------"

  check_usage

  result=$(claude -p "$(cat "$SCRIPT_DIR/PROMPT.md")" --output-format text 2>&1) || true

  echo "$result"

  if [[ "$result" == *"<promise>COMPLETE</promise>"* ]]; then
    echo ""
    echo "✅ Pete Loop complete after $i iteration(s)!"
    exit 0
  fi

  if [[ "$result" == *"<promise>BLOCKED</promise>"* ]]; then
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

---

## File 2: `pete-once.sh`

Single-iteration, interactive version. Use this to watch the loop work
before going AFK, or for hands-on steering of tricky tasks.

```bash
#!/bin/bash

# -----------------------------------------------
# PETE ONCE — Human-in-the-loop single iteration
# Usage: ./pete/pete-once.sh
# -----------------------------------------------

echo ""
echo "🔍 Pete Once — single interactive iteration"
echo "----------------------------------------"

claude "$(cat pete/PROMPT.md)"
```

---

## File 3: `PROMPT.md`

This is what gets fed to Claude on every loop iteration.

```markdown
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

**If working on UI/UX/design:** load both the "brand design" skill and the "frontend design" skill before writing any UI code.

**If you need to research documentation:** use the Context7 MCP server.

---

## Step 4: Verify

Check `pete/spec.md` and `CLAUDE.md` for the project's tech stack and any documented build/test commands. Run the appropriate verification checks for this stack — typically build, lint, and test. Common examples:

- Web (npm/bun): `npm run build` / `bun run build`, lint, test
- iOS/Xcode: `xcodebuild build`, `xcodebuild test`
- Flutter: `flutter analyze`, `flutter test`
- Other: derive from `spec.md`, `CLAUDE.md`, or package manifests in the project root

Fix any errors before continuing — even if the bug is unrelated to your current task.

Confirm the task's `acceptance` criteria are visibly met before proceeding.

---

## Step 5: Update plan.md

Update the completed task's `"passes"` field from `false` to `true` in `pete/plan.md`.
Do NOT rewrite task descriptions, reorder tasks, or restructure the file in any way.

---

## Step 6: Update pete/progress.txt

Append a new dated entry using APPEND only — do not rewrite existing entries:

```
[YYYY-MM-DD HH:MM] Phase X — Task X.Y: [task description]
  - What was implemented
  - Commands run and results
  - Any learnings or notes for future iterations
```

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

```
- [ ] **Task X.Y** — [What the human needs to do]
      (Context: why this is needed / what it unblocks)
```

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

---

## File 4: `plan.md`

All phases and tasks live in this single file. No separate phase files.
The number of phases, their names, and all tasks must be derived entirely from `spec.md` — do not invent phases or copy the structure below. This is a format example only.

```markdown
<!-- plan.md -->
# [Project Name] — Build Plan

**Spec reference:** `spec.md`
**Progress log:** `progress.txt`

---

## Phase Overview

<!-- One row per phase — derived from spec.md. Do not copy these phase names. -->
| Phase | Description | Status |
|-------|-------------|--------|
| 1 | [Phase name from spec] | 🔴 pending |

---

## Tech Stack

<!-- Populated from spec.md — list only what this project actually uses. -->

---

<!-- EXAMPLE PHASE — replace entirely with phases derived from spec.md -->
## Phase 1: [Name from spec]
**Status:** 🔴 pending

```json
[
  {
    "id": "1.1",
    "category": "setup|feature|ui|testing",
    "description": "Single sentence describing what to build or configure",
    "acceptance": "Observable outcome that proves this task is done",
    "passes": false
  }
]
```
```

---

## File 5: `progress.txt`

Starts empty. The AI appends to this every iteration as its rolling memory.
Delete and reset between major project milestones if it gets too long.

```
# progress.txt
# Pete Loop — Progress & Learnings Log
# Agent appends dated entries here. Do not manually edit.

[Project started]

```

---

## File 6: `spec.md` (template)

Fill this in BEFORE running the loop, ideally with AI help in a separate
Claude conversation. The more detail here, the better the loop performs.

```markdown
<!-- spec.md -->
# [Project Name] — Specification

## Overview

[1-2 sentence description of what this app does and who it's for]

---

## Tech Stack

| Layer | Technology | Notes |
|-------|-----------|-------|
| Frontend | | |
| Styling | | |
| Backend / DB | | |
| Auth | | |
| Hosting | | |
| Other | | |

---

## Features

### Core Features (MVP)
- [ ] Feature 1
- [ ] Feature 2
- [ ] Feature 3

### Nice-to-Have (Post-MVP)
- [ ] Feature A
- [ ] Feature B

---

## User Flows

[Describe the key user journeys step by step]

---

## Data Models

[Describe your main data structures / DB schema]

---

## API / Integrations

[List any third-party APIs, webhooks, or services]

---

## Design Notes

[Colors, fonts, vibe, any UI references]

---

## Constraints & Non-Goals

[What this app explicitly does NOT do]
```

---

## File 7: `.claude/settings.json`

Sandbox config for safe yolo-mode execution. Adjust permissions to match
your stack. Reference: https://code.claude.com/docs/en/sandboxing

```json
{
  "env": {
    "XDG_CACHE_HOME": ".cache",
    "npm_config_cache": ".cache/npm"
  },
  "permissions": {
    "allow": [
      "WebFetch(domain:registry.npmjs.org)",
      "WebFetch(domain:github.com)",
      "WebFetch(domain:cdn.jsdelivr.net)"
    ],
    "deny": [
      "Bash(sudo *)",
      "Bash(docker *)",
      "Read(./.env)",
      "Read(~/.ssh/**)",
      "Read(~/.aws/**)"
    ],
    "ask": [
      "Bash(git push:*)"
    ],
    "defaultMode": "acceptEdits"
  },
  "sandbox": {
    "enabled": true,
    "autoAllowBashIfSandboxed": true,
    "allowUnsandboxedCommands": false,
    "network": {
      "allowLocalBinding": true
    }
  }
}
```

---

## File 8: `pete/human-todo.md`

Created during setup. The Pete Loop appends to this whenever it encounters
a task that requires human input. Check this file whenever the loop pauses
or after each run to see what needs your attention.

```markdown
<!-- pete/human-todo.md -->

# 🙋 Human To-Do List

Tasks the Pete Loop flagged as needing human input.
Resolve each item, update the relevant task in `pete/plan.md` (`"passes": false` to retry),
then re-run the loop.

---
<!-- Pete Loop will append items here as needed -->

```

---



---

## Quick Start Checklist

```
□ Create .claude/settings.json
□ Fill out pete/spec.md (with AI help, outside the loop)
□ Generate pete/plan.md with all phases + tasks (with AI help, outside the loop)
□ Create pete/progress.txt (empty)
□ Create pete/human-todo.md (header only)
□ Create pete/PROMPT.md
□ Create pete/pete.sh + pete/pete-once.sh
□ chmod +x pete/pete.sh pete/pete-once.sh
□ git init + initial commit
□ Run ./pete/pete-once.sh to test one iteration interactively
□ Review output — tweak PROMPT.md if needed
□ Run ./pete/pete.sh 15 and go touch grass 🌿
```

---

## Tuning Tips

- **If Claude still works on multiple tasks:** Check that your tasks are genuinely small. If a task's `acceptance` implies 3+ distinct behaviors, split it. Also verify PROMPT.md has the ⛔ STOP gate intact — don't accidentally edit it out.
- **If tasks are getting skipped or misprioritized:** Add explicit priority context to the description, e.g. "Must be done before X can work."
- **If the AI marks tasks complete without really verifying:** Add stack-specific feedback commands to Step 4 in PROMPT.md (build, lint, test, browser check via Playwright MCP).
- **If plan.md gets corrupted JSON:** Check git log and restore with `git checkout HEAD~1 -- pete/plan.md`.
- **If progress.txt gets huge:** Fine to trim old entries after a phase completes — git log is the real history.
- **If a phase has too few tasks and iterations feel heavy:** Go back into plan.md and split the larger tasks. The sweet spot is tasks that commit in one clean diff.
