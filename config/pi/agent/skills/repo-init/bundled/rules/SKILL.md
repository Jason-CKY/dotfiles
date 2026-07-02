---
name: rules
description: >
  Manage the rule lifecycle with automatic conflict detection. Use this skill whenever:
  - User says "remember this" or "the rule is"
  - User describes a pattern with "always" or "never"
  - User corrects the agent in a way that establishes a new rule
  - User describes a pattern that might contradict existing rules
  - The agent wants to propose promoting a learning to a rule
  Triggers on: "remember", "the rule is", "always", "never", "you must", "never do X", "always do Y", "contradicts", "instead you should"
---

# Rules Skill

## Purpose

Manage the rule lifecycle with automatic conflict detection. Rules are the established patterns and conventions that should be followed consistently.

## When to Activate

Activate this skill when:
1. **User Rule Expression**: User says "remember", "the rule is", "always", "never"
2. **User Correction**: User corrects agent in a rule-establishing way
3. **Contradiction Detection**: User describes a pattern that might contradict existing rules
4. **Learning Promotion**: Agent wants to propose a learning becoming a rule
5. **Conflict Check**: Before adding any new rule, check for contradictions

## Conflict Detection (Critical)

**Before adding any new rule, ALWAYS check for contradictions:**

### Step 1: Search Existing Rules and Learnings

```bash
# Search for related topics in rules
grep -i "constructor\|struct.*init\|New" AGENTS.md .agentdocs/rules/*.md

# Search for related topics in learnings
grep -i "constructor\|struct.*init" .agentdocs/learnings/*.md

# List all current rules
cat AGENTS.md
```

### Step 2: Analyze for Contradictions

Look for:
- Opposite statements ("do X" vs "don't do X")
- Different recommendations for the same scenario
- Exceptions that might conflict with new rules

### Step 3: If Contradiction Found

Present to user:

```
⚠️ Potential Conflict Detected

The rule you're suggesting might contradict an existing rule/learning:

**Existing**: [quote or summary of existing rule]
**New**: [summary of proposed rule]

Options:
1. **Override**: Replace the old rule with the new one
2. **Clarify**: Keep both with context explaining when each applies
3. **Archive**: Mark old rule as deprecated, add new rule

What would you like to do?
```

### Step 4: User Decision

Wait for user confirmation before proceeding.

## Rule Lifecycle

```
┌─────────────┐
│  Triggered  │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Conflict   │
│  Detection  │◄──── Check existing rules/learnings
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  User       │
│  Confirm    │◄──── Present proposed rule + conflicts
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Create     │
│  Rule       │
└─────────────┘
```

## Creating a New Rule

### Step 1: Create Rule File

Create `.agentdocs/rules/<rule-name>.md`:

```markdown
# Rule: [Short Title]

## Statement
[One sentence rule]

## Why This Rule Exists
[Explain the purpose and benefits]

## Correct Example
\`\`\`go
// CORRECT
// Explanation
\`\`\`

## Incorrect Example
\`\`\`go
// WRONG
// Explanation
\`\`\`

## When This Applies
[Scope and boundaries of the rule]

## Exceptions (if any)
[Any valid exceptions to the rule]

## Related Rules
- [.agentdocs/rules/...md](...md)
- [.agentdocs/learnings/...md](../learnings/...md)
```

### Step 2: Add to AGENTS.md

Add one-liner to the appropriate table in `AGENTS.md`:

```markdown
| [Rule Name](.agentdocs/rules/<rule-name>.md) | One-liner description |
```

For example, if it's a CLI convention, add it to the CLI Conventions table. If it's a Go best practice, add it to the Go Best Practices table.

### Step 3: Consider AGENTS.md Update

For critical rules, add inline to `AGENTS.md`:
```markdown
## Core Rules
1. **Constructors Only** - [Summary with link](.agentdocs/rules/constructors.md)
```

## Rule Update Process

### Step 1: Detect Update Need

Rules should be updated when:
- A learning reveals a better approach
- User provides clarification
- Technology changes

### Step 2: Conflict Check

Before updating, check if the change contradicts other rules.

### Step 3: Propose Update

Present to user:
```
I propose updating rule X:

**Current**: [current statement]
**Proposed**: [new statement]

Should I proceed?
```

### Step 4: Execute Update

After confirmation:
1. Update the rule file
2. Update rules.md one-liner if needed
3. Update AGENTS.md if needed

## Rule Archival

Sometimes rules become obsolete. To archive:
1. Move file to `.agentdocs/rules/archive/`
2. Add "DEPRECATED" header to file
3. Note why and when deprecated
4. Update rules.md with strikethrough or note

## Examples

### Example 1: User Says "Remember"

**User**: "Remember, always use constructors for structs"

**Action**:
1. Check for existing constructor rules
2. If conflict, present options
3. Create `.agentdocs/rules/constructors.md`
4. Update `AGENTS.md` with the new rule entry

### Example 2: Learning Promotion

**Agent**: "I found a pattern that keeps causing bugs..."

**Action**:
1. Check existing rules for conflict
2. Propose to user: "Should this become a rule?"
3. If yes, follow rule creation process

### Example 3: Contradiction Detected

**User**: "Always use direct struct init in tests"

**Action**:
1. Search existing rules
2. Find "constructors.md" rule
3. Present conflict to user
4. Wait for decision (override, clarify, or archive)

## Best Practices

1. **Verify Before Adding**: Always check for existing rules
2. **Explain Conflicts**: When conflicts exist, present clearly
3. **Get Confirmation**: Never add/update rules without user approval
4. **Link Related**: Connect rules to related rules and learnings
5. **One Rule Per File**: Don't combine multiple rules
6. **Keep Rules Current**: Update when better approaches emerge

## File Naming

Use lowercase, hyphenated names:
- `constructors.md`
- `testing-standards.md`
- `route-registration.md`
