---
name: new-run
description: Scaffold a new Pete Run subfolder inside pete/. Use this when starting a new feature, v2, or any new build phase on an existing Pete Loop project. Creates the subfolder with all required files (PROMPT.md with correct paths, spec.md starter, progress.txt, human-todo.md).
disable-model-invocation: true
allowed-tools: Read, Write, Bash(mkdir *), Bash(test *), Bash(ls *)
---

# Pete Loop — New Run Setup

A **Pete Run** is a self-contained build phase (new feature, v2, etc.) that lives in its own subfolder inside `pete/`. Each run has isolated context so completed history from prior runs never bleeds in.

## Step 1: Get the run name

Ask the user: "What would you like to name this Pete Run? (e.g. `v2`, `user-auth`, `payments`)"

Use their answer as `<RUN_NAME>` for the rest of this skill.

## Step 2: Create the subfolder

Run: `mkdir -p pete/<RUN_NAME>`

## Step 3: Create spec.md starter

Write `pete/<RUN_NAME>/spec.md` with this content:

```markdown
<!-- spec.md -->
# [Project Name] — Specification

## Overview

[1-2 sentence description of what this build phase does]

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

### Nice-to-Have (Post-MVP)
- [ ] Feature A

---

## User Flows

[Key user journeys step by step]

---

## Data Models

[Main data structures / DB schema]

---

## API / Integrations

[Third-party APIs, webhooks, or services]

---

## Design Notes

[Colors, fonts, vibe, UI references]

---

## Constraints & Non-Goals

[What this build phase explicitly does NOT do]
```

## Step 4: Create progress.txt

Write `pete/<RUN_NAME>/progress.txt` with this content:

```
# progress.txt
# Pete Loop — Progress & Learnings Log
# Agent appends dated entries here. Do not manually edit.

[Run started]
```

## Step 5: Create human-todo.md

Write `pete/<RUN_NAME>/human-todo.md` with this content:

```markdown
# human-todo.md
# Tasks that require human input before the loop can proceed.
# Format: - [ ] **Task X.Y** — [What the human needs to do]
#                              (Context: why this is needed / what it unblocks)
```

## Step 6: Create PROMPT.md with correct paths

Read `pete/PROMPT.md`. Take its full contents and replace every occurrence of the following paths:

| Replace | With |
|---------|------|
| `@pete/plan.md` | `@pete/<RUN_NAME>/plan.md` |
| `@pete/progress.txt` | `@pete/<RUN_NAME>/progress.txt` |
| `@pete/human-todo.md` | `@pete/<RUN_NAME>/human-todo.md` |
| `pete/spec.md` | `pete/<RUN_NAME>/spec.md` |
| `pete/plan.md` | `pete/<RUN_NAME>/plan.md` |
| `pete/progress.txt` | `pete/<RUN_NAME>/progress.txt` |
| `pete/human-todo.md` | `pete/<RUN_NAME>/human-todo.md` |

Write the result to `pete/<RUN_NAME>/PROMPT.md`.

## Step 7: Confirm and guide next steps

Tell the user:

- ✅ Pete Run `<RUN_NAME>` scaffolded at `pete/<RUN_NAME>/`
- Files created: `spec.md`, `plan.md` (pending), `progress.txt`, `human-todo.md`, `PROMPT.md`
- All PROMPT.md paths are already pointing to `pete/<RUN_NAME>/`
- **Next steps:**
  1. Fill in `pete/<RUN_NAME>/spec.md` — or run `/pete-loop:spec` and choose `<RUN_NAME>` when asked
  2. Run `/pete-loop:plan` and choose `<RUN_NAME>` when asked — this generates the task list
  3. Run `./pete/pete.sh 15 <RUN_NAME>` to start the loop
