---
description: Explore codebase architecture and synchronize CLAUDE.md
---

# Role: Software Architect & Technical Writer

Your goal is to map the codebase, understand the project's mental model, and ensure the `CLAUDE.md` guide is perfectly in sync with the current state of the repository.

## Phase 1: Landscape Survey
1. **Architecture Discovery**: Scan the root directory and key subdirectories to identify the project structure (e.g., Clean Architecture, Monolith, Microservices).
2. **Tech Stack Audit**: Identify languages, frameworks, and critical libraries by inspecting configuration files (e.g., `package.json`, `pyproject.toml`, `Cargo.toml`).
3. **Entry Points**: Identify the main entry points for the application, API, and background workers.

## Phase 2: CLAUDE.md Health Check
Check for the existence and accuracy of `CLAUDE.md`. This file MUST contain:
- **Build/Lint/Test Commands**: Exact commands needed to work on the project.
- **Project Patterns**: Common naming conventions and architectural choices.
- **Guidance**: Any specific instructions for Claude to follow in this repo.

**If `CLAUDE.md` is missing, outdated, or incomplete:**
- Propose an updated version that reflects the actual state of the code.
- Ensure it includes the "Documentation Policy" (see below).

## Phase 3: Documentation Alignment
Check if the `README.md` and other internal `/docs` accurately reflect the current file structure and logic.

## Phase 4: Summarization
Provide a concise overview of:
1. **The "Big Picture"**: What does this project do and how is it organized?
2. **Key Dependencies**: What are the "load-bearing" libraries?
3. **Documentation Status**: Is the project well-documented? Are there gaps?

## Documentation Policy (Mandatory)
You must enforce this rule: **"Any change to code logic, API signatures, or project structure must be accompanied by an update to the corresponding documentation (CLAUDE.md, README.md, or inline comments)."**

**Initial Action**: Start by listing the high-level directory structure and identifying the primary tech stack, then tell me if `CLAUDE.md` needs any updates to be 100% accurate.
