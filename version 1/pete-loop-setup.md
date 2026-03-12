# 🔁 The Pete Loop — Complete Setup Files

A personalized variation of the Ralph Wiggum technique for Claude Code.
Built for Pro subscription users. Uses a fresh context window every iteration.

## 🛠️ Quick Setup Command

Load this file into Claude Code and run this prompt to scaffold everything instantly:
```
I've loaded pete-loop-setup.md. Please set up the Pete Loop scaffold for this project.

Create a /pete folder in the project root with this structure:
- pete/README.md (condensed quick-start instructions)
- pete/spec.md (blank spec template from this file)
- pete/plan.md (blank plan template from this file)
- pete/progress.txt (empty, just the header comment)
- pete/PROMPT.md (fully populated, ready to use)
- pete/pete.sh (fully populated, ready to use)
- pete/pete-once.sh (fully populated, ready to use)
- pete/phases/ (empty folder)

Also create .claude/settings.json using the sandbox config from this file,
but ONLY if that file doesn't already exist.

Make pete.sh and pete-once.sh executable with chmod +x.
Do not create plan.md phase files yet — those come after spec.md is filled out.

Once done, tell me to open pete/spec.md and fill it out before continuing.
```

That's it. Once the scaffold is created, open `pete/spec.md` and fill it in
(with AI help if you want — see the Pre-Loop Spec Session section below).
Then come back and run the spec-to-plan prompt to generate your phase files.

---

## How to Use This File

Each section below is a file you need to create in your project root.
The file path is shown at the top of each code block as a comment.

**Setup order:**
1. Create `.claude/settings.json` (sandbox config)
2. Create `spec.md` (the user will fill this in with AI help, outside the loop)
3. Run the pre-loop spec session (see bottom of this file)
4. Create `plan.md` + `phase1.md`, `phase2.md`, etc. (AI generates from spec)
5. Create `progress.txt`
6. Create `PROMPT.md`
7. Create `pete.sh` + `pete-once.sh`
8. `chmod +x pete.sh pete-once.sh`
9. Run `./pete-once.sh` first to watch it work, then `./pete.sh 15` to go AFK

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
# pete-once.sh
#!/bin/bash

# -----------------------------------------------
# PETE ONCE — Human-in-the-loop single iteration
# Usage: ./pete-once.sh
# -----------------------------------------------

echo ""
echo "🔍 Pete Once — single interactive iteration"
echo "----------------------------------------"

claude "$(cat PROMPT.md)"
```

---

## File 3: `PROMPT.md`

This is what gets fed to Claude on every loop iteration.
Customize the feedback/verification section for your stack.

```markdown
<!-- PROMPT.md -->

@pete/plan.md @pete/progress.txt @pete/human-todo.md

You are working autonomously on a software project. Follow these steps exactly.

---

## Step 1: Orient

Read `pete/progress.txt` to understand what has already been done.
Read `pete/plan.md` to identify the current active phase and its status.
Read `pete/human-todo.md` to see what tasks are currently blocked on human input.
Read `.env.example` to understand what environment variables are available. Assume all variables listed there are populated with real values in `.env`. Do NOT ask the user to provide credentials that appear in `.env.example`.

---

## Step 2: Load Current Phase

From `pete/plan.md`, identify which phase is currently active (the first phase NOT marked ✅ complete).
Open and read that phase file (e.g. `pete/phases/phase1.md`, `pete/phases/phase2.md`, etc.).

---

## Step 3: Choose One Task

From the current phase file, find the single highest-priority task where `"passes": false`.

- Do NOT choose the first task by default — reason about which incomplete task is most
  foundational or blocking other tasks, and choose that one.
- Do NOT choose a task already listed in `pete/human-todo.md` — skip blocked tasks entirely.

You will work on EXACTLY ONE task this iteration. No more.

---

## Step 4: Implement

Before starting, search the codebase to understand what already exists.
Do NOT assume something is not implemented — verify first.

Implement the chosen task fully:

- No placeholder code
- No TODO stubs
- Complete implementations only

