#!/usr/bin/env bash
# Node.js Environment Setup (nvm, npm, bun)

set -euo pipefail

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"

# Install nvm if not present
NVM_DIR="$HOME/.nvm"
if [ ! -d "$NVM_DIR" ]; then
    echo "Installing nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
else
    echo "nvm is already installed."
fi

# Source nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Configure global npm without sudo
NPM_GLOBAL_DIR="$HOME/.node_modules"
if [ ! -d "$NPM_GLOBAL_DIR" ]; then
    echo "Configuring global npm directory..."
    sudo mkdir -p "$NPM_GLOBAL_DIR"
    sudo chown -R "$USER" "$NPM_GLOBAL_DIR"
else
    if [ "$(stat -c "%U" "$NPM_GLOBAL_DIR")" != "$USER" ]; then
        echo "Fixing ownership of global npm directory..."
        sudo chown -R "$USER" "$NPM_GLOBAL_DIR"
    fi
fi

# Install and set default node 24
NODE_VERSION="24"
echo "Installing Node.js $NODE_VERSION..."
nvm install "$NODE_VERSION"
nvm alias default "$NODE_VERSION"
nvm use default

# Add nvm to .bashrc if not present
BASHRC="$HOME/.bashrc"
NVM_SOURCE_LINE='[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"'
if ! grep -qF 'NVM_DIR="$HOME/.nvm"' "$BASHRC" 2>/dev/null; then
    echo "" >> "$BASHRC"
    echo '# NVM' >> "$BASHRC"
    echo 'export NVM_DIR="$HOME/.nvm"' >> "$BASHRC"
    echo "$NVM_SOURCE_LINE" >> "$BASHRC"
fi

echo "Node.js $(node --version) installed successfully."
