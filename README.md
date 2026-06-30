# Dotfiles & Development Environment Setup

This repository automates setting up a complete development environment on Ubuntu
systems. Every script is **idempotent** — it can be run multiple times safely,
checking for existing installations and configurations before making changes.

## Quick Start

```bash
./install.sh
```

The orchestrator waits for any apt/dpkg locks to clear, then runs each setup
script in order. After it finishes, restart your terminal or run
`source ~/.profile` to load the new shell configuration.

> For a deeper reference (architecture, conventions, key configuration values),
> see [`CLAUDE.md`](CLAUDE.md). To add a new setup script, see
> [`DEVELOPER_GUIDE.md`](DEVELOPER_GUIDE.md).

## What Gets Installed

`install.sh` runs the following, in order:

| Step | Script | What it does |
|------|--------|--------------|
| 1 | `setup-dotfiles.sh` | Link/copy configs (`.bashrc`, `.profile`, `.npmrc`, `.bunfig.toml`, `uv.toml`) into `$HOME` |
| 2 | `sync-folders.sh` | Sync `bin/` and `shell/` to `~/.dotfiles` |
| 3 | `sync-pi.sh` | Sync Pi Coding Agent config (`config/pi/agent/`) to `~/.pi` |
| 4 | `install-packages.sh` | Install apt system packages |
| 5 | `setup-node.sh` | Set up Node.js (`n`, npm global packages, Bun) |
| 6 | `install-pi.sh` | Install Pi Coding Agent via npm |
| 7 | `install-claude-code.sh` | Install Claude Code CLI, skills, commands, and plugins |
| 8 | `setup-uv.sh` | Install UV (Python package/environment manager) |
| 9 | `setup-go.sh` | Install Go |
| 10 | `install-temporal.sh` | Install the Temporal CLI |
| 11 | `install-vault.sh` | Install the HashiCorp Vault CLI (official apt repo) |
| 12 | `install-opencode.sh` | Install the OpenCode CLI (via Bun) and link Claude commands/skills |
| 13 | `install-codex.sh` | Install the Codex CLI (shares Claude skills via `~/.agents/skills`) |

## Repository Layout

```
├── install.sh              # Main orchestrator (runs everything below in order)
├── bin/                    # Utility scripts, synced to ~/.dotfiles/bin (on PATH)
│   ├── jwt-decode          #   Decode a JWT to JSON
│   └── jwt-encode          #   Encode JSON to a JWT
├── scripts/                # Setup/installation scripts
│   └── lib/common.sh       #   Shared utility functions for setup scripts
├── config/                 # Configuration files, organized by tool
│   ├── shell/              #   .bashrc, .profile
│   ├── git/  npm/  bun/  uv/
│   ├── claude/            #   Claude Code settings, skills, commands, plugins
│   ├── opencode/         #   OpenCode commands, skills, plugins
│   └── pi/               #   Pi Coding Agent config
├── shell/                  # Sourced shell files
│   ├── .aliases           #   e.g. gst→git status, serve→http.server
│   └── .exports           #   PATH and environment variables
├── CLAUDE.md               # Full reference for humans and AI agents
└── DEVELOPER_GUIDE.md      # How to add new setup scripts
```

Shell loading: `~/.profile` sources `~/.bashrc`, which sources
`~/.dotfiles/shell/.aliases` and `~/.dotfiles/shell/.exports`.

## CLI Utilities (on PATH after setup)

```bash
jwt-decode <token>     # Decode a JWT token to JSON
jwt-encode <payload>   # Encode a JSON payload to a JWT
```

## Development

- **Idempotency**: every script must be safe to run repeatedly.
- **Syntax check**: `bash -n script.sh`.
- **Pre-commit hook**: runs `shellcheck` on all shell scripts
  (`sudo apt-get install shellcheck`).
- Shared helpers for setup scripts live in `scripts/lib/common.sh` — source it
  rather than reimplementing install/version/download logic.
