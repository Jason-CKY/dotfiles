# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a dotfiles repository that automates setting up a complete development environment on Ubuntu systems. All scripts are idempotent and can be run multiple times safely.

## Common Commands

**Full environment setup:**
```bash
./install.sh
```

**Individual setup scripts:**
```bash
./scripts/setup-dotfiles.sh     # Link dotfiles and configurations
./scripts/sync-folders.sh       # Sync utility scripts to ~/.dotfiles
./scripts/sync-pi.sh            # Sync Pi configuration to ~/.pi
./scripts/install-packages.sh   # Install system packages
./scripts/setup-node.sh         # Set up Node.js (n, npm, bun)
./scripts/install-pi.sh        # Install Pi Coding Agent (npm package)
./scripts/setup-uv.sh           # Install UV Python environment manager
./scripts/setup-go.sh           # Install Go
./scripts/install-temporal.sh   # Install Temporal CLI
./scripts/install-vault.sh      # Install HashiCorp Vault CLI (apt repo)
./scripts/install-claude-code.sh # Install Claude Code CLI and skills
./scripts/install-codex.sh      # Install Codex CLI
./scripts/install-starship.sh   # Install Starship cross-shell prompt
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
  ├── sync-pi.sh (syncs config/pi/ to ~/.pi)
  ├── install-packages.sh (apt packages - uses lib/common.sh)
  ├── setup-node.sh (n, npm global packages, bun)
  ├── install-pi.sh (Pi Coding Agent via npm)
  ├── setup-uv.sh (Python package manager - uses lib/common.sh)
  ├── setup-go.sh (Go runtime - uses lib/common.sh)
  ├── install-temporal.sh (Temporal CLI)
  ├── install-vault.sh (HashiCorp Vault CLI via apt repo)
  ├── install-claude-code.sh (Claude Code CLI and skills)
  ├── install-opencode.sh (OpenCode CLI via official installer)
  ├── install-codex.sh (Codex CLI)
  └── install-starship.sh (Starship cross-shell prompt)
```

### Library Structure

