---
name: update
description: Update Pete Loop system files (pete.sh, pete-once.sh, README.md) in this project to the latest plugin version. Safe to run anytime — never overwrites your spec, plan, progress, or human-todo files. Asks before touching PROMPT.md.
disable-model-invocation: true
allowed-tools: Read, Write, Bash(chmod *), Bash(test *)
---

# Pete Loop — Update

Update the Pete Loop system scripts in this project to match the current plugin version. Only safe, non-user-edited files are overwritten automatically. Your spec, plan, progress, human-todo, and PROMPT.md are never touched without asking.

## Step 1: Check that pete/ exists

Run: `test -d pete`

If it does not exist, stop and tell the user:
> ❌ No `pete/` folder found in this project. Run `/pete-loop:setup` first to scaffold Pete Loop.

## Step 2: Update system scripts

Read each file from `${CLAUDE_SKILL_DIR}/templates/` and write it to the project at the destination shown:

| Source (read from) | Destination (write to) |
|---|---|
| `${CLAUDE_SKILL_DIR}/templates/pete.sh` | `pete/pete.sh` |
| `${CLAUDE_SKILL_DIR}/templates/pete-once.sh` | `pete/pete-once.sh` |
| `${CLAUDE_SKILL_DIR}/templates/README.md` | `pete/README.md` |

After writing, run: `chmod +x pete/pete.sh pete/pete-once.sh`

## Step 3: Ask about PROMPT.md

Tell the user:

> **PROMPT.md** is the instruction set fed to Claude on every loop iteration. The latest plugin version may include improvements, but you may also have customized it for your workflow.
>
> Would you like to reset `pete/PROMPT.md` to the latest template? **This will overwrite any customizations you've made.**
>
> Reply **yes** to overwrite, or **no** to keep your current version.

- If **yes**: read `${CLAUDE_SKILL_DIR}/templates/PROMPT.md` and write it to `pete/PROMPT.md`.
- If **no**: leave `pete/PROMPT.md` untouched.

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
