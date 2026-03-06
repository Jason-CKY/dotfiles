# Dotfiles & Development Environment Setup

This repository contains scripts to automatically set up a complete development environment on Ubuntu systems. The provisioning is designed to be idempotent, meaning it can be run multiple times without causing issues or duplicating configurations.

## What This Repo Does

The scripts in this repository will:

1. Install essential system packages (nano, git, curl, wget, etc.)
2. Set up Node.js environment with:
   - nvm (Node.js version manager)
   - Bun JavaScript runtime
3. Install and configure UV (Python environment manager)
4. Install and configure Go language
5. Install OpenCode CLI and LiteLLM plugin
6. Link dotfiles and custom configurations:
   - .npmrc
   - .gitconfig
   - Custom bashrc and profile configurations
7. Synchronize utility scripts to ~/.dotfiles for easy access

## How to Use

To set up your development environment, simply run the main installation script:

```bash
./install.sh
```

This script will:
1. Wait for any existing package manager locks to be released
2. Execute all setup scripts in the correct order
3. Link dotfiles and custom configurations

For OpenCode-only setup:
```bash
./setup-opencode.sh
```

## Script Breakdown

### Main Orchestrator
- `install.sh`: Main orchestrator script that runs all other scripts in order

### Setup Scripts in `scripts/` directory:
- `install-packages.sh`: Installs system packages
- `setup-dotfiles.sh`: Links dotfiles and custom configurations
- `setup-node.sh`: Sets up Node.js environment (nvm)
- `setup-uv.sh`: Installs UV for Python environment management
- `setup-go.sh`: Installs and configures Go
- `sync-folders.sh`: Synchronizes utility scripts to ~/.dotfiles
- `install-opencode.sh`: Installs OpenCode CLI
- `setup-bun.sh`: Standalone Bun setup (not called by install.sh)

### Utility Scripts in `bin/` directory:
- `jwt-decode`: Utility script for decoding JWT tokens
- `jwt-encode`: Utility script for encoding JWT tokens

## Idempotency

All scripts are designed to be idempotent. This means you can run them multiple times safely. They will check if software is already installed or configured before making changes, preventing duplication or conflicts.

## Directory Structure

```
├── bin/                      # Utility scripts synchronized to ~/.dotfiles/bin
│   ├── jwt-decode            # JWT decoding utility
│   └── jwt-encode            # JWT encoding utility
├── scripts/                  # All setup and installation scripts
│   ├── lib/                  # Shared utility library
│   │   └── common.sh         # Common functions (pkg_installed, cmd_available, etc.)
│   ├── install-packages.sh   # System packages
│   ├── install-opencode.sh  # OpenCode CLI
│   ├── setup-dotfiles.sh    # Dotfiles linking
│   ├── setup-go.sh          # Go installation
│   ├── setup-node.sh        # Node.js (nvm)
│   ├── setup-uv.sh          # UV Python manager
│   ├── setup-bun.sh         # Bun runtime (standalone)
│   └── sync-folders.sh      # Sync bins to ~/.dotfiles
├── config/                   # Configuration files
│   ├── git/                 # Git configuration
│   ├── opencode/            # OpenCode configuration
│   │   ├── opencode.json    # OpenCode plugins config
│   │   └── litellm.json     # LiteLLM auth template
│   └── shell/               # Shell configs
├── shell/                    # Shell source files
│   ├── .aliases             # Custom shell aliases
│   └── .exports             # Environment variables and PATH
├── .bashrc                  # Bash configuration
├── .gitconfig               # Git configuration
├── .npmrc                   # npm configuration
├── .profile                 # Profile configuration
└── install.sh              # Main installation script
```

## Key Configurations

### Git
- User: jason.cheng.ky
- Email: jason.cheng.ky@default.org

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

## OpenCode Integration

- OpenCode CLI is installed via `install-opencode.sh` (requires Bun)
- LiteLLM plugin provides authentication to self-hosted LiteLLM instances
- Configuration: Edit `~/.config/opencode/litellm.json` with your LiteLLM credentials

## Custom Configurations

- `shell/.aliases`: Contains custom shell aliases
- `shell/.exports`: Contains environment variables and PATH configurations
- All custom configurations are automatically sourced during shell initialization

After running the setup, restart your terminal or run `source ~/.profile` to load all configurations.

## Development

- **Pre-commit hook**: Runs `shellcheck` on all shell scripts. Install with `sudo apt-get install shellcheck`
- **Syntax check**: Run `bash -n script.sh` to verify script syntax
- **Idempotency**: All scripts should be safe to run multiple times without side effects
