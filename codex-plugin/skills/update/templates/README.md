# Pete Loop — Quick Start

## Customizing PROMPT.md for your setup

`PROMPT.md` is the instruction set Codex reads on every loop iteration — it's worth tailoring it to your workflow. Common additions:

- **Commit style** — add a line like *"Do NOT add a Co-Authored-By attribution"* if you don't want that in your git history
- **Tech stack context** — reference your `AGENTS.md` for project-specific conventions

See [`Resources/prompt-improvements.md`](https://github.com/petemcpherson/pete-loop/blob/main/Resources/prompt-improvements.md) for concrete examples and copy-paste snippets.

## First time setup
1. Fill in `pete/spec.md` — run `/pete-loop:spec` for AI-guided help
2. Generate `pete/plan.md` — run `/pete-loop:plan` after spec is done
3. Run `./pete/pete.sh 5` to start the loop (low iteration count is a good first run) 🌿

## Files
- `spec.md` — What you're building (fill this in first)
- `plan.md` — Phased task list (one task per loop iteration)
- `PROMPT.md` — The prompt fed to Codex each iteration (don't edit unless tuning)
- `progress.txt` — Rolling log appended by Codex each iteration
- `human-todo.md` — Tasks the loop paused on (needs your input)
- `pete.sh` — The main loop script (`./pete/pete.sh 15`)
- `pete-once.sh` — Single interactive iteration, useful for watching one iteration hands-on

## Pete Runs — Starting a New Build Phase

Each time you use Pete Loop to build something new — a feature, a v2, a new phase — that's a **Pete Run**. Each run lives in its own subfolder with isolated context.

Start one with a single command:

```shell
/pete-loop:new-run
```

It asks for a name, scaffolds the subfolder, and wires up all the paths in `PROMPT.md` automatically. Then:

```shell
/pete-loop:spec   # write the spec (will ask which run)
/pete-loop:plan   # generate the plan (will ask which run)
./pete/pete.sh 15 v2
```

Subfolder is the **second** arg — `./pete/pete.sh 15` still works as normal for the root run.

Full tutorial: see **Pete Runs** section in the [main README](https://github.com/petemcpherson/pete-loop#pete-runs).

## Updating Pete Loop

When you update the pete-loop plugin, your project's scripts (`pete.sh`, `pete-once.sh`) are **not** automatically updated — they were copied here at setup time.

To pull the latest scripts into this project after a plugin update, run:

```shell
/pete-loop:update
```

This updates `pete.sh`, `pete-once.sh`, and this `README.md`. It will ask before touching `PROMPT.md`, and never overwrites your `spec.md`, `plan.md`, `progress.txt`, or `human-todo.md`.

## Tuning tips
- Tasks too big? Split anything with more than 2 acceptance criteria.
- Codex working on multiple tasks? Verify the ⛔ STOP gate in PROMPT.md is intact.
- Loop getting stuck? Check `pete/human-todo.md` for blocked items.
- `progress.txt` too long? Trim old entries after a phase completes — git log is the real history.
