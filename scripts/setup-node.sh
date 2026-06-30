#!/usr/bin/env bash
# Node.js Environment Setup (npm, n, bun)

set -euo pipefail

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"

# Configure global npm without sudo (Idempotent: checks if directory exists and has correct owner)
NPM_GLOBAL_DIR="$HOME/.node_modules"
if [ ! -d "$NPM_GLOBAL_DIR" ]; then
    echo "Configuring global npm directory..."
    sudo mkdir -p "$NPM_GLOBAL_DIR"
    sudo chown -R "$USER" "$NPM_GLOBAL_DIR"
else
    # Ensure ownership is correct, idempotent way to fix a potential issue
    if [ "$(stat -c "%U" "$NPM_GLOBAL_DIR")" != "$USER" ]; then
        echo "Fixing ownership of global npm directory..."
        sudo chown -R "$USER" "$NPM_GLOBAL_DIR"
    fi
fi

# Install n for Node.js management (Idempotent: checks if n is installed globally)
if ! command -v n &> /dev/null; then
    echo "Installing n..."
    NODE_OPTIONS="" npm install -g n
else
    echo "n is already installed."
fi

# Configure n directory. `n` reads N_PREFIX to decide where to install Node, so
# export it here too (install.sh sources shell/.exports, but this script must
# also work when run standalone, where that export is absent).
export N_PREFIX="$HOME/.n"

if [ ! -d "$N_PREFIX" ]; then
    echo "Creating n directory..."
    mkdir -p "$N_PREFIX"
fi

"$NPM_GLOBAL_DIR/bin/n" install 24

echo "Running npm package installation script..."
"$SCRIPT_DIR/install-npm-packages.sh" "$N_PREFIX/bin/npm"
