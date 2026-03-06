# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a dotfiles repository that automates setting up a complete development environment on Ubuntu systems. All scripts are idempotent and can be run multiple times safely.

## Common Commands

**Full environment setup:**
```bash
./install.sh
```

**OpenCode only setup:**
```bash
./setup-opencode.sh
```

**Individual setup scripts:**
```bash
./scripts/setup-dotfiles.sh     # Link dotfiles and configurations
./scripts/sync-folders.sh       # Sync utility scripts to ~/.dotfiles
./scripts/install-packages.sh   # Install system packages
./scripts/setup-node.sh         # Set up Node.js (nvm, npm, bun)
./scripts/setup-uv.sh           # Install UV Python environment manager
./scripts/setup-go.sh           # Install Go
./scripts/setup-kubectl.sh      # Install kubectl
./scripts/install-temporal.sh    # Install Temporal CLI
./scripts/install-claude-code.sh # Install Claude Code CLI and skills
./scripts/install-opencode.sh    # Install OpenCode CLI and plugins
```

**Developer utilities:**
```bash
./scripts/lib/common.sh         # Shared utility functions (source this in scripts)
./DEVELOPER_GUIDE.md            # Guide for adding new setup scripts
```

**JWT utility scripts (in PATH after setup):**
```bash
jwt-decode <token>              # Decode JWT token to JSON
jwt-encode <payload>            # Encode JSON payload to JWT
```

## Architecture

The repository uses a modular script architecture with a main orchestrator (`install.sh`) that runs individual setup scripts in order. The execution flow:

```
install.sh
  ├── setup-dotfiles.sh (copies configs to $HOME)
  ├── sync-folders.sh (syncs bin/ to ~/.dotfiles)
  ├── install-packages.sh (apt packages - uses lib/common.sh)
  ├── setup-node.sh (nvm, npm global packages, bun)
  ├── setup-uv.sh (Python package manager - uses lib/common.sh)
  ├── setup-go.sh (Go runtime - uses lib/common.sh)
  ├── setup-kubectl.sh (Kubernetes CLI)
  ├── install-temporal.sh (Temporal CLI)
  ├── install-claude-code.sh (Claude Code CLI and skills)
  └── install-opencode.sh (OpenCode CLI + LiteLLM plugin)
```

### Library Structure

```
scripts/
  ├── lib/
  │   └── common.sh (shared utility functions)
  │       - pkg_installed()        Check if apt package is installed
  │       - cmd_available()        Check if command is available
  │       - install_if_missing()   Install package if not present
  │       - update_if_needed()     Run apt-get update if needed
  │       - version_matches()      Compare version strings
  │       - install_binary_if_needed()  Install binary if version mismatch
  │       - download_if_needed()   Download with caching
  │       - extract_archive()      Extract tar.gz/zip archives
  └── *.sh (setup scripts)
```

### Directory Structure

- `bin/` - Utility scripts synchronized to `~/.dotfiles/bin`
- `scripts/` - Setup/installation scripts (sourced from `install.sh`)
  - `scripts/lib/` - Shared utility library
- `config/` - Configuration files organized by tool
  - `config/shell/` - Shell configs (`.bashrc`, `.profile`)
  - `config/git/` - Git config (`.gitconfig`)
  - `config/npm/` - npm config (`.npmrc`)
  - `config/bun/` - Bun config (`.bunfig.toml`)
  - `config/uv/` - UV config (`uv.toml`)
  - `config/claude/` - Claude Code settings and skills
    - `settings.json` - Claude Code managed settings
    - `skills/` - Claude Code skills (copied to `~/.claude/skills/`)
    - `commands/` - Slash commands (copied to `~/.claude/commands/`)
      - `/code-review` - Comprehensive code review
      - `/git-commit` - Create git commits
      - `/refactor` - Refactor code
      - `/security-check` - Security vulnerability scan
  - `config/opencode/` - OpenCode configuration
    - `opencode.json` - OpenCode config (plugins)
    - `litellm.json` - LiteLLM auth credentials template
