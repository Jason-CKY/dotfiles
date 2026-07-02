#!/usr/bin/env bash
# Claude Code Installation Script (Idempotent)

set -euo pipefail

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"

CLAUDE_BIN="$HOME/.local/bin/claude"

# Marketplaces registered with Claude Code, managed via the `claude plugin`
# CLI so Claude tracks them in ~/.claude/plugins/known_marketplaces.json.
CLAUDE_MARKETPLACES=(
    "anthropics/claude-plugins-official"
)

# Plugins to install (plugin@marketplace). Recorded by Claude in
# ~/.claude/plugins/installed_plugins.json; enabled via the "enabledPlugins"
# block of config/claude/settings.json. Keep the two lists in sync.
CLAUDE_PLUGINS=(
    "typescript-lsp@claude-plugins-official"
    "pyright-lsp@claude-plugins-official"
    "gopls-lsp@claude-plugins-official"
)

# Check if Node.js is installed (prerequisite)
if ! command -v node &> /dev/null; then
    echo "Node.js is required for Claude Code. Please run setup-node.sh first."
    exit 0
fi

# Install or update Claude Code to the latest version via the official installer.
# Docs: https://code.claude.com/docs/en/setup
if [ -x "$CLAUDE_BIN" ]; then
    echo "Claude Code found at $CLAUDE_BIN ($("$CLAUDE_BIN" --version 2>/dev/null)). Updating to latest..."
    "$CLAUDE_BIN" update || echo "Warning: 'claude update' failed; keeping the installed version."
else
    echo "Installing latest Claude Code via official installer..."
    curl -fsSL https://claude.ai/install.sh | bash
fi

echo "Claude Code installation complete."

# Register marketplaces and install plugins via the `claude plugin` CLI. This
# lets Claude Code track everything correctly (known_marketplaces.json /
# installed_plugins.json / marketplaces/ / cache/), unlike a raw git clone which
# Claude does not recognize. Every command is idempotent — re-adding a
# marketplace or re-installing a plugin is a safe no-op — and best-effort, so a
# transient network failure warns instead of aborting the whole install.
#
# Runs AFTER sync_local_config so the declarative settings.json (with its
# enabledPlugins + extraKnownMarketplaces blocks) is already in place before the
# CLI installs — otherwise the settings copy would clobber what the CLI writes.
setup_plugins() {
    if [ ! -x "$CLAUDE_BIN" ]; then
        echo "Claude binary not found at $CLAUDE_BIN. Skipping marketplace/plugin setup."
        return 0
    fi
    for market in "${CLAUDE_MARKETPLACES[@]}"; do
        echo "Registering marketplace: $market"
        "$CLAUDE_BIN" plugin marketplace add "$market" \
            || echo "Warning: failed to add marketplace $market."
    done
    for plugin in "${CLAUDE_PLUGINS[@]}"; do
        echo "Installing plugin: $plugin"
        "$CLAUDE_BIN" plugin install "$plugin" --scope user \
            || echo "Warning: failed to install plugin $plugin."
    done
}

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

    # NB: ~/.claude/plugins is intentionally NOT copied from the repo. It is
    # runtime state that Claude Code manages (with machine-specific absolute
    # paths) via the `claude plugin` CLI above. Copying a checked-in copy over
    # it would clobber known_marketplaces.json / installed_plugins.json.

    echo "Local Claude config synced successfully."
}

sync_local_config
setup_plugins
