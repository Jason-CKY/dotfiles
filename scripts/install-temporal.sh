#!/usr/bin/env bash
# Temporal CLI Installation

set -euo pipefail

INSTALL_DIR="$HOME/.local/bin"
TEMPORAL_INSTALL_PATH="$INSTALL_DIR/temporal"
# Official "latest" archive endpoint (redirects to the newest linux/amd64 build)
TEMPORAL_ARCHIVE_URL="https://temporal.download/cli/archive/latest?platform=linux&arch=amd64"

# Check if the binary already exists
if [ -f "$TEMPORAL_INSTALL_PATH" ]; then
    echo "Temporal binary already exists at $TEMPORAL_INSTALL_PATH. Skipping download."
else
    echo "Downloading Temporal CLI..."
    mkdir -p "$INSTALL_DIR"
    TMP_DIR="$(mktemp -d)"
    if curl -fsSL "$TEMPORAL_ARCHIVE_URL" -o "$TMP_DIR/temporal.tar.gz"; then
        tar -xzf "$TMP_DIR/temporal.tar.gz" -C "$TMP_DIR" temporal
        mv "$TMP_DIR/temporal" "$TEMPORAL_INSTALL_PATH"
        chmod +x "$TEMPORAL_INSTALL_PATH"
        echo "Download successful."
    else
        echo "Error: Download failed." >&2
        rm -rf "$TMP_DIR"
        exit 1
    fi
    rm -rf "$TMP_DIR"
fi

echo "Temporal installation check complete."