```
scripts/
  ├── lib/
  │   └── common.sh (shared utility functions)
  │       - apt_get()              Run apt-get with a dpkg-lock wait timeout
  │       - dpkg_ensure_configured() Heal an interrupted dpkg (configure --pending)
  │       - pkg_installed()        Check if apt package is installed
  │       - cmd_available()        Check if command is available
  │       - install_if_missing()   Install package if not present
  │       - update_if_needed()     Run apt-get update if needed (non-fatal: a
  │                                 broken third-party repo won't abort the run)
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
  - `config/shell/` - Shell config (`.zshrc`)
  - `config/starship/` - Starship prompt config (`starship.toml`)
  - `config/npm/` - npm config (`.npmrc`)
  - `config/bun/` - Bun config (`.bunfig.toml`)
  - `config/uv/` - UV config (`uv.toml`)
  - `config/claude/` - Claude Code settings, skills, commands, and plugins
    - `settings.json` - Claude Code managed settings
    - `skills/` - **Canonical skills set for all agents.** Synced as an exact
      mirror to `~/.claude/skills/` (wiped first, so skills removed from the repo
      are removed on install). OpenCode, Pi, and Codex symlink to this dir.
    - `commands/` - Slash commands (copied to `~/.claude/commands/`)
      - `/code-review` - Comprehensive code review
      - `/git-commit` - Create git commits
      - `/refactor` - Refactor code
      - `/security-check` - Security vulnerability scan
    - (Plugins/marketplaces are **not** stored here — they are runtime state
      managed by the `claude plugin` CLI in `install-claude-code.sh`, since
      `~/.claude/plugins/*.json` contains machine-specific absolute paths.)
- `shell/` - Shell source files (`.exports`, `.aliases`)

### Configuration Loading

- Shell config targets **zsh**. `install-packages.sh` installs the `zsh`
  package but does **not** run `chsh` to change the default login shell (that
  is left to the user: `chsh -s "$(command -v zsh)"`).
- `~/.zshrc` (sourced by zsh for interactive shells) sources
  `~/.dotfiles/shell/.aliases` and `~/.dotfiles/shell/.exports`

## Key Configurations

### npm
- Registry: https://registry.npmjs.org/
- Global prefix: `~/.node_modules`

### Path Configuration
All local bins are consolidated in PATH via `shell/.exports`:
- `~/.local/bin`
- `~/.dotfiles/bin`
- `~/.opencode/bin` (OpenCode's official-installer location)
- `~/.local/go/bin`, `~/.go/bin`
- `~/.node_modules/bin`, `~/.n/bin`, `~/.bun/bin`

### Aliases
- `gst` - `git status`
- `serve` - `uv run -- python -m http.server`
- `oc` - `opencode`
- `cc` - `claude`

## Pi Coding Agent

- Pi is installed/updated to the **latest** on every run via npm (with the
  docs-recommended `--ignore-scripts` flag):
  `npm install -g --ignore-scripts @earendil-works/pi-coding-agent@latest`
- Pi is configured in `config/pi/agent/` and synced to `~/.pi`
- Settings: `config/pi/agent/settings.json` → `~/.pi/agent/settings.json`
- Skills: `~/.pi/agent/skills/` is a **symlink** to `~/.claude/skills/` (the
  canonical set), created by `sync-pi.sh`. Pi has no separate skills in the repo.

### Pi MCP Adapter

- `pi-mcp-adapter` package is installed via `settings.json`, providing MCP server
  integration for Pi.
- No MCP servers are configured by default.

## Claude Code

- Claude Code CLI is installed via `install-claude-code.sh`.
- Installed/updated to the **latest** on every run: if `~/.local/bin/claude`
  already exists the script runs `claude update`; otherwise it installs via the
  official installer `curl -fsSL https://claude.ai/install.sh | bash` (binary
  lands at `~/.local/bin/claude`).
- Settings: `config/claude/settings.json` → `~/.claude/settings.json`
- Skills: `config/claude/skills/` → `~/.claude/skills/` — the **canonical skills
  set**. `setup-dotfiles.sh` (and `install-claude-code.sh`) wipe
  `~/.claude/skills` before copying, so it is an exact mirror of the repo; skills
  present on the machine but not in the repo are removed. OpenCode
  (`~/.config/opencode/skills`), Pi (`~/.pi/agent/skills`), and Codex
  (`~/.agents/skills`) are all symlinks to this dir.
- Commands: `config/claude/commands/` → `~/.claude/commands/`
- Plugins & marketplaces: managed via the `claude plugin` CLI in
  `install-claude-code.sh` (`setup_plugins`), not by copying files. The script
  registers each marketplace in `CLAUDE_MARKETPLACES` (`claude plugin
  marketplace add`) and installs each plugin in `CLAUDE_PLUGINS` (`claude plugin
  install ... --scope user`). Both are idempotent no-ops when already present.
  This populates `~/.claude/plugins/{known_marketplaces,installed_plugins}.json`
  with correct machine-specific paths — which is why that runtime state is
  **not** checked into the repo. Currently registered:
  `anthropics/claude-plugins-official`. Currently installed: `typescript-lsp`,
  `pyright-lsp`, `gopls-lsp`.
- `config/claude/settings.json` carries the **declarative** plugin config:
  `enabledPlugins` (which installed plugins are active) and
  `extraKnownMarketplaces` (marketplace sources, by GitHub repo — no
  machine-specific paths, safe to commit). `install-claude-code.sh` runs
  `sync_local_config` (copies settings.json) **before** `setup_plugins`, so the
  declarative settings are in place before the CLI installs. Keep
  `enabledPlugins`/`extraKnownMarketplaces` in sync with the
  `CLAUDE_PLUGINS`/`CLAUDE_MARKETPLACES` lists in `install-claude-code.sh`.

### OpenCode Integration

- OpenCode CLI is installed/updated to the **latest** on every run via
  `install-opencode.sh`, using OpenCode's official installer
  (`curl -fsSL https://opencode.ai/install | bash -s -- --no-modify-path`). The
  binary lands at `~/.opencode/bin/opencode` (added to PATH in `shell/.exports`).
  The installer downloads a standalone binary — it needs only `curl`/`tar`, not
  Node or Bun.
- Config is copied from `config/opencode/` to `~/.config/opencode/` by
  `setup-dotfiles.sh` (commands come from `config/opencode/commands/`).
- Skills: `~/.config/opencode/skills/` is a **symlink** to `~/.claude/skills/`
  (the canonical set), so OpenCode uses the same skills as Claude. OpenCode has
  no separate skills in the repo.

## Codex

- The Codex CLI is installed via `install-codex.sh` using the official installer:
  `curl -fsSL https://chatgpt.com/codex/install.sh | sh` (binary lands at
  `~/.local/bin/codex`, home dir `~/.codex`). Idempotent: skips if `codex` is
  already on PATH.
- Codex shares Claude Code's skills via a symlink created by `setup-dotfiles.sh`:
  `~/.agents/skills` → `~/.claude/skills`. `~/.agents/skills` is Codex's
  documented **user-level** skills location (per
  https://developers.openai.com/codex/skills), and Codex follows the symlink
  target when scanning for skills — so every Claude skill is available to Codex.

## Starship Prompt

- Starship is the shell prompt, shared across **both bash and zsh**. Installed
  via `install-starship.sh` using the official installer
  (`curl -sS https://starship.rs/install.sh | sh -s -- -y -b ~/.local/bin`).
  Idempotent: skips if `starship` is already on PATH.
- Config: `config/starship/starship.toml` → `~/.config/starship.toml` (copied by
  `setup-dotfiles.sh`). Based on the official **Gruvbox Rainbow** preset, trimmed
  to the tools in use.
- Shell init:
  - zsh: the managed `.zshrc` runs `eval "$(starship init zsh)"` when starship is
    on PATH (falls back to the old built-in `PROMPT` otherwise).
  - bash: `setup-dotfiles.sh` appends an `eval "$(starship init bash)"` block to
    `~/.bashrc` idempotently (guarded by a `grep`, so it never clobbers the
    user's bashrc or duplicates on re-runs).
- Prompt segments: OS + username, current path, git branch + status (shown as
  readable per-state counts, e.g. `!2 ?1 +3`), Go / Bun / Python(+uv venv)
  versions when in a relevant project, the current kubectl (Kubernetes) context,
  and the time.
- **Requires a Nerd Font** in the terminal for the powerline arrows and tool
  icons to render (otherwise they show as boxes).

## Vault CLI

- The HashiCorp Vault CLI is installed via `install-vault.sh` (apt package `vault`).
- The script adds the official HashiCorp apt repo at `apt.releases.hashicorp.com`:
  - GPG key (from `https://apt.releases.hashicorp.com/gpg`) →
    `/usr/share/keyrings/hashicorp-keyring.gpg`
  - Repo list → `/etc/apt/sources.list.d/hashicorp.list`
    (uses `${VERSION_CODENAME}` from `/etc/os-release`)
- Idempotent: skips the key/repo/`apt-get update` if already present.
- Authentication is **not** automated — log in manually after setup with
  `vault login <token>` (token copied from the Vault UI).

## Important Notes

- All `apt-get` calls go through `apt_get()` in `lib/common.sh`, which passes
  `-o DPkg::Lock::Timeout` (default 300s, override with `APT_LOCK_TIMEOUT`) so apt
  *waits* for the dpkg/apt lock if another process (e.g. `unattended-upgrades`)
  holds it mid-run, instead of failing with exit code 100. `install.sh` also does
  a best-effort `fuser`-based lock check up front before any scripts run.
- If an apt run is killed mid-configure (common when a workspace restarts during
  `unattended-upgrades`), dpkg is left half-done and aborts the next apt-get with
  "dpkg was interrupted...". `install.sh` calls `dpkg_ensure_configured()` (runs
  `sudo dpkg --configure -a --pending`) up front to heal this; it is a no-op when
  dpkg is clean.
- `apt-get update` is treated as non-fatal. `update_if_needed()` (and the
  `apt_get update` in `install-vault.sh`) warn and continue if the update
  reports errors, so a single broken/decommissioned third-party apt repo on the
  host (e.g. a dead PPA whose `InRelease` no longer verifies) doesn't abort the
  whole `install.sh` run. The actual package installs still come from the repos
  that updated successfully and fail loudly only if a package is genuinely
  unavailable. Note: this masks update failures by design — fix broken host apt
  sources separately (remove the dead `.list` from `/etc/apt/sources.list.d/`).
- All setup scripts check for existing installations before making changes

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
