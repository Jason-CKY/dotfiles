---
name: repo-init
description: >
  Initialize a new repository with standardized agent documentation structure. Use when:
  - User says "init repo", "initialize repo", "setup agent docs", "setup CLAUDE.md"
  - User asks to set up rules, learnings, or skills for a project
  - User invokes this skill directly via "/skill:repo-init" or similar
  - User wants to establish a new project's agent documentation from scratch
  - User wants to convert an existing repo to the standardized structure
  This skill is invoked by direct user request, not automatic triggers.
---

# Repo Init Skill

Initialize a repository with standardized agent documentation structure following the progressive disclosure pattern.

## What This Creates

```
<repo-root>/
├── AGENTS.md                    # Symlink to CLAUDE.md
├── CLAUDE.md                    # Project overview with inline rules + links
├── .agentdocs/
│   ├── README.md               # Index of all agent documentation
│   ├── rules/
│   │   ├── README.md           # Rules index
│   │   └── <rule-name>.md      # Individual rule files
│   └── learnings/
│       ├── README.md           # Learnings index
│       └── <learning-name>.md  # Individual learning files
├── .claude/
│   └── skills/                 # Canonical skills location
│       ├── auto-learn/         # Capture learnings from mistakes
│       └── rules/              # Rule lifecycle management
└── .pi/
    └── skills/                 # Symlink → ../.claude/skills
```

Skills live in `.claude/skills/` as the single source of truth. `.pi/skills`
is a symlink pointing at `.claude/skills`, so Claude and Pi share the same
skills without duplication.

## Step-by-Step Process

### Step 1: Detect Existing Structure

Check what already exists in the repo:

```bash
# Check for existing CLAUDE.md or AGENTS.md
ls -la CLAUDE.md AGENTS.md 2>/dev/null || echo "No existing agent docs"

# Check for existing .agentdocs
ls -la .agentdocs/ 2>/dev/null || echo "No .agentdocs"

# Check for existing skills
ls -la .claude/skills/ .pi/skills/ 2>/dev/null || echo "No existing skills"
```

### Step 2: Detect Existing Agent Docs

If existing files are found:

```
⚠️ Existing Agent Docs Detected

Found: [list of existing files]

Options:
1. **Convert**: Migrate existing CLAUDE.md content to new structure
2. **Merge**: Combine existing content with new structure
3. **Replace**: Overwrite with fresh structure (loses existing content)

Recommendation: Convert - preserves knowledge while adopting new structure
```

**If converting existing CLAUDE.md:**
1. Read the existing file
2. Extract rules and conventions into `.agentdocs/rules/` files
3. Extract learnings into `.agentdocs/learnings/` files
4. Create new AGENTS.md with summary inline, links to detail files

### Step 3: Create Directory Structure

```bash
# Create directories (skills are canonically under .claude/skills)
mkdir -p .agentdocs/rules .agentdocs/learnings .claude/skills/auto-learn .claude/skills/rules
```

### Step 4: Create AGENTS.md Symlink

```bash
# If CLAUDE.md doesn't exist, create it first
touch CLAUDE.md

# Remove old AGENTS.md if exists and create symlink
rm -f AGENTS.md
ln -s CLAUDE.md AGENTS.md
```

### Step 5: Copy Bundled Skills

This skill includes bundled copies of core skills. Copy them into the canonical
`.claude/skills/` location:

```bash
# Copy bundled auto-learn skill
cp -r ~/.pi/agent/skills/repo-init/bundled/auto-learn/. .claude/skills/auto-learn/

# Copy bundled rules skill
cp -r ~/.pi/agent/skills/repo-init/bundled/rules/. .claude/skills/rules/
```

### Step 6: Symlink .pi/skills → .claude/skills

Point Pi at the same skills directory so both agents share one source of truth:

```bash
# Create .pi and symlink its skills directory to .claude/skills
mkdir -p .pi
rm -rf .pi/skills
ln -s ../.claude/skills .pi/skills
```