- `shell/` - Shell source files (`.exports`, `.aliases`)
- `packages/` - Plugin packages
  - `opencode-litellm-auth/` - LiteLLM auth plugin for OpenCode

### Configuration Loading

- `~/.profile` sources `~/.bashrc`
- `~/.bashrc` sources `~/.dotfiles/shell/.aliases` and `~/.dotfiles/shell/.exports`

## Key Configurations

### Git
- User: jason.cheng.ky
- Email: jason.cheng.ky@default.org

### npm
- Registry: https://registry.npmjs.org/
- Global prefix: `~/.node_modules`

### Path Configuration
All local bins are consolidated in PATH via `shell/.exports`:
- `~/.local/bin`
- `~/.dotfiles/bin`
- `~/.local/go/bin`, `~/.go/bin`
- `~/.node_modules/bin`, `~/.nvm`, `~/.bun/bin`

### Aliases
- `gst` - `git status`
- `k` - `kubectl`
- `serve` - `uv run -- python -m http.server`

## Downloads

All tools are downloaded from their official sources:
- Python builds via UV from `astral.sh`
- Node.js via nvm from `github.com/nvm-sh`
- Bun from `bun.sh`

## Claude Code

- Claude Code CLI is installed via `install-claude-code.sh` (requires Node.js)
- Binary installed to `~/.local/bin/claude`
- Version is checked against the mirror and updated if needed
- Settings: `config/claude/settings.json` → `~/.claude/settings.json`
- Skills: `config/claude/skills/` → `~/.claude/skills/`
- Slash Commands: `config/claude/commands/` → `~/.claude/commands/`
  - `/code-review` - Review changes for quality, security, performance
  - `/git-commit` - Create conventional git commits
  - `/refactor` - Improve code clarity and maintainability
  - `/security-check` - Scan for security vulnerabilities

### OpenCode Integration

- OpenCode CLI is installed via `install-opencode.sh` (requires Bun)
- Claude Code commands and skills are symlinked to OpenCode config:
  - Commands: `~/.claude/commands/` → `~/.config/opencode/commands/`
  - Skills: `~/.claude/skills/` → `~/.config/opencode/skills/`

#### LiteLLM Plugin

- Plugin: `packages/opencode-litellm-auth/` - TypeScript plugin that provides:
  - Authentication to self-hosted LiteLLM instances
  - Automatic model discovery from `/v1/models` endpoint
  - Tools: `litellm-list-models`, `litellm-refresh-models`
- Configuration: Edit `~/.config/opencode/litellm.json` with:
  ```json
  {
    "url": "https://litellm.yourcompany.com",
    "apiKey": "sk-your-api-key"
  }
  ```
- Plugin is built to `~/.config/opencode/plugins/opencode-litellm-auth/`

## Important Notes

- Scripts wait for apt/dpkg locks before proceeding
- All setup scripts check for existing installations before making changes
- VS Code settings are synced to `~/.local/share/code-server/User/settings.json`
- Secrets like `GITLAB_PERSONAL_ACCESS_TOKEN` are loaded via Coder external-auth integration

## Development

- **Pre-commit hook**: Runs `shellcheck` on all shell scripts. Install with `sudo apt-get install shellcheck`
- **Syntax check**: Run `bash -n script.sh` to verify script syntax
- **Idempotency**: All scripts should be safe to run multiple times without side effects

## Keeping CLAUDE.md Updated

**Always update CLAUDE.md when making changes to this repository.** This file is the single source of truth for anyone (or any AI) working on this project. After any modification to scripts, configurations, or structure:

1. Update the **Common Commands** section if adding/removing scripts
2. Update the **Architecture** flow chart if the execution order changes
3. Update the **Directory Structure** if adding new config folders or files
4. Update the relevant **Key Configurations** sections if settings change
5. Add new sections if introducing new tools or capabilities

Treat CLAUDE.md as documentation that must stay in sync with the codebase - stale documentation is worse than no documentation.