**If working on UI/UX/design:** load both the "brand design" skill and the "frontend design" skill before writing any UI code.

**If you need to research documentation:** use the Context7 MCP server.

---

## Step 5: Verify

Run available feedback checks for this project's stack:

- `bun run build`
- `bun run lint`
- `bun test` (scoped to changed files if possible)

Fix any errors before continuing — even if the bug is unrelated to your current task.

---

## Step 6: Update Phase File

Update the completed task's `"passes"` field from `false` to `true` in the current phase file.
Do NOT rewrite task descriptions, reorder tasks, or restructure the file in any way.

---

## Step 7: Update pete/progress.txt

Append a new dated entry using APPEND only — do not rewrite existing entries:

```
[YYYY-MM-DD HH:MM] Phase X — Task: [task description]
  - What was implemented
  - Commands run and results
  - Any learnings or notes for future iterations
```

---

## Step 8: Git Commit

Make a single git commit for this task only.
Format: `[PhaseX] Brief description of what was implemented`

Do NOT run `git init`, change remotes, or `git push`.

---

## Step 9: Check for Blocked Tasks

Before finishing, check if the task you WOULD have chosen next requires human input
(missing credentials, external service setup, manual configuration, unclear requirements).

If yes → add it to `pete/human-todo.md` using this format, then skip it next iteration:

```
- [ ] **Task X.Y** — [What the human needs to do]
      (Context: why this is needed / what it unblocks)
```

Mark the task `"passes": "blocked"` in the phase file so it is not chosen again.

---

## Step 10: Check Phase Completion

Check if ALL tasks in the current phase file have `"passes": true` OR `"passes": "blocked"`.

If yes → mark the current phase ✅ complete in `pete/plan.md` and set the next phase as active.

---

## Step 11: Check Project Completion

If ALL phases in `pete/plan.md` are marked ✅ complete, output exactly:

<promise>COMPLETE</promise>

If all remaining tasks across ALL phases are blocked, output exactly:

<promise>BLOCKED</promise>

Otherwise, stop here. The next iteration will handle the next task.

---

## IMPORTANT RULES

- One task per iteration. Always.
- Full implementations only. No placeholders, no stubs.
- Search the codebase before assuming something isn't implemented.
- Never modify task descriptions or restructure phase files.
- Never push to remote.
- If a task requires human action, document it in `pete/human-todo.md` and move on.
  Do NOT loop asking the same question — write it down and skip it.
```

---

## File 4: `plan.md`

High-level overview only. Points to phase files. Gets loaded every iteration.
Keep this under ~150 lines — detail lives in the phase files.

```markdown
<!-- plan.md -->
# [Your Project Name] — Master Plan

**Spec reference:** `spec.md`
**Progress log:** `progress.txt`

---

## Phase Overview

| Phase | File | Description | Status |
|-------|------|-------------|--------|
| 1 | `phase1.md` | Project Setup & Foundation | 🔴 pending |
| 2 | `phase2.md` | Core Features | 🔴 pending |
| 3 | `phase3.md` | UI & Polish | 🔴 pending |
| 4 | `phase4.md` | Testing & Launch Prep | 🔴 pending |

---

## Active Phase

**Phase 1** → See `phase1.md`

---

## Tech Stack

- Frontend: [e.g. SvelteKit + Tailwind]
- Backend: [e.g. Firebase]
- Email: [e.g. AWS SES]
- Hosting: [e.g. Vercel]

---

## Completion Criteria

All phases marked ✅ complete in the table above.
```

---

## File 5: `phase1.md` (template — duplicate for each phase)

Tasks use a JSON format with a `passes` flag. Each task should be small enough
to complete in a single focused iteration. If a task feels too big, split it.

```markdown
<!-- phase1.md -->
# Phase 1: Project Setup & Foundation

**Goal:** Get the project scaffolded, dependencies installed, and dev environment running.

---

## Tasks

