# Pete Loop — Codex Plugin Implementation Plan

## Overview

This document outlines the implementation plan for releasing Pete Loop as an OpenAI Codex plugin, alongside the existing Claude Code plugin. The goal is a parallel `codex-plugin/` directory that mirrors the Claude Code `plugin/` structure, adapted for the Codex plugin specification.

---

## Background: Codex Plugin System (as of v0.117.0, March 2026)

Codex plugins are installable bundles of **skills**, **MCP servers**, and **app integrations**. They are distributed via the Codex plugin marketplace (self-serve publishing coming soon) or locally via `marketplace.json` files.

**Installation commands:**
```bash
/plugins          # browse and install interactively
codex plugin install <name>
codex plugin list
```

**Official plugin docs:** https://developers.openai.com/codex/plugins/build

---

## Key Differences: Claude Code Plugin vs Codex Plugin

| Concern | Claude Code | Codex | Status |
|---|---|---|---|
| Manifest directory | `.claude-plugin/plugin.json` | `.codex-plugin/plugin.json` | ✅ Resolved |
| Non-interactive CLI | `claude -p "..."` | `codex exec "..."` | ✅ Resolved |
| Output capture | `--output-format text` | `--output-last-message <path>` | ✅ Resolved |
| AFK flags | `--no-interactive` | `--sandbox workspace-write --ask-for-approval never` | ✅ Resolved |
| Skill dir variable | `${CLAUDE_SKILL_DIR}` | `${CODEX_SKILL_DIR}` (unconfirmed name) | ⚠️ Needs verification |
| Skill frontmatter: disable model | `disable-model-invocation: true` | Not supported — remove | ✅ Resolved |
| Skill frontmatter: tool allowlist | `allowed-tools: Read, Write, Bash(...)` | Not supported — remove | ✅ Resolved |
| Manifest: marketplace metadata | Not present | `interface` object | ✅ Resolved |
| Project-level config | `.claude/settings.json` (sandbox, permissions) | No equivalent — `~/.codex/config.toml` is user-level only | ✅ Resolved |
| Project context file | `CLAUDE.md` | `AGENTS.md` | ✅ Resolved |
| Usage/rate-limit check | Queries Anthropic OAuth API | Remove entirely (no public equivalent) | ✅ Resolved |

---

## Directory Structure (Target)

```
pete-loop/
├── plugin/                          # Existing Claude Code plugin (unchanged)
│   ├── .claude-plugin/
│   │   └── plugin.json
│   └── skills/
│       ├── setup/
│       ├── spec/
│       ├── plan/
│       └── new-run/
│
└── codex-plugin/                    # NEW — Codex plugin
    ├── .codex-plugin/
    │   └── plugin.json              # Codex manifest
    └── skills/
        ├── setup/
        │   ├── SKILL.md             # Adapted (stripped frontmatter, new step 3)
        │   └── templates/
        │       ├── PROMPT.md        # Adapted (CLAUDE.md → AGENTS.md)
        │       ├── pete.sh          # Adapted (codex exec, no usage check)
        │       ├── pete-once.sh     # Adapted (codex TUI invocation)
        │       ├── spec.md          # Unchanged (generic)
        │       ├── plan.md          # Unchanged (generic)
        │       ├── progress.txt     # Unchanged (generic)
        │       ├── human-todo.md    # Unchanged (generic)
        │       └── README.md        # Updated for Codex context
        ├── spec/
        │   └── SKILL.md             # Adapted (stripped frontmatter)
        ├── plan/
        │   └── SKILL.md             # Adapted (stripped frontmatter)
        └── new-run/
            └── SKILL.md             # Adapted (stripped frontmatter)
```

---

## Implementation Phases

### Phase 1: One Remaining Research Item

Most CLI unknowns are now resolved. One item still needs verification before writing the setup skill:

- [ ] **1.1** — Confirm the exact skill-directory variable Codex exposes inside `SKILL.md`
  - The Claude Code equivalent is `${CLAUDE_SKILL_DIR}` — points to the skill's own directory so it can read template files
  - Check: https://developers.openai.com/codex/skills
  - The `setup` skill reads all templates from this path; if it's unavailable, the fallback is to inline all template content directly in the SKILL.md body (verbose but functional)

---

### Phase 2: Create Codex Manifest

- [ ] **2.1** — Create `codex-plugin/.codex-plugin/plugin.json`

  ```json
  {
    "name": "pete-loop",
    "version": "2.2.0",
    "description": "Autonomous build loop for Codex. Implements one task per fresh context window from a structured spec → plan → loop workflow.",
    "author": "Pete McPherson",
    "homepage": "https://github.com/petemcpherson/pete-loop",
    "repository": "https://github.com/petemcpherson/pete-loop",
    "license": "MIT",
    "keywords": ["autonomous", "loop", "build", "agent", "workflow"],
    "skills": "./skills/",
    "interface": {
      "displayName": "Pete Loop",
      "shortDescription": "Autonomous build loop — one task per context window, AFK.",
      "longDescription": "Pete Loop gives you a structured autonomous build workflow. Fill in a spec, generate a plan, then let the loop implement one task per fresh context window — committing as it goes. Built for users who want to go AFK while Codex builds.",
      "developerName": "Pete McPherson",
      "category": "developer-tools",
      "capabilities": ["skills"],
      "websiteURL": "https://github.com/petemcpherson/pete-loop",
      "defaultPrompt": "Set up Pete Loop in my project"
    }
  }
  ```

---

### Phase 3: Adapt Skills

Each skill needs its frontmatter stripped of Claude Code-specific fields. The skill body content is largely identical. The `setup` skill has the most changes.

