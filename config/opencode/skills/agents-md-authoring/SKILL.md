---
name: agents-md-authoring
description: Explores codebase architecture and synchronizes AGENTS.md / .agentdocs. TRIGGER THIS SKILL AUTOMATICALLY when the user asks to "refactor AGENTS.md", "create AGENTS.md", "initialize agents", or when setting up/onboarding to a project.
allowed-tools: Glob, Grep, Read, Write, Bash(ln *), Bash(mkdir *)
---

# Role: Software Architect & Technical Writer

Your goal is to map the codebase, understand the project's mental model, and ensure the agent documentation (`AGENTS.md` and `.agentdocs/`) is perfectly in sync with the current state of the repository.

Target scope to explore: $ARGUMENTS

## Phase 1: Landscape Survey
1. **Architecture Discovery**: Scan the target directory and key subdirectories to identify the project structure (e.g., Clean Architecture, Monolith, Microservices).
2. **Tech Stack Audit**: Identify languages, frameworks, and critical libraries by inspecting configuration files (e.g., `package.json`, `pyproject.toml`, `Cargo.toml`).
3. **Entry Points**: Identify the main entry points for the application, API, and background workers.

## Phase 2: AGENTS.md & Symlink Health Check
Check for the existence and accuracy of `AGENTS.md` and its ecosystem:
- **Symlink Enforcement**: Verify that both `AGENTS.md` and `CLAUDE.md` exist in the root directory. `CLAUDE.md` MUST be a direct symlink to `AGENTS.md`. If the symlink is missing, use Bash to create it (`ln -s AGENTS.md CLAUDE.md`).
- **Progressive Disclosure**: `AGENTS.md` MUST NOT be a massive, monolithic file. It must act as a high-level index and root instruction file. Detailed rules and guidelines must be abstracted away into specific, topical files.
- **Core Content**: `AGENTS.md` must contain:
  - High-level project purpose and instructions.
  - An index/table of contents linking to detailed `.agentdocs/*.md` files (e.g., `.agentdocs/build.md`, `.agentdocs/architecture.md`).

**If `AGENTS.md` or `.agentdocs/` is missing, outdated, or incomplete:**
- Use Bash to create the `.agentdocs/` directory if it doesn't exist (`mkdir -p .agentdocs`).
- Extract bloated instructions from the root file into topical `.agentdocs/*.md` files.
- Update `AGENTS.md` so it reflects the actual state of the code and properly utilizes progressive disclosure.

## Phase 3: Progressive Documentation Alignment
Check if the `README.md`, `AGENTS.md`, and the specific `.agentdocs/*.md` files accurately reflect the current file structure and logic. 
- Ensure Build/Lint/Test Commands are documented in `.agentdocs/commands.md`.
- Ensure Project Patterns are documented in `.agentdocs/patterns.md`.

## Phase 4: Summarization
Provide a concise overview of:
1. **The "Big Picture"**: What does this project do and how is it organized?
2. **Key Dependencies**: What are the "load-bearing" libraries?
3. **Documentation Status**: Are `AGENTS.md`, the `CLAUDE.md` symlink, and the `.agentdocs/` folder set up correctly? Detail any corrections you made.

## Documentation Policy (Mandatory)
Enforce this rule: **"Any change to code logic, API signatures, or project structure must be accompanied by an update to the corresponding documentation (`AGENTS.md`, the appropriate `.agentdocs/*.md` file, `README.md`, or inline comments)."**

**Initial Action**: Start by listing the high-level directory structure and identifying the primary tech stack. Then, check the root for the `AGENTS.md`/`CLAUDE.md` symlink and the `.agentdocs/` structure, and immediately make or propose the necessary updates to achieve 100% accuracy.