```json
[
  {
    "id": "1.1",
    "category": "setup",
    "description": "Initialize project structure and install dependencies",
    "steps": [
      "Create directory structure per spec.md",
      "Initialize package.json / relevant config files",
      "Install all required dependencies",
      "Verify project runs without errors"
    ],
    "passes": false
  },
  {
    "id": "1.2",
    "category": "setup",
    "description": "Configure environment and base settings",
    "steps": [
      "Create .env.example with all required variables",
      "Set up any config files (tailwind, typescript, etc.)",
      "Verify config loads correctly"
    ],
    "passes": false
  },
  {
    "id": "1.3",
    "category": "setup",
    "description": "Set up git and initial commit",
    "steps": [
      "Create .gitignore appropriate for stack",
      "Verify no sensitive files are tracked",
      "Make initial commit"
    ],
    "passes": false
  }
]
```

---

## Phase Completion Criteria

All tasks above have `"passes": true`.
```

---

## File 6: `progress.txt`

Starts empty. The AI appends to this every iteration as its rolling memory.
Delete and reset between major project milestones if it gets too long.

```
# progress.txt
# Pete Loop — Progress & Learnings Log
# Agent appends dated entries here. Do not manually edit.

[Project started]

```

---

## File 7: `spec.md` (template)

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

## File 8: `.claude/settings.json`

Sandbox config for safe yolo-mode execution. Adjust permissions to match
your stack. Reference: https://code.claude.com/docs/en/sandboxing

```json
// .claude/settings.json
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

## File 9: `pete/human-todo.md`

Created during setup. The Pete Loop appends to this whenever it encounters
a task that requires human input. Check this file whenever the loop pauses
or after each run to see what needs your attention.

```markdown
<!-- pete/human-todo.md -->

# 🙋 Human To-Do List

Tasks the Pete Loop flagged as needing human input.
Resolve each item, update the relevant phase file (`"passes": false` to retry),
then re-run the loop.

---
<!-- Pete Loop will append items here as needed -->

```

---

## Pre-Loop Spec Session Prompts

Run these in a **fresh Claude conversation** (not inside the loop).

### Step 1: Build spec.md

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

### Step 2: Generate plan.md + phase files

Once `spec.md` is solid, run this prompt to generate your plan files:

```
Based on our spec.md, please generate:

1. A pete/plan.md file (high-level phase overview, keep it under 150 lines)
2. A pete/phases/phase1.md, phase2.md, etc. for each phase

Use this task format for each phase file:
{
  "id": "X.Y",
  "category": "setup|feature|ui|testing",
  "description": "...",
  "steps": ["..."],
  "passes": false
}

Rules:
- Each task should be completable in a single focused AI session
- Tasks within a phase should be ordered by dependency (blocking tasks first)
- Aim for 5-10 tasks per phase
- No task should require human input to complete (external credentials,
  manual service setup, etc.) — flag those separately in the description
  so the loop can handle them gracefully
- No task should be so large it would overflow a context window

Before finalizing, review every task and ask: "Can Claude complete this
fully autonomously, or does it need the human to do something first?"
Flag any that need human input with a note in the description.
```

---

## Quick Start Checklist

```
□ Create .claude/settings.json
□ Fill out spec.md (with AI help, outside the loop)
□ Generate plan.md + phaseX.md files (with AI help, outside the loop)
□ Create progress.txt (empty)
□ Create PROMPT.md
□ Create pete.sh + pete-once.sh
□ chmod +x pete.sh pete-once.sh
□ git init + initial commit
□ Run ./pete-once.sh to test one iteration interactively
□ Review output — tweak PROMPT.md if needed
□ Run ./pete.sh 15 and go touch grass 🌿
```

---

## Tuning Tips

- **If the AI keeps choosing the wrong task:** Add more explicit priority hints to your phase file task descriptions
- **If tasks are too big and context bloats:** Split them — each task should touch one component or concern
- **If the AI marks tasks complete without really verifying:** Add stack-specific verification steps to the PROMPT.md Step 5
- **If progress.txt gets huge:** It's fine to trim old entries after a phase completes — the git log serves as the real history
- **If a phase file's JSON gets corrupted:** Check git log and restore the last good version with `git checkout HEAD~1 -- phase1.md`
