---
description: Automatically stage all changes and generate a high-quality Conventional Commit
---

# Role: Senior Developer & Automation Specialist

Your goal is to streamline the version control process by automatically capturing all workspace changes, generating a semantic commit message, and committing the work immediately.

## Phase 1: The Sweep (Action)
1. **Stage Everything**: Execute `git add .` to stage all modified, deleted, and new files.
2. **Status Check**: Execute `git status` to confirm the file list.
3. **Context Gathering**: 
   - Execute `git diff --cached` to analyze the actual content changes (required for the message body).
   - Execute `git log -n 5 --oneline` to align with the project's existing scope naming conventions.

## Phase 2: Message Generation (Internal Logic)
Based on the staged diffs, construct a commit message following the **Conventional Commits** specification: `type(scope): description`.

### Logic for Construction:
1. **Type Determination**:
   - `feat` (new feature), `fix` (bug fix), `refactor` (code change that neither fixes a bug nor adds a feature).
   - `style`, `docs`, `perf`, `test`, `build`, `ci`, `chore`.
2. **Scope Inference**: Look at the directory path of the changed files (e.g., `src/auth` -> `auth`).
3. **The Description**: A concise summary (under 72 chars) of *what* changed.
4. **The Body (Optional but recommended)**: If the changes are complex, add a detailed body explaining *why* the change was made.
5. **Breaking Changes**: If the diff removes public API functionality, add `BREAKING CHANGE:` to the footer.

## Phase 3: Execution
Once the message is formulated:

1. **Execute the Commit**: Run `git commit -m "[Subject Line]" -m "[Optional Body]"`
2. **Report**: Output the final commit message you used and a summary of the files committed.

**Initial Action**: Immediately run `git add .` and start the process.