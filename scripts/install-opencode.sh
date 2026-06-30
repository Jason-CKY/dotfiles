#!/usr/bin/env bash
# opencode-ai CLI Installation
# Uses bun to install the latest version of opencode-ai

set -euo pipefail

PACKAGE_NAME="opencode-ai"
BINARY_NAME="opencode"
BINARY_PATH="$HOME/.node_modules/bin/$BINARY_NAME"
BUN_BINARY_PATH="$HOME/.bun/bin/$BINARY_NAME"

# Check if bun is available
if ! command -v bun &> /dev/null; then
    echo "Error: bun is not installed. Please run setup-node.sh first." >&2
    exit 1
fi

echo "Using bun: $(bun --version)"

# Check if opencode binary exists in either location
if [ -x "$BINARY_PATH" ]; then
    OPENCODE_BIN="$BINARY_PATH"
elif [ -x "$BUN_BINARY_PATH" ]; then
    OPENCODE_BIN="$BUN_BINARY_PATH"
else
    OPENCODE_BIN=""
fi

if [ -z "$OPENCODE_BIN" ]; then
    echo "$BINARY_NAME is not installed."
    needs_install=true
else
    # Get installed version
    installed_version=$("$OPENCODE_BIN" --version 2>/dev/null | awk '{print $NF}' | sed 's/^v//')
    echo "Installed version: $installed_version at $OPENCODE_BIN"
    echo "$BINARY_NAME is already installed."
fi

# Perform installation only if not installed
if [ "${needs_install:-false}" = true ]; then
    echo "Installing $PACKAGE_NAME@latest..."
    bun install -g "$PACKAGE_NAME@latest"
    echo "Installation complete."
fi

echo "opencode-ai setup complete."
echo "Note: OpenCode configuration is synced by setup-dotfiles.sh"
