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
│       ├── new-run/
│       └── update/
│
└── codex-plugin/                    # NEW — Codex plugin
    ├── .codex-plugin/
    │   └── plugin.json              # Codex manifest
    └── skills/
        ├── setup/
        │   ├── SKILL.md             # Adapted (stripped frontmatter, step 2 & 3 changes)
        │   └── templates/
        │       ├── PROMPT.md        # Adapted (CLAUDE.md → AGENTS.md)
        │       ├── pete.sh          # Adapted (codex exec, no usage check)
        │       ├── pete-once.sh     # Adapted (codex TUI invocation)
        │       ├── spec.md          # Unchanged (generic)
        │       ├── plan.md          # Unchanged (generic)
        │       ├── progress.txt     # Unchanged (generic)
        │       ├── human-todo.md    # Unchanged (generic)
        │       └── README.md        # Updated for Codex context
        │       # NOTE: settings.json is NOT copied — no Codex equivalent
        ├── spec/
        │   └── SKILL.md             # Adapted (stripped frontmatter)
        ├── plan/
        │   └── SKILL.md             # Adapted (stripped frontmatter)
        ├── new-run/
        │   └── SKILL.md             # Adapted (stripped frontmatter)
        └── update/
            ├── SKILL.md             # Adapted (stripped frontmatter, CLAUDE.md → AGENTS.md)
            └── templates/
                ├── pete.sh          # Same adaptation as setup/templates/pete.sh
                ├── pete-once.sh     # Same adaptation as setup/templates/pete-once.sh
                ├── PROMPT.md        # Same adaptation as setup/templates/PROMPT.md
                └── README.md        # Same adaptation as setup/templates/README.md
