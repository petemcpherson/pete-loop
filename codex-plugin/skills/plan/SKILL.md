---
name: plan
description: Generate a complete pete/plan.md from pete/spec.md. Creates all phases and tasks inline. Run this after /pete-loop:spec and before running the loop.
---

# Pete Loop — Generate plan.md

## Step 0: Determine target folder

Before anything else, ask the user:

> "Is this plan for your main `pete/` folder (first-time setup), or for a **Pete Run** subfolder (new feature, v2, etc.)? If a Pete Run, what's the subfolder name (e.g. `v2`, `user-auth`)?"

Use their answer to set the paths for this session:
- Root: read `pete/spec.md`, write `pete/plan.md`
- Pete Run: read `pete/<RUN_NAME>/spec.md`, write `pete/<RUN_NAME>/plan.md`

---

Read the spec file and generate a complete plan file with all phases and tasks.

## Task format

Every task must use this JSON structure:

```json
{
  "id": "X.Y",
  "category": "setup|feature|ui|testing",
  "description": "Single sentence describing what to build or configure",
  "acceptance": "Observable outcome that proves this task is done",
  "passes": false
}
```

## Rules for task design

- Use `"acceptance"` (observable outcome), NOT steps (implementation checklist)
- Each task should be completable in one focused AI session
- Each task typically touches ≤5 files — if it would touch many more, split it
- If you'd write more than 2 acceptance criteria, split the task
- Aim for 12–20 tasks per phase — smaller is better than larger
- Order tasks within each phase by dependency (blocking tasks first)
- Flag tasks that need human input (credentials, manual service setup, etc.)
  with a note in the description and set `"passes": "blocked"` if the prerequisite isn't done yet
- Before finalizing, review every task: "Can Codex complete this fully autonomously,
  or does it need the human to do something first?" Flag any that need human input.

## Output format

Write the full file to the target plan path determined in Step 0:

```markdown
<!-- plan.md -->
# [Project Name] — Build Plan

**Spec reference:** `spec.md`
**Progress log:** `progress.txt`

---

## Phase Overview

| Phase | Description | Status |
|-------|-------------|--------|
| 1 | [Phase name] | 🔴 pending |
| 2 | [Phase name] | 🔴 pending |

---

## Tech Stack

[From spec.md — list only what this project actually uses]

---

## Phase 1: [Name]
**Status:** 🔴 pending

` `` `json
[
  { ... tasks ... }
]
` `` `

## Phase 2: [Name]
**Status:** 🔴 pending

` `` `json
[
  { ... tasks ... }
]
` `` `
```

## After writing

Tell the user:
- plan.md is ready with [N] phases and [total] tasks
- If this is the root `pete/` folder: run `./pete/pete-once.sh` to test one iteration, then `./pete/pete.sh 15` to go AFK
- If this is a Pete Run (`<RUN_NAME>`): run `./pete/pete-once.sh <RUN_NAME>` to test, then `./pete/pete.sh 15 <RUN_NAME>` to go AFK
