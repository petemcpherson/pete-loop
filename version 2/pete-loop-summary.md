# The Pete Loop

A personal variation of the Ralph Wiggum autonomous coding technique for Claude Code.
Uses a fresh context window every iteration. Built for Claude Pro subscription users.

---

## How It Works

A bash script (`pete/pete.sh`) runs Claude Code in a loop. Each iteration:
1. Checks subscription usage (stops if 5-hour session exceeds 85%)
2. Feeds `pete/PROMPT.md` to Claude as a headless prompt (`claude -p`)
3. Claude reads the plan, picks one task, implements it, commits, and stops
4. Loop repeats until complete, blocked, or max iterations reached

Each iteration runs in a **fresh context window** — this is the key difference from the official Claude Code Ralph plugin.

---

## File Structure

```
your-project/
├── .env.example        ← committed, empty values, Claude reads this
├── .env                ← real secrets, denied in settings.json
├── .mcp.json           ← MCP server registrations (auto-loaded)
├── .claude/
│   └── settings.json   ← sandbox + permissions config
└── pete/
    ├── pete.sh         ← main loop (run from project root)
    ├── pete-once.sh    ← single interactive iteration for testing
    ├── PROMPT.md       ← instructions fed to Claude every iteration
    ├── spec.md         ← what you're building (human-authored, AI-assisted)
    ├── plan.md         ← ALL phases and tasks in one file
    ├── progress.txt    ← append-only log of what Claude has done
    └── human-todo.md   ← tasks Claude flagged as needing human input
```

All phases and tasks live inline in `plan.md` — there is no separate `phases/` folder.

---

## Task Format (in plan.md)

```json
{
  "id": "1.2",
  "category": "setup|feature|ui|testing",
  "description": "Single sentence: what to build or configure",
  "acceptance": "Observable outcome that proves this is done",
  "passes": false
}
```

`passes` has three states: `false` (todo), `true` (done), `"blocked"` (needs human).

**No `steps` field.** The `acceptance` field describes the end state, not the implementation path. This prevents Claude from treating a multi-step checklist as a multi-task work order.

**Task sizing:** Aim for 12–20 tasks per phase. A well-sized task typically touches ≤5 files and has one clear acceptance criterion. If a task implies 3+ distinct behaviors, split it.

---

## plan.md Structure

All phases live in one file. Claude reads one file, picks one task, stops.

```markdown
## Phase Overview
| Phase | Description | Status |
| 1 | Setup | 🔴 pending |
| 2 | Core Features | 🔴 pending |

## Phase 1: Setup
**Status:** 🔴 pending

```json
[
  { "id": "1.1", "description": "...", "acceptance": "...", "passes": false },
  { "id": "1.2", "description": "...", "acceptance": "...", "passes": false }
]
```

## Phase 2: Core Features
**Status:** 🔴 pending
...
```

---

## Running the Loop

```bash
# Test one iteration interactively first
./pete/pete-once.sh

# Run the full loop (from project root)
./pete/pete.sh 15

# Monitor progress in another terminal
tail -f pete/progress.txt
watch -n 5 git log --oneline -10
```

---

## Exit Signals

Claude outputs one of these to end the loop early:

| Signal | Meaning |
|--------|---------|
| `<promise>COMPLETE</promise>` | All phases done |
| `<promise>BLOCKED</promise>` | All remaining tasks need human input |

---

## Key Rules Baked Into PROMPT.md

- One task per iteration — enforced with a hard ⛔ STOP gate after commit
- Skip tasks listed in `human-todo.md`
- Search codebase before assuming something isn't implemented
- Verify `acceptance` criteria are met before marking a task passing
- No placeholder code, no stubs
- Append to `progress.txt`, never rewrite it
- One git commit per task, never push
- Read `.env.example` to know what credentials exist — assume all are populated