```

---

## Implementation Phases

### Phase 1: One Remaining Research Item

Most CLI unknowns are now resolved. One item still needs verification before writing the setup skill:

- [x] **1.1** — Confirm the exact skill-directory variable Codex exposes inside `SKILL.md`
  - **Resolution:** No skill-dir variable is documented in Codex plugin docs. Used fallback: all template content is inlined directly in `setup/SKILL.md` and `update/SKILL.md`.
  - The Claude Code equivalent is `${CLAUDE_SKILL_DIR}` — points to the skill's own directory so it can read template files
  - Check: https://developers.openai.com/codex/skills
  - The `setup` skill reads all templates from this path; if it's unavailable, the fallback is to inline all template content directly in the SKILL.md body (verbose but functional)

---

### Phase 2: Create Codex Manifest

- [x] **2.1** — Create `codex-plugin/.codex-plugin/plugin.json`

  ```json
  {
    "name": "pete-loop",
    "version": "2.2.5",
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

- [x] **3.1** — Create `codex-plugin/skills/setup/SKILL.md`

  **Frontmatter changes:**
  - Remove: `disable-model-invocation: true`
  - Remove: `allowed-tools: ...`

  **Body changes:**
  - Replace `${CLAUDE_SKILL_DIR}` with the Codex equivalent (from Phase 1.1)
  - In Step 2 copy table: remove the `settings.json` row — there is no `.claude/settings.json` equivalent in Codex
  - Replace Step 3 (create `.claude/settings.json`) with:
    > Since Codex has no project-level config file, skip file creation. Instead, inform the user:
    > "Pete Loop runs AFK using `--sandbox workspace-write --ask-for-approval never`. These flags are baked into `pete/pete.sh`. No project config file is needed."
  - Update Step 5 next-step instructions to use Codex skill invocation syntax

- [x] **3.2** — Create `codex-plugin/skills/spec/SKILL.md`
  - Remove: `disable-model-invocation: true`
  - Body is otherwise identical to Claude Code version

- [x] **3.3** — Create `codex-plugin/skills/plan/SKILL.md`
  - Remove: `disable-model-invocation: true`
  - Remove: `allowed-tools: Read, Write`
  - Body is otherwise identical to Claude Code version

- [x] **3.4** — Create `codex-plugin/skills/new-run/SKILL.md`
  - Remove: `disable-model-invocation: true`
  - Remove: `allowed-tools: ...`
  - Body is otherwise identical to Claude Code version

- [x] **3.5** — Create `codex-plugin/skills/update/SKILL.md`
  - Remove: `disable-model-invocation: true`
  - Remove: `allowed-tools: ...`
  - Body changes: replace `${CLAUDE_SKILL_DIR}` with the Codex equivalent (from Phase 1.1)
  - Body changes: the update skill's Step 3 asks about PROMPT.md reset — ensure the ask references `AGENTS.md` behavior, not `CLAUDE.md`
  - Otherwise identical to Claude Code version

---

### Phase 4: Adapt Templates

#### 4.1 — `pete.sh` (the AFK loop)

Key changes from the Claude Code version:
- Replace `claude -p "..." --output-format text` with `codex exec "..." --output-last-message <tmpfile>`
- Remove the entire `check_usage()` function (queries Anthropic OAuth API — no public Codex equivalent)
- Use `--sandbox workspace-write --ask-for-approval never` for AFK-safe execution

- [x] Create `codex-plugin/skills/setup/templates/pete.sh`:

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

- [x] Create `codex-plugin/skills/setup/templates/pete-once.sh`:

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

- [x] Create `codex-plugin/skills/setup/templates/PROMPT.md`
  - Replace every reference to `CLAUDE.md` with `AGENTS.md` — this appears in **Step 4 (Verify)**: "Check `pete/spec.md` and `CLAUDE.md` for the project's tech stack…"
  - All other content is identical — the loop instructions are fully generic

#### 4.4 — Unchanged templates

- [x] Copy from `plugin/skills/setup/templates/` as-is:
  - `spec.md`
  - `plan.md`
  - `progress.txt`
  - `human-todo.md`

#### 4.5 — `README.md`

- [x] Create `codex-plugin/skills/setup/templates/README.md`
  - Remove the `.claude/settings.json` Required Policy block and the sandbox warning at the top
  - Update the "Customizing PROMPT.md" section: remove references to Claude-specific skills/MCP servers; reference `AGENTS.md` instead of `CLAUDE.md`
  - In the "Updating Pete Loop" section: replace `/pete-loop:update` invocation syntax with Codex equivalent
  - Remove reference to `settings.json` from the Files list
  - All other content (Pete Runs section, tuning tips, first-time setup steps) is generic — keep as-is

#### 4.6 — `update` skill templates

The `update` skill has its own `templates/` directory that mirrors the files it will overwrite in a user's project (`pete.sh`, `pete-once.sh`, `PROMPT.md`, `README.md`). These must be kept in sync with the setup skill templates.

- [x] Create `codex-plugin/skills/update/templates/pete.sh` — identical to `codex-plugin/skills/setup/templates/pete.sh`
- [x] Create `codex-plugin/skills/update/templates/pete-once.sh` — identical to `codex-plugin/skills/setup/templates/pete-once.sh`
- [x] Create `codex-plugin/skills/update/templates/PROMPT.md` — identical to `codex-plugin/skills/setup/templates/PROMPT.md`
- [x] Create `codex-plugin/skills/update/templates/README.md` — identical to `codex-plugin/skills/setup/templates/README.md`

---

### Phase 5: Local Testing

- [ ] **5.1** — Create a personal local marketplace for testing

  Step 1: Copy (or symlink) the plugin folder into `~/.codex/plugins/`:
  ```bash
  mkdir -p ~/.codex/plugins
  cp -R /absolute/path/to/pete-loop/codex-plugin ~/.codex/plugins/pete-loop
  ```

  Step 2: Create `~/.agents/plugins/marketplace.json` (or add an entry if it already exists):
  ```json
  {
    "name": "personal",
    "interface": {
      "displayName": "My Plugins"
    },
    "plugins": [
      {
        "name": "pete-loop",
        "source": {
          "source": "local",
          "path": "./.codex/plugins/pete-loop"
        },
        "policy": {
          "installation": "AVAILABLE",
          "authentication": "ON_INSTALL"
        },
        "category": "Productivity"
      }
    ]
  }
  ```
  Note: `source.path` is relative to the marketplace file's location (`~/.agents/plugins/`), must start with `./`, and must stay inside that root.

  Step 3: Restart Codex.

- [ ] **5.2** — Open the Codex plugin directory, select the "My Plugins" marketplace, and install `pete-loop` from there.

- [ ] **5.3** — Test each skill in a fresh test project:
  - Invoke setup skill → verify `pete/` scaffold is created, scripts are executable, no `settings.json` is created
  - Invoke spec skill → verify `pete/spec.md` is generated with correct content
  - Invoke plan skill → verify `pete/plan.md` is generated from spec
  - Invoke new-run skill → verify named subfolder is scaffolded with correct paths in PROMPT.md
  - Invoke update skill → verify `pete.sh`, `pete-once.sh`, `README.md` are overwritten; PROMPT.md is asked about; spec/plan/progress/human-todo untouched
  - Run `./pete/pete-once.sh` → verify interactive Codex session launches with PROMPT.md content
  - Run `./pete/pete.sh 3` → verify 3 non-interactive iterations complete, output is captured, COMPLETE/BLOCKED detection works

- [ ] **5.4** — Verify `pete.sh` loop terminates correctly:
  - On `<promise>COMPLETE</promise>` in final message → exits 0
  - On `<promise>BLOCKED</promise>` in final message → exits 2
  - On max iterations → exits 1

---

### Phase 6: Repository & Distribution

- [x] **6.1** — Update root `README.md` to include Codex installation alongside Claude Code
  - Side-by-side install instructions for both agents
  - Note any behavioral differences (no usage check, `AGENTS.md` vs `CLAUDE.md`)

- [ ] **6.2** — Update `MAINTAINER-NOTES.md` with guidance on keeping both plugins in sync

- [ ] **6.3** — Tag a new release (e.g., `v2.3.0`) covering both plugin variants

- [ ] **6.4** — When OpenAI opens self-serve publishing, submit to official Codex plugin directory
  - **Status as of April 2026: Not yet available.** The docs say "Adding plugins to the official Plugin Directory is coming soon."
  - Track: https://developers.openai.com/codex/plugins/build

---

### Phase 7: Public Distribution

The official Codex plugin marketplace does not support self-serve publishing yet ("coming soon" as of April 2026). In the meantime, the GitHub repo is the distribution channel — users clone it, wire up a marketplace.json locally, and install from there. This section covers what needs to ship in the repo for that to work smoothly, and what to do when the official marketplace opens.

---

#### 7.1 — GitHub distribution (available now)

Once `codex-plugin/` is committed and pushed to the public repo, any Codex user can install pete-loop by following a short manual setup. The repo is already public at `https://github.com/petemcpherson/pete-loop`.

The install flow for end users:

1. Clone the repo (or pull latest):
   ```bash
   git clone https://github.com/petemcpherson/pete-loop.git ~/.codex/plugins/pete-loop-src
   ```
2. Create or update `~/.agents/plugins/marketplace.json`:
   ```json
   {
     "name": "personal",
     "interface": {
       "displayName": "My Plugins"
     },
     "plugins": [
       {
         "name": "pete-loop",
         "source": {
           "source": "local",
           "path": "./.codex/plugins/pete-loop-src/codex-plugin"
         },
         "policy": {
           "installation": "AVAILABLE",
           "authentication": "ON_INSTALL"
         },
         "category": "Productivity"
       }
     ]
   }
   ```
   Note: `source.path` is relative to `~/.agents/plugins/` and must start with `./`.
3. Restart Codex, open the plugin directory, select "My Plugins", install `pete-loop`.

To get updates later: `git pull` in `~/.codex/plugins/pete-loop-src`, then restart Codex.

**What this phase requires:**

- [x] **7.1** — Write a clear **Codex install guide** block in the root `README.md` (covered in Phase 6.1), containing exactly the three steps above. This is the only thing users need; no scripts required.

---

#### 7.2 — Official Codex Plugin Directory (not yet available)

> **Status as of April 2026: Self-serve publishing is not open.** OpenAI's docs say "Adding plugins to the official Plugin Directory is coming soon."

When it opens, the submission process will likely involve:
- Providing the plugin manifest (`plugin.json`) with full `interface` metadata
- Uploading assets (icon, screenshots) — paths defined in `interface.composerIcon`, `interface.logo`, `interface.screenshots`
- Agreeing to a developer agreement / terms

**What you (Pete) need to do manually when this opens:**

> ⚠️ **MANUAL ACTION REQUIRED (future)**
>
> 1. Watch https://developers.openai.com/codex/plugins/build for a "Publish" or "Submit" button/flow to appear.
> 2. Prepare assets if required: a square plugin icon (PNG, recommended 512×512) and optionally a logo and 1–2 screenshots. Store them in `codex-plugin/assets/` and add the paths to `plugin.json` under `interface.composerIcon`, `interface.logo`, and `interface.screenshots`.
> 3. Ensure `plugin.json` has complete `interface` metadata: `privacyPolicyURL` and `termsOfServiceURL` may be required. A GitHub URL is acceptable for both (e.g. link to a `PRIVACY.md` in the repo).
> 4. Submit through whatever portal OpenAI provides. There is no automation possible here — it requires a human account action.

- [ ] **7.2** — Add `codex-plugin/assets/` with a plugin icon when preparing for official submission
- [ ] **7.3** — Add `privacyPolicyURL` and `termsOfServiceURL` to `codex-plugin/.codex-plugin/plugin.json` before submitting (GitHub links to policy files in the repo are acceptable)
- [ ] **7.4** — Submit to the official directory once self-serve publishing opens

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
