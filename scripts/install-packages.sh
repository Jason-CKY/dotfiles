#!/usr/bin/env bash
# System Package Management

set -euo pipefail

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
source "$SCRIPT_DIR/lib/common.sh"

# Update package lists if needed
update_if_needed nano npm

# Install packages
install_if_missing zsh
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

# Set zsh as the default login shell so that `wsl ~` (and any new login shell)
# boots into zsh. Idempotent: only runs chsh when the shell isn't already zsh.
# We use `sudo chsh` (not a bare `chsh`) so it reuses the sudo credentials from
# the apt steps above instead of prompting for the login password.
set_default_shell_zsh() {
    local zsh_path current_shell
    zsh_path="$(command -v zsh)" || {
        echo "zsh not found on PATH; skipping default-shell change." >&2
        return 0
    }

    # chsh only accepts shells listed in /etc/shells.
    if ! grep -qxF "$zsh_path" /etc/shells 2>/dev/null; then
        echo "Adding $zsh_path to /etc/shells..."
        echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
    fi

    current_shell="$(getent passwd "$USER" | cut -d: -f7)"
    if [ "$current_shell" = "$zsh_path" ]; then
        echo "Default shell already set to zsh ($zsh_path)."
        return 0
    fi

    echo "Setting default login shell to zsh ($zsh_path)..."
    sudo chsh -s "$zsh_path" "$USER"
}

set_default_shell_zsh
