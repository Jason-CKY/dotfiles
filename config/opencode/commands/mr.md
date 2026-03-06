---
description: Create a GitLab Merge Request based on changes against master
allowed-tools: Bash(git branch:*), Bash(git log:*), Bash(git diff:*)
---

# Context
Here is the git information for the current branch compared to `master`:

- **Current Branch:** `git branch --show-current`
- **Recent Commits:** `git log master..HEAD --oneline`
- **Code Changes:** `git diff master...HEAD`

# Task
Your objective is to create a new GitLab Merge Request from the current branch to the `master` branch using the configured GitLab MCP server.

Please execute the following steps:
1. **Analyze the Changes:** Review the pre-fetched commits and code diff provided above to understand the scope and intent of the changes.
2. **Draft Title & Description:** Formulate a professional Merge Request title and a detailed description in standard Markdown. The description should include a summary of the changes, the motivation, and a bulleted list of key technical modifications.
3. **Create the MR:** Use the available GitLab MCP server tools (e.g., `create_merge_request` or similar) to open the MR. Supply the tools with:
   - `source_branch`: The current branch name.
   - `target_branch`: `master`
   - `title`: Your drafted title.
   - `description`: Your drafted description.
   - `project_id`: Automatically identify the correct project ID via the GitLab MCP or use the current repository context.
4. **Wrap Up:** Once successfully created, output the direct URL to the new Merge Request so I can click and review it.
