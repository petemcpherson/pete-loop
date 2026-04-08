# Pete Loop

`pete-loop` is an autonomous build workflow for AI coding tools (Codex, Claude Code) that executes **one task per iteration** using a **fresh context window** each time.

It is designed for vibe coders who want reliable, incremental progress while they are away from the keyboard ("go touch grass mode").

Full tutorial video here: https://youtu.be/nJscwBE0NA4


## Keeping Pete Loop Updated

Pete Loop is actively maintained.

### Claude Code plugin updates

Claude Code does **not** auto-update plugins by default — enable it so you always get the latest version:

**Via UI:** Run `/plugin` → **Marketplaces** tab → select `petemcpherson-claude-plugins` → enable **Auto-update**

**Or manually update anytime:**
```bash
claude plugin update pete-loop@petemcpherson-claude-plugins
```

Then run `/reload-plugins` to apply the update.

### Codex plugin updates

Codex installation currently uses a local source path. Update by pulling the latest repo changes in your local plugin source directory, then restart Codex.

Example:

```bash
cd ~/.codex/plugins/pete-loop-src
git pull
```

### After updating the plugin — update your project files

Updating the plugin updates the skills, but **not** the files already copied into your project (like `pete.sh`). To pull the latest scripts into an existing project, run:

```shell
/pete-loop:update
```

This updates `pete.sh`, `pete-once.sh`, and `pete/README.md`. It will ask before touching `PROMPT.md`, and never touches your spec, plan, progress, or human-todo files.

---

## What This Project Includes

- A Claude Code plugin in `plugin/`
- A Codex plugin in `codex-plugin/`
- Five plugin skills:
  - `/pete-loop:setup` - scaffold the loop files into any project (first time)
  - `/pete-loop:update` - update system scripts in an existing project after a plugin update
  - `/pete-loop:new-run` - scaffold a new Pete Run subfolder for a new feature, v2, etc.
  - `/pete-loop:spec` - guided session to produce a strong `spec.md`
  - `/pete-loop:plan` - generate phased, task-by-task `plan.md` from your spec
- A "version 2" operating model (single `plan.md`, one-task loop, strict stop gate, progress logging)
- Some other resources

---

## How Pete Loop Works

At runtime, the loop script repeatedly:

1. Runs the configured agent with `pete/PROMPT.md` in headless/non-interactive mode
2. Forces exactly one task per iteration
3. Requires verification, updates `plan.md`, appends `progress.txt`, and commits
4. Starts next iteration in a fresh context (new run)

Agent-specific note:
- Claude Code plugin: includes a usage-threshold guard
- Codex plugin: no usage API check is available; loop behavior is controlled by script flags

This fresh-context-per-iteration model is the core design choice that keeps sessions focused and reduces drift.

---

## Prerequisites

- Git repository for your project
- For Claude Code usage:
  - Claude Code Pro installed and authenticated
  - Claude Code v1.0.33+ (plugins support)
- For Codex usage:
  - Codex CLI installed and authenticated
  - Codex plugin support enabled in your environment

---

## Install The Pete Loop Plugin

Use the install path for your agent.

### Claude Code - Option A: Marketplace UI (recommended)

1. Open Claude Code
2. Run `/plugin`
3. Go to the **Marketplaces** tab and add:
   - `petemcpherson/claude-plugins`
4. Go to **Discover**, find `pete-loop`, and install it
5. Choose scope:
   - **User** (all your projects)
   - **Project** (shared in this repo)
   - **Local** (only you, only this repo)

### Claude Code - Option B: Install via commands

Run these commands in Claude Code:

```shell
/plugin marketplace add petemcpherson/claude-plugins
/plugin install pete-loop@petemcpherson-claude-plugins
```

CLI equivalent:

```bash
claude plugin marketplace add petemcpherson/claude-plugins
claude plugin install pete-loop@petemcpherson-claude-plugins
```

After install, available commands are:

- `/pete-loop:setup`
- `/pete-loop:update`
- `/pete-loop:new-run`
- `/pete-loop:spec`
- `/pete-loop:plan`

### Claude Code - Local development install (from this repo)

If you are developing this plugin locally:

```bash
claude --plugin-dir ./plugin
```

Then run `/reload-plugins` after edits.

### Codex - Local marketplace install (current path)

Codex self-serve official publishing is still rolling out, so install from a local source path:

1. Clone the repo to your local Codex plugin area:

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

Important path rules for `source.path`:
- Must start with `./`
- Must be relative to the **marketplace root** (for `~/.agents/plugins/marketplace.json`, use paths rooted at `~`, such as `./.codex/plugins/...`)
- Must stay inside that root (do not use `..`)

3. Restart Codex, open Plugins, select `My Plugins`, and install `pete-loop`.

---

## Quick Start (Using Pete Loop In A Project)

### 1) Scaffold your project

Inside the target project:

```shell
/pete-loop:setup
```

This creates:

- `pete/PROMPT.md`
- `pete/pete.sh`
- `pete/pete-once.sh`
- `pete/spec.md`
- `pete/plan.md`
- `pete/progress.txt`
- `pete/human-todo.md`
- (and `.claude/settings.json` if it does not already exist)

