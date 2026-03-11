# Clarifying questions that an AI chatbot can ask to the user about their initial app/build idea.

The user create a very simple spec.md file with just a few thoughts on what is being built. The AI can ask some or all of the following (a few at a time is good).

## Tech Stack

Do you have an existing codebase, or is this greenfield?
Any strong preferences or dealbreakers on language/framework? (Or should I recommend based on your goals?)
Where do you want to host this — do you care, or do you have an account somewhere already?
Do you need a database? If so, do you prefer SQL or NoSQL?
Will users need to log in? Any auth preferences (email/password, Google, magic link)?

## Features & Scope

What does "done" look like for v1? What would you cut if you had to ship in half the time?
Is there anything that looks like a feature but is actually out of scope?
Are there any features that depend on each other — like, X can't work until Y is built?
Will this have an admin panel, dashboard, or anything beyond the core user-facing app?

## Users & Data

Who's using this — just you, a small team, or the public?
What's the most important thing a user does in this app? Walk me through it step by step.
What data needs to persist — and is any of it sensitive?

## Integrations & External Services

Does this connect to anything external — payment processors, email, APIs, file storage?
Does it send emails or notifications?

## Design & Feel

Any apps you'd consider reference points for the vibe or UX?
Mobile-first, desktop-first, or both?
Do you have a brand already (colors, fonts, logo) or starting from scratch?

## Constraints

Any hard deadlines or milestones?
Budget constraints that affect third-party service choices?
Anything you've already tried that didn't work?