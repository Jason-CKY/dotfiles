# Developer Guide

This document provides guidance for working with the dotfiles repository.

## Table of Contents
- [Architecture Overview](#architecture-overview)
- [Script Reference](#script-reference)
- [Adding a New Setup Script](#adding-a-new-setup-script)
- [Common Functions](#common-functions)
- [Best Practices](#best-practices)

## Architecture Overview

```
install.sh (orchestrator)
  ├── shell/.exports (environment variables)
  ├── scripts/
  │   ├── lib/
  │   │   └── common.sh (shared utility functions)
  │   ├── install-packages.sh
  │   ├── setup-dotfiles.sh
  │   ├── sync-folders.sh
  │   ├── setup-node.sh
  │   ├── install-claude-code.sh
  │   ├── setup-uv.sh
  │   ├── setup-go.sh
  │   ├── setup-kubectl.sh
  │   └── install-temporal.sh
  ├── config/ (configuration files)
  └── bin/ (utility scripts)
```

## Script Reference

### `install.sh`
The main orchestrator script. Runs all setup scripts in dependency order.

**Usage:** `./install.sh`

**Execution Order:**
1. Dotfiles setup (symlinks/configs)
2. Folder sync (`~/.dotfiles`)
3. System packages (apt)
4. Node.js environment
5. Claude Code
6. UV (Python)
7. Go
8. kubectl
9. Temporal CLI

### `scripts/setup-dotfiles.sh`
Copies configuration files to `$HOME`.

### `scripts/sync-folders.sh`
Synchronizes `bin/` and `shell/` directories to `~/.dotfiles/`.

### `scripts/install-packages.sh`
Installs system packages using apt. Uses `lib/common.sh` for package checking.

### `scripts/setup-node.sh`
Sets up Node.js with n, configures global npm directory, and installs global packages.

### `scripts/install-claude-code.sh`
Installs/updates Claude Code CLI and syncs skills/commands.

### `scripts/setup-uv.sh`
Installs UV Python package manager with version checking.

### `scripts/setup-go.sh`
Installs Go with version checking and configures GOPROXY.

### `scripts/setup-kubectl.sh`
Installs kubectl and sets up kubeconfig from GitLab snippet.

### `scripts/install-temporal.sh`
Downloads and installs Temporal CLI.

## Adding a New Setup Script

1. Create a new file in `scripts/`:
```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
source "$SCRIPT_DIR/lib/common.sh"

# Your setup logic here
```

2. Add the script to `install.sh` in the correct dependency order:
```bash
echo "Running new setup script..."
$SCRIPT_DIR/scripts/setup-new-tool.sh
```

3. Test idempotency by running the script multiple times.

## Common Functions

See `scripts/lib/common.sh` for the full list. Key functions:

| Function | Description |
|----------|-------------|
| `pkg_installed <name>` | Check if apt package is installed |
| `cmd_available <name>` | Check if command is in PATH |
| `install_if_missing <name>` | Install package if not present |
| `update_if_needed <pkgs...>` | Run apt-get update if packages missing |
| `version_matches <current> <desired>` | Compare version strings |
| `install_binary_if_needed <name> <url> <version>` | Install binary if version mismatch |

## Best Practices

1. **Always use `set -euo pipefail`** at the top of scripts
2. **Use `$HOME` instead of hardcoded paths** like `/home/user`
3. **Source `lib/common.sh`** for shared functionality
4. **Make scripts idempotent** - safe to run multiple times
5. **Provide clear error messages** with `>&2`
6. **Use exit codes** appropriately (0 for success, non-zero for failure)
7. **Test with `bash -n`** before committing
8. **Update CLAUDE.md** when changing script behavior

## Pre-commit Hook

The repository includes a pre-commit hook that runs `shellcheck` on all shell scripts. To install:

```bash
sudo apt-get install shellcheck
# Hook is already installed at .git/hooks/pre-commit
```

The hook will:
- Skip validation if shellcheck is not installed
- Skip vendor scripts in `config/claude/skills/`
- Fail if any script has shellcheck issues
