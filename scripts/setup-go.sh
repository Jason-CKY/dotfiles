#!/usr/bin/env bash
# Golang Setup

set -euo pipefail

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
source "$SCRIPT_DIR/lib/common.sh"

GO_VERSION="1.26.3"
GO_INSTALL_DIR="$HOME/.local/go"
GO_BIN="$GO_INSTALL_DIR/bin/go"
EXPECTED_VERSION_STR="go${GO_VERSION}"

# Determine if installation is needed
NEEDS_INSTALL=false

if [ ! -f "$GO_BIN" ]; then
    echo "Go is not installed."
    NEEDS_INSTALL=true
else
    CURRENT_VERSION_STR=$("$GO_BIN" version | awk '{print $3}')

    if [ "$CURRENT_VERSION_STR" != "$EXPECTED_VERSION_STR" ]; then
        echo "Version mismatch detected."
        echo "  Current: $CURRENT_VERSION_STR"
        echo "  Desired: $EXPECTED_VERSION_STR"
        echo "Removing existing Go installation to force update..."
        sudo rm -rf "$GO_INSTALL_DIR"
        NEEDS_INSTALL=true
    else
        echo "Go is already at the correct version ($GO_VERSION)."
    fi
fi

# Installation Execution
if [ "$NEEDS_INSTALL" = true ]; then
    echo "Installing Go version $GO_VERSION..."
    mkdir -p "$HOME/.local"

    GO_TAR_GZ="/tmp/go${GO_VERSION}.linux-amd64.tar.gz"
    DOWNLOAD_URL="https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz"

    # Download if not cached in /tmp
    if [ ! -f "$GO_TAR_GZ" ]; then
        echo "Downloading..."
        if ! wget -q "$DOWNLOAD_URL" -O "$GO_TAR_GZ"; then
            echo "Error: Failed to download Go from $DOWNLOAD_URL"
            exit 1
        fi
    fi

    echo "Extracting..."
    sudo tar -C "$HOME/.local" -xzf "$GO_TAR_GZ"
    sudo rm "$GO_TAR_GZ"

    echo "Installation complete."
fi

export PATH="$GO_INSTALL_DIR/bin:$PATH"

# install go language server protocol for golang
go install golang.org/x/tools/gopls@latest
