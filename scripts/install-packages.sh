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

# Set bash as the default login shell so that `wsl ~` (and any new login shell)
# boots into bash. Idempotent: only runs chsh when the shell isn't already bash.
# We use `sudo chsh` (not a bare `chsh`) so it reuses the sudo credentials from
# the apt steps above instead of prompting for the login password.
set_default_shell_bash() {
    local bash_path current_shell
    bash_path="$(command -v bash)" || {
        echo "bash not found on PATH; skipping default-shell change." >&2
        return 0
    }

    # chsh only accepts shells listed in /etc/shells.
    if ! grep -qxF "$bash_path" /etc/shells 2>/dev/null; then
        echo "Adding $bash_path to /etc/shells..."
        echo "$bash_path" | sudo tee -a /etc/shells >/dev/null
    fi

    current_shell="$(getent passwd "$USER" | cut -d: -f7)"
    if [ "$current_shell" = "$bash_path" ]; then
        echo "Default shell already set to bash ($bash_path)."
        return 0
    fi

    echo "Setting default login shell to bash ($bash_path)..."
    sudo chsh -s "$bash_path" "$USER"
}

# Remove zsh: this repo targets bash exclusively. Purge the package when present
# and drop the orphaned managed ~/.zshrc left by earlier (zsh-based) installs.
# Idempotent: a no-op once zsh is already gone.
remove_zsh() {
    if pkg_installed zsh; then
        echo "Removing zsh package..."
        apt_get purge -y zsh
    else
        echo "zsh is not installed."
    fi
    rm -f "$HOME/.zshrc"
}

# Switch the login shell to bash *before* purging zsh so the login shell never
# points at a removed binary.
set_default_shell_bash
remove_zsh
