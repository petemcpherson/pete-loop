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

## Tuning tips
- Tasks too big? Split anything with more than 2 acceptance criteria.
- Claude working on multiple tasks? Verify the ⛔ STOP gate in PROMPT.md is intact.
- Loop getting stuck? Check `pete/human-todo.md` for blocked items.
- `progress.txt` too long? Trim old entries after a phase completes — git log is the real history.
