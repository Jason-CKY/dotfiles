# Dotfiles & Development Environment Setup

This repository contains scripts to automatically set up a complete development environment on Ubuntu systems. The provisioning is designed to be idempotent, meaning it can be run multiple times without causing issues or duplicating configurations.

## What This Repo Does

The scripts in this repository will:

1. Install essential system packages (nano, npm)
2. Set up Node.js environment with:
   - Global npm configuration
   - n (Node.js version manager)
   - Bun JavaScript runtime
   - Claude Code CLI tool
3. Install and configure UV (Python environment manager)
4. Install and configure Go language
5. Install and configure kubectl (Kubernetes CLI)
6. Install Temporal CLI
7. Link dotfiles and custom configurations:
   - .npmrc
   - .bunfig.toml
   - uv.toml
   - .gitconfig
   - Custom bashrc and profile configurations
8. Synchronize utility scripts to ~/.dotfiles for easy access

## How to Use

To set up your development environment, simply run the main installation script:

```bash
./install.sh
```

This script will:
1. Wait for any existing package manager locks to be released
2. Execute all setup scripts in the correct order
3. Link dotfiles and custom configurations
4. Append custom environment configurations to your shell profile

## Script Breakdown

### Main Orchestrator
- `install.sh`: Main orchestrator script that runs all other scripts in order

### Setup Scripts in `scripts/` directory:
- `install-npm-packages.sh`: Installs global npm packages
- `install-packages.sh`: Installs system packages
- `install-temporal.sh`: Installs Temporal CLI
- `setup-dotfiles.sh`: Links dotfiles and custom configurations
- `setup-go.sh`: Installs and configures Go
- `setup-kubectl.sh`: Installs kubectl and sets up kubeconfig
- `setup-node.sh`: Sets up Node.js environment
- `setup-uv.sh`: Installs UV for Python environment management
- `sync-folders.sh`: Synchronizes utility scripts to ~/.dotfiles

### Utility Scripts in `bin/` directory:
- `jwt-decode`: Utility script for decoding JWT tokens
- `jwt-encode`: Utility script for encoding JWT tokens

## Idempotency

All scripts are designed to be idempotent. This means you can run them multiple times safely. They will check if software is already installed or configured before making changes, preventing duplication or conflicts.

## Directory Structure

```
├── bin/                 # Utility scripts that get synchronized to ~/.dotfiles/bin
│   ├── jwt-decode       # JWT decoding utility
│   └── jwt-encode       # JWT encoding utility
├── scripts/             # All setup and installation scripts
│   ├── install-npm-packages.sh
│   ├── install-packages.sh
│   ├── install-temporal.sh
│   ├── setup-dotfiles.sh
│   ├── setup-go.sh
│   ├── setup-kubectl.sh
│   ├── setup-node.sh
│   ├── setup-uv.sh
│   └── sync-folders.sh
├── shell/               # Shell configuration files
│   ├── .aliases         # Custom shell aliases
│   └── .exports         # Environment variables and PATH configurations
├── .bashrc              # Bash configuration (sources shell/.exports and shell/.aliases)
├── .gitconfig           # Git configuration
├── .npmrc               # npm configuration
├── .profile             # Profile configuration
└── install.sh           # Main installation script
```

## Custom Configurations

- `shell/.aliases`: Contains custom shell aliases like `gst` for `git status`
- `shell/.exports`: Contains environment variables and PATH configurations
- All custom configurations are automatically sourced during shell initialization

After running the setup, restart your terminal or run `source ~/.profile` to load all configurations.