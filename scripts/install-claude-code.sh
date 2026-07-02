#!/usr/bin/env bash
# Claude Code Installation Script (Idempotent)

set -euo pipefail

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"

CLAUDE_BIN="$HOME/.local/bin/claude"
CLAUDE_PLUGINS_DIR="$HOME/.claude/plugins"

# Official public Claude Code plugins marketplace
OFFICIAL_REPO="https://github.com/anthropics/claude-plugins-official.git"

# Check if Node.js is installed (prerequisite)
if ! command -v node &> /dev/null; then
    echo "Node.js is required for Claude Code. Please run setup-node.sh first."
    exit 0
fi

# Install or update Claude Code via the official installer
if [ -x "$CLAUDE_BIN" ]; then
    echo "Claude Code already installed at $CLAUDE_BIN ($("$CLAUDE_BIN" --version 2>/dev/null))."
    echo "Run 'claude update' to upgrade."
else
    echo "Installing Claude Code via official installer..."
    curl -fsSL https://claude.ai/install.sh | bash
fi

echo "Claude Code installation complete."

# Clone the official plugins marketplace (best-effort; failure is non-fatal)
if command -v git &> /dev/null; then
    if [ -d "$CLAUDE_PLUGINS_DIR/claude-plugins-official" ]; then
        echo "Official marketplace exists. Pulling latest..."
        git -C "$CLAUDE_PLUGINS_DIR/claude-plugins-official" pull \
            || echo "Warning: failed to update official marketplace."
    else
        echo "Cloning official marketplace..."
        mkdir -p "$CLAUDE_PLUGINS_DIR"
        git clone "$OFFICIAL_REPO" "$CLAUDE_PLUGINS_DIR/claude-plugins-official" \
            || echo "Warning: failed to clone official marketplace."
    fi
else
    echo "Git not installed. Skipping plugin clone."
fi

# Sync local Claude config files to ~/.claude/
sync_local_config() {
    local config_source="$SCRIPT_DIR/../config/claude"
    local claude_home="$HOME/.claude"

    if [ ! -d "$config_source" ]; then
        echo "Claude config source not found at $config_source. Skipping config sync."
        return 1
    fi

    echo "Syncing local Claude configuration files..."

    if [ -f "$config_source/settings.json" ]; then
        mkdir -p "$claude_home"
        cp "$config_source/settings.json" "$claude_home/settings.json"
        echo "  Installed settings.json"
    fi

    if [ -d "$config_source/skills" ]; then
        # Exact mirror: wipe first so skills removed from this repo are also
        # removed here. OpenCode, Pi, and Codex all symlink to this dir.
        rm -rf "$claude_home/skills"
        cp -r "$config_source/skills" "$claude_home/skills"
        echo "  Installed skills (mirrored)"
    fi

    if [ -d "$config_source/commands" ]; then
        mkdir -p "$claude_home/commands"
        for cmd in "$config_source/commands"/*.md; do
            [ -f "$cmd" ] && cp "$cmd" "$claude_home/commands/"
        done
        echo "  Installed commands"
    fi

    if [ -d "$config_source/plugins" ]; then
        mkdir -p "$claude_home/plugins"
        cp -r "$config_source/plugins"/* "$claude_home/plugins/"
        echo "  Installed plugins"
    fi

    echo "Local Claude config synced successfully."
}

sync_local_config
