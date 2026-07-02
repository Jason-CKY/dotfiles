---
name: auto-learn
description: >
  Capture learnings immediately when discovered during development. Use this skill whenever:
  - The agent makes the same mistake twice
  - The user corrects the agent
  - The agent discovers a better approach to something
  - A test reveals a bug or unexpected behavior
  - A pattern is discovered that should be documented
  Triggers on: "mistake", "wrong", "correct me", "should do X instead", "I learned", "discovered", "found that"
---

# Auto-Learn Skill

## Purpose

Capture learnings immediately when discovered during development. This ensures the agent doesn't repeat the same mistakes and builds up a knowledge base of patterns and corrections.

## When to Activate

Activate this skill when:
1. **User Correction**: User says "wrong", "incorrect", "you should do X instead", "remember this"
2. **Agent Mistake**: Agent realizes a mistake was made (even if self-corrected)
3. **Pattern Discovery**: Agent discovers a better approach or common pitfall
4. **Test Failure**: A test reveals unexpected behavior or a bug
5. **Same Mistake Twice**: Agent notices the same error pattern recurring

## Learning Entry Format

Create a file at `.agentdocs/learnings/<short-title>.md` with this structure:

```markdown
# Learning: [Short Title]

## Context
What was the situation? What were you trying to do?

## Mistake/Discovery
What went wrong OR what was discovered?

## Corrected Approach
How should it be done correctly?

## Triggered By
- [ ] User correction
- [ ] Bug found in test
- [ ] Agent self-discovery
- [ ] Code review

## Related
- [.agentdocs/rules/...md](../rules/...)  # Link to related rules if applicable
- [.agentdocs/learnings/...md](...)       # Link to related learnings if applicable

## Date
YYYY-MM-DD
```

## Step-by-Step Process

### 1. Detect the Learning Trigger

When activated, identify what type of learning this is:
- **Correction**: User pointed out a mistake
- **Self-Discovery**: Agent noticed a problem
- **Pattern**: Discovered a new approach

### 2. Assess If This Is New

Before creating a new learning, check if one already exists:

```bash
# Search for existing learnings on this topic
grep -r "related-keyword" .agentdocs/learnings/
ls .agentdocs/learnings/
```

### 3. Create or Update the Learning

**If new learning:**
```bash
# Generate filename from topic
# e.g., "pointer receiver on maps" → pointer-receiver-maps.md
touch ".agentdocs/learnings/<short-title>.md"
```

**If updating existing learning:**
- Add new context to the existing file
- Update the "Triggered By" section
- Keep the original date, but note the update

### 4. Fill in the Template

Write the learning following the format above. Be specific:
- Include file paths and line numbers when relevant
- Show before/after code examples
- Explain WHY this matters

### 5. Propose Rule Promotion (Optional)

If this learning seems like it should become a general rule:

```
This learning seems like a good candidate for a rule. Should I:
1. Create a rule in .agentdocs/rules/...
2. Add to AGENTS.md
3. Keep as learning only

Recommendation: [Your recommendation]
```

Wait for user confirmation before promoting to rule.

## Examples

### Example 1: User Correction

**Trigger**: User says "wrong, you should always use constructors"

**Action**: Create learning file:

```markdown
# Learning: Constructor Usage Required

## Context
Implementing a new feature that required creating an App struct.

## Mistake
Used direct struct initialization: `App{Name: "test"}`

## Corrected Approach
Always use constructor: `NewApp(cfg)`

## Triggered By
- [x] User correction

## Related
- [.agentdocs/rules/constructors.md](../rules/constructors.md)

## Date
2025-05-06
```

### Example 2: Agent Self-Discovery

**Trigger**: Agent realizes map access returns a copy

**Action**: Create learning file documenting the pattern.

## Best Practices

1. **Immediate Capture**: Write the learning right away, don't wait
2. **Be Specific**: Include exact code, files, and context
3. **Explain Why**: The "why" helps future decisions
4. **Link Related**: Connect to existing rules/learnings
5. **One Topic Per File**: Don't mix multiple learnings

## File Naming

Use lowercase, hyphenated names:
- `pointer-receiver-maps.md`
- `ternary-operator-go.md`
- `route-registration-both-steps.md`

## Integration with Rules Skill

After capturing a learning, consider if the rules skill should also be invoked to:
1. Check for contradictions with existing rules
2. Propose a new rule if appropriate
