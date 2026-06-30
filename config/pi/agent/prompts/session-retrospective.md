---
description: Analyze the previous session for inefficiencies and suggest repo improvements
argument-hint: "[goal]"
---
Analyze this conversation as a retrospective. Your job is to help me (the human) improve my Claude Code / Pi setup so future sessions are more effective.

## What to look for

### Wrong directions (the main focus)
- Places where I (the human) had to redirect you back on track
- Attempts that failed, required backtracking, or were dead ends
- Steps that seemed necessary but turned out to be unnecessary
- Misunderstandings about the codebase, tools, or domain
- Assumptions that proved wrong
- Commands or approaches that didn't work on first try

### What made you effective
- Key insights, docs, or context that helped you succeed
- Patterns you recognized quickly

## Output format

### 1. Wrong Turns (list each with)
- **What happened:** Brief description of the wrong direction
- **What I said:** The human's clarifying message or correction
- **Why it happened:** Root cause (missing context, ambiguous instruction, incorrect assumption)
- **Repositioning:** How we got back on track

### 2. Repo Improvements (concrete, actionable)

For each issue, suggest ONE of:
- **CLAUDE.md entry** — Add to `.md` with key files, patterns, gotchas
- **New skill** — Brief workflow in `~/.claude/skills/` or `.pi/agent/skills/`
- **Prompt template** — New template in `prompts/` for a common task
- **Script** — Add utility to `bin/` or `scripts/`
- **Documentation** — Create a `docs/*.md` for a pattern
- **Config** — Change settings in `.claude/settings.json`

### 3. One-Line Summary

End with: "Next time I need to [do this], I should add [X] to the repo."

Keep it concise. This is a session retrospective, not a full postmortem.
