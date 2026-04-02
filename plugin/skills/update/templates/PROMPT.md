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
[X.Y done YYYY-MM-DD] Brief description. ⚠️  Learning: [only if there's a genuine gotcha,
else omit]
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
