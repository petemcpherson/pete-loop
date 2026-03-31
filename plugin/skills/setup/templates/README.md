# Pete Loop — Quick Start

> ⚠️ **Sandbox + permission policy is required** via `.claude/settings.json` for safe AFK execution.
>
> If `.claude/settings.json` already exists, **do not replace the entire file**. Merge in the `permissions` and `sandbox` sections below, and preserve any existing settings.
>
> Note: `pete-loop@petemcpherson-claude-plugins` is usually already present in `enabledPlugins` because the plugin is installed before this setup runs. Keep that entry and preserve any other plugin settings you already have.

## Required `.claude/settings.json` policy

Use this as the recommended shape:

```json
{
  "enabledPlugins": {
    "pete-loop@petemcpherson-claude-plugins": true
  },
  "permissions": {
    "allow": [
      "WebFetch(domain:registry.npmjs.org)",
      "WebFetch(domain:github.com)",
      "WebFetch(domain:cdn.jsdelivr.net)"
    ],
    "deny": [
      "Bash(sudo *)",
      "Bash(docker *)",
      "Read(./.env)",
      "Read(~/.ssh/**)",
      "Read(~/.aws/**)"
    ],
    "ask": [
      "Bash(git push:*)"
    ],
    "defaultMode": "acceptEdits"
  },
  "sandbox": {
    "enabled": true,
    "autoAllowBashIfSandboxed": true,
    "allowUnsandboxedCommands": false,
    "network": {
      "allowLocalBinding": true
    }
  }
}
```

## Customizing PROMPT.md for your setup

`PROMPT.md` is the instruction set Claude reads on every loop iteration — it's worth tailoring it to your workflow. Common additions:

- **Skills & subagents** — tell Claude when to invoke specific skills (e.g. *"If working on UI, load the frontend-design skill before writing any code"*)
- **MCP servers** — reference tools you have installed (e.g. *"Use Context7 for documentation research"*)
- **Commit style** — add a line like *"Do NOT add a Co-Authored-By attribution"* if you don't want that in your git history

See [`Resources/prompt-improvements.md`](https://github.com/petemcpherson/pete-loop/blob/main/Resources/prompt-improvements.md) for concrete examples and copy-paste snippets.

## First time setup
1. Fill in `pete/spec.md` — run `/pete-loop:spec` for AI-guided help
2. Generate `pete/plan.md` — run `/pete-loop:plan` after spec is done
3. Run `./pete/pete.sh 5` to start the loop (low iteration count is a good first run) 🌿

## Files
- `spec.md` — What you're building (fill this in first)
- `plan.md` — Phased task list (one task per loop iteration)
- `PROMPT.md` — The prompt fed to Claude each iteration (don't edit unless tuning)
- `progress.txt` — Rolling log appended by Claude each iteration
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

## Tuning tips
- Tasks too big? Split anything with more than 2 acceptance criteria.
- Claude working on multiple tasks? Verify the ⛔ STOP gate in PROMPT.md is intact.
- Loop getting stuck? Check `pete/human-todo.md` for blocked items.
- `progress.txt` too long? Trim old entries after a phase completes — git log is the real history.
