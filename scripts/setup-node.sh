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

# `n` installs Node into N_PREFIX. Export it so n (and the rest of this script)
# agree on the location even when run standalone (install.sh sources
# shell/.exports, but this script must also work on its own).
export N_PREFIX="$HOME/.n"
N_BIN="$N_PREFIX/bin/n"

# Bootstrap `n` directly from source. `n` is a standalone bash script, so this
# needs neither an existing Node nor npm. That matters because the system's
# node/npm may be missing or broken (e.g. a stray `/usr/local/bin/node -> bun`
# symlink shadowing the real binary makes apt's npm crash). Bootstrapping via
# curl sidesteps that entirely.
if [ ! -x "$N_BIN" ]; then
    echo "Bootstrapping n (standalone, no npm required)..."
    mkdir -p "$N_PREFIX/bin"
    curl -fsSL https://raw.githubusercontent.com/tj/n/master/bin/n -o "$N_BIN"
    chmod +x "$N_BIN"
else
    echo "n is already installed at $N_BIN."
fi

# Install/activate the desired Node.js version into N_PREFIX.
echo "Installing Node.js 24 via n..."
"$N_BIN" install 24

# Put the freshly installed Node/npm first on PATH for the rest of this run so
# every later command (and install-npm-packages.sh) uses them, not the system's.
export PATH="$N_PREFIX/bin:$PATH"
echo "Using node $(node --version) / npm $(npm --version)"

echo "Running npm package installation script..."
"$SCRIPT_DIR/install-npm-packages.sh" "$N_PREFIX/bin/npm"