Verify the link resolves:

```bash
ls -la .pi/skills/
```

### Step 7: Create Starter Files

Create these files with templates (see Templates section below):

1. **CLAUDE.md** - Project overview with inline rules + links to .agentdocs
2. **.agentdocs/README.md** - Index of all agent documentation
3. **.agentdocs/rules/README.md** - Rules index
4. **.agentdocs/learnings/README.md** - Learnings index

### Step 8: Customize AGENTS.md for Project

Replace template placeholders in CLAUDE.md with project-specific information:

- `[PROJECT NAME]` → Actual project name
- `[Brief description]` → What the project does
- `[Tech stack]` → Languages, frameworks, key technologies
- `[Essential commands]` → Build, test, run commands
- `[Key rules]` → Project-specific rules beyond defaults

## Templates

### CLAUDE.md Template

```markdown
# [Project Name]

[Brief description of what this project does and its purpose.]

## Project Structure
- `cmd/` - [Entry points]
- `internal/` - [Application code]
- `build/` - [Compiled output]
- `.agentdocs/` - [Detailed documentation, rules, and learnings]
- `.claude/skills/` - [Agent skills for specialized tasks (.pi/skills symlinks here)]

## Tech Stack
- **Language**: [e.g., Go, TypeScript, Python]
- **Framework**: [e.g., Echo, React, FastAPI]
- **Build**: [e.g., Make, npm, Cargo]

## Essential Commands
\`\`\`bash
[Build command]
[Test command]
[Run command]
\`\`\`

## Core Rules

These are the fundamental rules for working in this codebase:

1. **[Rule 1 Name](.agentdocs/rules/<rule-1>.md)** - [One-liner summary]
2. **[Rule 2 Name](.agentdocs/rules/<rule-2>.md)** - [One-liner summary]

## Conventions

| Category | Rule | One-Liner | Details |
|----------|------|-----------|---------|
| [Category] | [Rule Name](.agentdocs/rules/<rule>.md) | [Summary] | |
| [Category] | [Learning Name](.agentdocs/learnings/<learning>.md) | [Summary] | |

## Learnings

Agent discoveries from past mistakes are documented in [.agentdocs/learnings/](.agentdocs/learnings/).

## Configuration
- **Path**: [Config file location]
- **Env Prefix**: [Environment variable prefix]

---

# .agentdocs - Agent Documentation Index

This directory contains all agent documentation for this project.

## Quick Navigation

| Section | Purpose |
|---------|---------|
| [rules.md](rules.md) | List of all rules with one-liners |
| [rules/](rules/) | Detailed rule explanations |
| [learnings/](learnings/) | Discoveries from mistakes and corrections |

## How Documentation Works

1. **CLAUDE.md** (root) - Project overview, tech stack, inline rules, links to this directory
2. **[rules/](rules/)** - One-liner rules + detailed explanations
3. **[learnings/](learnings/)** - Discoveries from mistakes and corrections

## Adding New Rules

When a new rule is established:
1. Create `[rules/<rule-name>.md](rules/)` with full explanation
2. Add one-liner to this index
3. Skills will automatically detect and manage rule lifecycle

## Adding Learnings

When a learning is discovered, use the auto-learn skill to capture it.

## Rule Format

Each rule file should contain:
- Clear rule statement
- Why this rule exists
- Correct and incorrect examples
- Related rules and learnings
```

### .agentdocs/README.md Template

```markdown
# Agent Documentation Index

All agent documentation for this project is organized here.

## Structure

\`\`\`
.agentdocs/
├── README.md       # This file
├── rules/          # Rule files (see rules/README.md)
└── learnings/      # Learning files (see learnings/README.md)
\`\`\`

## How It Works

1. **CLAUDE.md** at repo root contains project overview and inline rules
2. **rules/** contains detailed rule explanations
3. **learnings/** contains discoveries from mistakes

## Contributing

When establishing a new rule:
1. Create \`rules/<rule-name>.md\` with full explanation
2. Add one-liner to rules/README.md
3. Update CLAUDE.md with inline summary + link

When capturing a learning:
1. Use the auto-learn skill
2. Create \`learnings/<learning-name>.md\`
3. Update learnings/README.md with the new entry
```

