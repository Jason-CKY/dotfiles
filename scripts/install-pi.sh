#!/usr/bin/env bash
# Pi Coding Agent Installation
# Installs/updates @earendil-works/pi-coding-agent to the latest version via npm.
# The official docs recommend the --ignore-scripts flag for npm installs.
# Docs: https://pi.dev/  and https://www.npmjs.com/package/@earendil-works/pi-coding-agent

set -euo pipefail

PACKAGE_NAME="@earendil-works/pi-coding-agent"
BINARY_NAME="pi"
BINARY_PATH="$HOME/.node_modules/bin/$BINARY_NAME"

# Check if npm is available
if ! command -v npm &> /dev/null; then
    echo "Error: npm is not installed. Please run setup-node.sh first." >&2
    exit 1
fi

echo "Using npm: $(npm --version)"

# Always install the latest release.
echo "Installing/updating $PACKAGE_NAME@latest..."
npm install -g --ignore-scripts "$PACKAGE_NAME@latest"

if [ -x "$BINARY_PATH" ]; then
    echo "$BINARY_NAME installed: $("$BINARY_PATH" --version 2>/dev/null) at $BINARY_PATH"
fi

echo "Pi Coding Agent setup complete."
echo "Note: Pi configuration is synced by sync-pi.sh"