- [ ] **3.1** — Create `codex-plugin/skills/setup/SKILL.md`

  **Frontmatter changes:**
  - Remove: `disable-model-invocation: true`
  - Remove: `allowed-tools: ...`

  **Body changes:**
  - Replace `${CLAUDE_SKILL_DIR}` with the Codex equivalent (from Phase 1.1)
  - Replace Step 3 (create `.claude/settings.json`) with:
    > Since Codex has no project-level config file, skip file creation. Instead, inform the user:
    > "Pete Loop runs AFK using `--sandbox workspace-write --ask-for-approval never`. These flags are baked into `pete/pete.sh`. No project config file is needed."
  - Update Step 5 next-step instructions to use Codex skill invocation syntax

- [ ] **3.2** — Create `codex-plugin/skills/spec/SKILL.md`
  - Remove: `disable-model-invocation: true`
  - Body is otherwise identical to Claude Code version

- [ ] **3.3** — Create `codex-plugin/skills/plan/SKILL.md`
  - Remove: `disable-model-invocation: true`
  - Remove: `allowed-tools: Read, Write`
  - Body is otherwise identical to Claude Code version

- [ ] **3.4** — Create `codex-plugin/skills/new-run/SKILL.md`
  - Remove: `disable-model-invocation: true`
  - Remove: `allowed-tools: ...`
  - Body is otherwise identical to Claude Code version

---

### Phase 4: Adapt Templates

#### 4.1 — `pete.sh` (the AFK loop)

Key changes from the Claude Code version:
- Replace `claude -p "..." --output-format text` with `codex exec "..." --output-last-message <tmpfile>`
- Remove the entire `check_usage()` function (queries Anthropic OAuth API — no public Codex equivalent)
- Use `--sandbox workspace-write --ask-for-approval never` for AFK-safe execution

- [ ] Create `codex-plugin/skills/setup/templates/pete.sh`:

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

#### 4.2 — `pete-once.sh` (human-watches single iteration)

The Claude Code version calls `claude "$(cat ...)"` — interactive TUI. The Codex equivalent is `codex "$(cat ...)"`.

- [ ] Create `codex-plugin/skills/setup/templates/pete-once.sh`:

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

#### 4.3 — `PROMPT.md`

- [ ] Create `codex-plugin/skills/setup/templates/PROMPT.md`
  - Replace every reference to `CLAUDE.md` with `AGENTS.md`
  - All other content is identical — the loop instructions are fully generic

#### 4.4 — Unchanged templates

- [ ] Copy from `plugin/skills/setup/templates/` as-is:
  - `spec.md`
  - `plan.md`
  - `progress.txt`
  - `human-todo.md`

#### 4.5 — `README.md`

- [ ] Create `codex-plugin/skills/setup/templates/README.md`
  - Remove all references to Claude Code sandbox mode, `CLAUDE.md`, `settings.json`
  - Update "AFK" section to describe `--sandbox workspace-write --ask-for-approval never` flags
  - Reference `AGENTS.md` for project context

---

### Phase 5: Local Testing

- [ ] **5.1** — Create a personal local marketplace for testing

  At `~/.agents/plugins/marketplace.json`:
  ```json
  {
    "plugins": [
      {
        "name": "pete-loop",
        "path": "/absolute/path/to/pete-loop/codex-plugin"
      }
    ]
  }
  ```

- [ ] **5.2** — Install: `codex plugin install pete-loop`

- [ ] **5.3** — Test each skill in a fresh test project:
  - Invoke setup skill → verify `pete/` scaffold is created, scripts are executable
  - Invoke spec skill → verify `pete/spec.md` is generated with correct content
  - Invoke plan skill → verify `pete/plan.md` is generated from spec
  - Run `./pete/pete-once.sh` → verify interactive Codex session launches with PROMPT.md content
  - Run `./pete/pete.sh 3` → verify 3 non-interactive iterations complete, output is captured, COMPLETE/BLOCKED detection works

- [ ] **5.4** — Verify `pete.sh` loop terminates correctly:
  - On `<promise>COMPLETE</promise>` in final message → exits 0
  - On `<promise>BLOCKED</promise>` in final message → exits 2
  - On max iterations → exits 1

---

### Phase 6: Repository & Distribution

- [ ] **6.1** — Update root `README.md` to include Codex installation alongside Claude Code
  - Side-by-side install instructions for both agents
  - Note any behavioral differences (no usage check, `AGENTS.md` vs `CLAUDE.md`)

- [ ] **6.2** — Update `MAINTAINER-NOTES.md` with guidance on keeping both plugins in sync

- [ ] **6.3** — Tag a new release (e.g., `v2.3.0`) covering both plugin variants

- [ ] **6.4** — When OpenAI opens self-serve publishing, submit to official Codex plugin directory
  - Track: https://developers.openai.com/codex/plugins

---

## Resolved Questions

| Question | Answer |
|---|---|
| Non-interactive CLI command | `codex exec "..."` |
| Capture output for COMPLETE/BLOCKED | `--output-last-message <tmpfile>`, then read the file |
| AFK-safe flags | `--sandbox workspace-write --ask-for-approval never` |
| Project-level config equivalent | None — no project-level config in Codex; flags go in the shell scripts |
| Claude.md equivalent | `AGENTS.md` (confirmed in Codex CLI reference) |
| Usage/rate-limit check | Remove entirely — no public Codex API equivalent for this |

## Remaining Open Questions

| Question | Impact |
|---|---|
| Exact name of skill-dir variable (`${CODEX_SKILL_DIR}`?) | Blocks writing the `setup` SKILL.md — can fallback to inlining templates |
| Codex plugin marketplace self-serve publishing timeline | Affects Phase 6 public distribution; local install works in the meantime |
