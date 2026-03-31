---
name: spec
description: Guided spec-building session for Pete Loop. Asks clarifying questions about your project, then generates a complete pete/spec.md. Run this after /pete-loop:setup and before /pete-loop:plan.
disable-model-invocation: true
---

# Pete Loop — Build spec.md

## Step 0: Determine target folder

Before anything else, ask the user:

> "Is this spec for your main `pete/` folder (first-time setup), or for a **Pete Run** subfolder (new feature, v2, etc.)? If a Pete Run, what's the subfolder name (e.g. `v2`, `user-auth`)?"

Use their answer to set the target path for this session:
- Root: `pete/spec.md`
- Pete Run: `pete/<RUN_NAME>/spec.md`

Refer to this as `<SPEC_PATH>` for the rest of this skill.

---

Help the user build a complete spec at `<SPEC_PATH>`.

## Your approach

1. **Ask first, write second.** Do not write anything until you have asked all your questions and the user has answered them.

2. **Ask clarifying questions** covering:
   - What does the app do, and who is it for? (1–2 sentences)
   - Tech stack choices and any hard constraints (existing codebase, team familiarity, hosting requirements)
   - Core features for MVP vs. nice-to-haves for later
   - Key user flows (the 2–3 most important journeys through the app)
   - Data models and any third-party integrations or APIs
   - Design notes: colors, fonts, vibe, any UI references or inspirations
   - Constraints and non-goals: what this app explicitly will NOT do

3. **Ask all questions in one message** — don't ask one at a time.

4. **After the user answers**, generate a complete `pete/spec.md` using this template:

```markdown
<!-- spec.md -->
# [Project Name] — Specification

## Overview

[1-2 sentence description of what this app does and who it's for]

---

## Tech Stack

| Layer | Technology | Notes |
|-------|-----------|-------|
| Frontend | | |
| Styling | | |
| Backend / DB | | |
| Auth | | |
| Hosting | | |
| Other | | |

---

## Features

### Core Features (MVP)
- [ ] Feature 1

### Nice-to-Have (Post-MVP)
- [ ] Feature A

---

## User Flows

[Key user journeys step by step]

---

## Data Models

[Main data structures / DB schema]

---

## API / Integrations

[Third-party APIs, webhooks, or services]

---

## Design Notes

[Colors, fonts, vibe, UI references]

---

## Constraints & Non-Goals

[What this app explicitly does NOT do]
```

5. **Write the completed spec** to `<SPEC_PATH>`. If the file doesn't exist yet, create it. If it already exists, ask the user before overwriting.

6. **After writing**, tell the user:
   - spec.md is ready at `<SPEC_PATH>`
   - Next step: run `/pete-loop:plan` — it will ask which folder to use (give it the same answer you gave here)
