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
    ├── plan.md         ← phase overview, points to phase files
    ├── progress.txt    ← append-only log of what Claude has done
    ├── human-todo.md   ← tasks Claude flagged as needing human input
    └── phases/
        ├── phase1.md
        ├── phase2.md
        └── ...
```

---

## Task Format (in phase files)

```json
{
  "id": "1.2",
  "category": "setup|feature|ui|testing",
  "description": "What to implement and any relevant context",
  "steps": ["step one", "step two"],
  "passes": false
}
```

`passes` has three states: `false` (todo), `true` (done), `"blocked"` (needs human).

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

- One task per iteration, always
- Skip tasks listed in `human-todo.md`
- Search codebase before assuming something isn't implemented
- No placeholder code, no stubs
- Append to `progress.txt`, never rewrite it
- One git commit per task, never push
- Read `.env.example` to know what credentials exist — assume all are populated
