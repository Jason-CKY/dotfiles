#!/usr/bin/env bash
# Starship prompt installation (cross-shell: bash + zsh)

set -euo pipefail

INSTALL_DIR="$HOME/.local/bin"

if command -v starship >/dev/null 2>&1; then
    echo "Starship already installed at $(command -v starship). Skipping download."
else
    echo "Installing Starship prompt..."
    mkdir -p "$INSTALL_DIR"
    # Official installer: -y skips the prompt, -b picks the install dir.
    curl -sS https://starship.rs/install.sh | sh -s -- -y -b "$INSTALL_DIR"
    echo "Starship installation complete."
fi
