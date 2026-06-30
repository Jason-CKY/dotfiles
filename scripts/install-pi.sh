#!/usr/bin/env bash
# Pi Coding Agent Installation
# Uses npm to install the latest version of @earendil-works/pi-coding-agent

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

# Check if pi binary exists
needs_install=false
if [ ! -x "$BINARY_PATH" ]; then
    echo "$BINARY_NAME is not installed."
    needs_install=true
else
    # Get installed version
    installed_version=$("$BINARY_PATH" --version 2>/dev/null | awk '{print $NF}' | sed 's/^v//')
    echo "Installed version: $installed_version at $BINARY_PATH"
    echo "$BINARY_NAME is already installed."
fi

# Perform installation only if not installed
if [ "$needs_install" = true ]; then
    echo "Installing $PACKAGE_NAME@latest..."
    npm install -g "$PACKAGE_NAME@latest"
    echo "Installation complete."
fi

echo "Pi Coding Agent setup complete."
echo "Note: Pi configuration is synced by sync-pi.sh"
