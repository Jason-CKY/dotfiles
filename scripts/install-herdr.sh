#!/usr/bin/env bash
# Herdr Installation Script (Idempotent)
# Herdr is a terminal-native agent multiplexer ("tmux for coding agents").
# Docs: https://herdr.dev/  Repo: https://github.com/ogulcancelik/herdr

set -euo pipefail

# The official installer places the binary in ~/.local/bin by default (already
# in PATH via shell/.exports). It never edits shell rc files — it only warns if
# the dir is not on PATH — so no --no-modify-path style flag is needed.
export HERDR_INSTALL_DIR="$HOME/.local/bin"
HERDR_BIN="$HERDR_INSTALL_DIR/herdr"

# Coding-agent integrations to register with herdr. Each provides native session
# restore / semantic agent-status detection for that agent inside herdr panes.
HERDR_INTEGRATIONS=(
    claude
    codex
    opencode
    pi
)

if ! command -v curl &> /dev/null; then
    echo "Error: curl is required to install herdr." >&2
    exit 1
fi

# Install or update herdr to the latest version. `herdr update` upgrades an
# installer-managed binary in place; otherwise run the official installer.
if [ -x "$HERDR_BIN" ]; then
    echo "Herdr found at $HERDR_BIN ($("$HERDR_BIN" --version 2>/dev/null)). Updating to latest..."
    "$HERDR_BIN" update || echo "Warning: 'herdr update' failed; keeping the installed version."
else
    echo "Installing latest Herdr via official installer..."
    curl -fsSL https://herdr.dev/install.sh | sh
fi

echo "Herdr installation complete."

# Register coding-agent integrations. `herdr integration install` is idempotent
# (a no-op when already installed) and best-effort per agent, so an agent that
# is not present (or a transient failure) warns instead of aborting the run.
if [ -x "$HERDR_BIN" ]; then
    for agent in "${HERDR_INTEGRATIONS[@]}"; do
        echo "Installing herdr integration: $agent"
        "$HERDR_BIN" integration install "$agent" \
            || echo "Warning: failed to install herdr integration for $agent."
    done
else
    echo "Herdr binary not found at $HERDR_BIN. Skipping integration setup."
fi

echo "Herdr integration setup complete."
