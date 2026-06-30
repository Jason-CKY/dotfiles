#!/usr/bin/env bash
# System Package Management

set -euo pipefail

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
source "$SCRIPT_DIR/lib/common.sh"

# Update package lists if needed
update_if_needed nano npm

# Install packages
install_if_missing nano
install_if_missing npm
install_if_missing openssl
install_if_missing jq
install_if_missing wl-clipboard
install_if_missing ripgrep
install_if_missing fd-find

# Symlink fdfind to fd for convenience
mkdir -p ~/.local/bin
ln -sf /usr/bin/fdfind ~/.local/bin/fd