### .agentdocs/rules/README.md Template

```markdown
# Rules Index

## Rule List

| Rule | Summary |
|------|---------|
| [rule-name.md](rule-name.md) | One-liner description |

## Adding a New Rule

\`\`\`markdown
# Rule: [Short Title]

## Statement
[One sentence rule]

## Why This Rule Exists
[Explain the purpose]

## Correct Example
\`\`\`[language]
// CORRECT
\`\`\`

## Incorrect Example
\`\`\`[language]
// WRONG
\`\`\`

## Related
- [Other rules](.)
- [Related learnings](../learnings/)
\`\`\`
```

### .agentdocs/learnings/README.md Template

```markdown
# Learnings Index

## Categories

### [Category Name]
| Learning | Summary |
|----------|---------|
| [learning-name.md](learning-name.md) | One-liner description |

## How Learnings Are Created

Learnings are created by the \`auto-learn\` skill when:
- Agent makes the same mistake twice
- User corrects the agent
- Agent discovers a better approach
- Test reveals a bug

## Learning Entry Format

\`\`\`markdown
# Learning: [Short Title]

## Context
What was the situation?

## Mistake/Discovery
What went wrong OR what was discovered?

## Corrected Approach
How should it be done?

## Triggered By
- [ ] User correction
- [ ] Bug found in test
- [ ] Agent self-discovery

## Related
- [Link to related rules](../rules/)
- [Link to related learnings]

## Date
YYYY-MM-DD
\`\`\`
```

## Bundled Skills

This skill includes the following bundled skills that will be copied to target repos:

### auto-learn
Captures learnings immediately when discovered during development. Bundled at:
`~/.pi/agent/skills/repo-init/bundled/auto-learn/SKILL.md`

### rules
Manages the rule lifecycle with automatic conflict detection. Bundled at:
`~/.pi/agent/skills/repo-init/bundled/rules/SKILL.md`

## Customization Checklist

After running this skill, customize:

- [ ] Project name in CLAUDE.md header
- [ ] Project description
- [ ] Directory structure (cmd, internal, etc.)
- [ ] Tech stack (language, framework, build tools)
- [ ] Essential commands (build, test, run)
- [ ] Core rules specific to this project
- [ ] Conventions tables for project-specific patterns
- [ ] Configuration paths and env prefixes

## Example: Go Project

For a Go project, you might add:

**Core Rules:**
1. **Constructors Only** - Never use direct struct initialization, always use constructors
2. **Tests Required** - Any feature must include tests

**Go Conventions:**
- Pointer receiver methods on maps require reassignment
- Always grep struct definitions before writing tests
- Interface methods must update mocks in same commit

## Example: TypeScript/Node Project

For a TypeScript project, you might add:

**Core Rules:**
1. **Explicit Types** - No \`any\`, always declare types
2. **Tests Required** - Any feature must include tests

**TS Conventions:**
- Use \`interface\` for object shapes, \`type\` for unions
- Default exports are banned, use named exports
- Error handling with custom error classes

## Best Practices

1. **Be Project-Specific** - Customize templates with actual project details
2. **Link Everything** - Every inline rule should link to detail file
3. **One Rule Per File** - Don't combine multiple rules
4. **Capture Learnings** - Use auto-learn skill to document mistakes
5. **Keep AGENTS.md Lean** - Inline only the most critical rules

## Skill Files

```
~/.pi/agent/skills/repo-init/
├── SKILL.md                    # This file
└── bundled/
    ├── auto-learn/
    │   └── SKILL.md           # Bundled auto-learn skill
    └── rules/
        └── SKILL.md           # Bundled rules skill
```
