#!/usr/bin/env bash
# UV (Python Environment) Setup

set -euo pipefail

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
source "$SCRIPT_DIR/lib/common.sh"

UV_VERSION="0.11.11"
INSTALLER_DOWNLOAD_URL="https://github.com/astral-sh/uv/releases/download/${UV_VERSION}"

# Determine if installation is needed
NEEDS_INSTALL=false

if ! cmd_available uv; then
    echo "uv is not installed."
    NEEDS_INSTALL=true
else
    CURRENT_VERSION=$(uv --version | awk '{print $2}')

    if [ "$CURRENT_VERSION" != "$UV_VERSION" ]; then
        echo "Version mismatch detected."
        echo "  Current: $CURRENT_VERSION"
        echo "  Desired: $UV_VERSION"
        echo "Removing existing uv binary to force reinstall..."
        rm -f "$(command -v uv)"
        NEEDS_INSTALL=true
    else
        echo "uv is already at the correct version ($UV_VERSION)."
    fi
fi

# Install UV
if [ "$NEEDS_INSTALL" = true ]; then
    echo "Installing uv version $UV_VERSION..."

    if wget -q "${INSTALLER_DOWNLOAD_URL}/uv-installer.sh" -O /tmp/uv-installer.sh; then
        env UV_VERSION="$UV_VERSION" \
            INSTALLER_DOWNLOAD_URL="$INSTALLER_DOWNLOAD_URL" \
            sh /tmp/uv-installer.sh
        rm /tmp/uv-installer.sh
        echo "Installation complete."
    else
        echo "Error: Failed to download installer from ${INSTALLER_DOWNLOAD_URL}/uv-installer.sh"
        exit 1
    fi
fi

# Install pyright via uv
if cmd_available uv; then
    echo "Installing pyright via uv..."
    uv tool install pyright
    echo "pyright installation complete."
fi
