#!/usr/bin/env bash
# opencode CLI Installation
# Installs/updates opencode to the latest version using the official installer.
# Docs: https://opencode.ai/docs/  (curl -fsSL https://opencode.ai/install | bash)

set -euo pipefail

BINARY_NAME="opencode"
INSTALL_DIR="$HOME/.opencode/bin"

# The official installer downloads a standalone binary; it needs curl + tar and
# does NOT require node or bun.
if ! command -v curl &> /dev/null; then
    echo "Error: curl is required to install opencode." >&2
    exit 1
fi

# Always pull the latest release. --no-modify-path: PATH is managed by this
# repo in shell/.exports (which adds ~/.opencode/bin), so the installer must not
# edit shell rc files.
echo "Installing/updating $BINARY_NAME to the latest version via the official installer..."
curl -fsSL https://opencode.ai/install | bash -s -- --no-modify-path

if [ -x "$INSTALL_DIR/$BINARY_NAME" ]; then
    echo "$BINARY_NAME installed: $("$INSTALL_DIR/$BINARY_NAME" --version 2>/dev/null) at $INSTALL_DIR/$BINARY_NAME"
fi

echo "opencode setup complete."
echo "Note: OpenCode configuration is synced by setup-dotfiles.sh"