### 2) Build a real spec

**YOU should spend a good deal of time on this step!**

Create a spec.md file with your notes, preferences, opinions, features, sub-features, everything.

You can also write out a bit and THEN run...

```shell
/pete-loop:spec
```

Claude Code will ask you clarifying questions. Answer the questions carefully. Better input here = better autonomous output later.

### 3) Generate phased tasks

```shell
/pete-loop:plan
```

This creates a single `pete/plan.md` with phases and task objects.

### 4) Test one interactive iteration

**NOTE**: I don't actually do this.

```bash
./pete/pete-once.sh
```

### 5) Run full autonomous loop

```bash
./pete/pete.sh 15
```

Use a small number first (`5`) until you trust the flow for that project.

For a **Pete Run** (new feature, v2, etc.), pass the subfolder name as the second arg:

```bash
./pete/pete.sh 15 v2
```

---

## Core Files You Will Use

- `pete/spec.md` - what you are building
- `pete/plan.md` - all phases + tasks in one file
- `pete/PROMPT.md` - loop policy and hard stop behavior
- `pete/progress.txt` - append-only run history
- `pete/human-todo.md` - tasks blocked on human action
- `pete/pete.sh` - autonomous loop runner (`./pete/pete.sh 15` or `./pete/pete.sh 15 v2`)
- `pete/pete-once.sh` - single interactive run

---

## Operational Rules (Important)

- One task per iteration, always
- Verify acceptance before marking pass
- No placeholder code / no TODO stubs
- Update task status only; do not restructure plan during loop runs
- Append to `progress.txt` only
- Never `git push` from loop runs
- If a task needs human input, add it to `human-todo.md` and mark blocked

---

## Monitoring While It Runs

In another terminal:

```bash
tail -f pete/progress.txt
```

and optionally:

```bash
watch -n 5 git log --oneline -10
```

---

## Exit Signals

The loop stops early if Claude returns:

- `<promise>COMPLETE</promise>` - all phases complete
- `<promise>BLOCKED</promise>` - all remaining tasks need human input

---

## Troubleshooting

- `/plugin` not available:
  - Update Claude Code and restart your terminal
- Skill not showing:
  - Run `/reload-plugins`
- Loop pauses as blocked:
  - Check `pete/human-todo.md`, resolve items, set affected tasks back to `false`, rerun
- Tasks too big / Claude over-scoping:
  - Split large tasks in `plan.md` so acceptance is singular and observable
- Usage threshold hit:
  - Wait for your 5-hour window reset, then rerun `./pete/pete.sh <N>`

---

## Security Notes

Plugins can execute code with your user privileges. Install only from trusted marketplaces.

The default Pete Loop setup uses sandboxed execution:
- Claude Code setup can create `.claude/settings.json`
- Codex setup uses `--sandbox workspace-write --ask-for-approval never` flags in `pete.sh`

---

## Repository Layout

This repository has two main areas:

- `version 2/` - reference docs and setup prompts for the current methodology
- `plugin/` - the distributable Claude Code plugin (`pete-loop`)
- `codex-plugin/` - the distributable Codex plugin (`pete-loop`)

---

## License

MIT - see `LICENSE`.

---

## Pete Runs — Adding Features, v2, or New Build Phases

Each time you use Pete Loop to build something — an initial app, a new feature, a v2 — that's a **Pete Run**. Every run gets its own subfolder inside `pete/` with its own isolated context.

This keeps each run focused (no stale history bleeding in), preserves all past runs naturally, and scales to any number of future builds.

### Folder Structure

```
pete/
├── pete.sh               ← accepts a subfolder arg
├── pete-once.sh          ← same
├── initial-build/        ← your first Pete Run (archived)
│   ├── spec.md
│   ├── plan.md
│   ├── progress.txt
│   ├── human-todo.md
│   └── PROMPT.md
└── user-auth/            ← a new Pete Run
    ├── spec.md
    ├── plan.md
    ├── progress.txt
    ├── human-todo.md
    └── PROMPT.md
```

### Starting a New Pete Run

The easiest way — one command does everything:

```shell
/pete-loop:new-run
```

This skill asks for a run name (e.g. `v2`, `user-auth`), then scaffolds the full subfolder: `spec.md` starter, `progress.txt`, `human-todo.md`, and a `PROMPT.md` with all paths already updated. No manual copying or path-editing required.

Then:

```shell
/pete-loop:spec    # guided spec session — it will ask which run
/pete-loop:plan    # generates plan.md — it will ask which run
./pete/pete.sh 15 user-auth
```

Monitor:

```bash
tail -f pete/user-auth/progress.txt
```

### (Optional) Archive Your Original Files

```bash
mkdir pete/initial-build
mv pete/spec.md pete/plan.md pete/progress.txt pete/human-todo.md pete/PROMPT.md pete/initial-build/
```

> The subfolder arg is the **second** arg — iterations always comes first.
> `./pete/pete.sh 15` still works exactly as before.
