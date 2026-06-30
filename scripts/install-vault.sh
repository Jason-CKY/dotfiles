#!/usr/bin/env bash
# Vault CLI Installation
#
# Installs the HashiCorp Vault CLI from the official HashiCorp apt repository,
# then installs the `vault` package. Idempotent: skips work already done.

set -euo pipefail

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
source "$SCRIPT_DIR/lib/common.sh"

KEYRING_PATH="/usr/share/keyrings/hashicorp-keyring.gpg"
GPG_URL="https://apt.releases.hashicorp.com/gpg"

# Install the HashiCorp GPG key if it is not already present
if [ -f "$KEYRING_PATH" ]; then
    echo "HashiCorp keyring already exists at $KEYRING_PATH."
else
    echo "Installing HashiCorp GPG key..."
    curl -fsSL "$GPG_URL" | gpg --dearmor | sudo tee "$KEYRING_PATH" > /dev/null
fi

# Add the HashiCorp apt repository if it is not already configured
# shellcheck disable=SC1091
source /etc/os-release
REPO_LIST_PATH="/etc/apt/sources.list.d/hashicorp.list"

if [ -f "$REPO_LIST_PATH" ]; then
    echo "HashiCorp apt repository already configured at $REPO_LIST_PATH."
else
    echo "Adding HashiCorp apt repository..."
    echo "deb [signed-by=${KEYRING_PATH}] https://apt.releases.hashicorp.com ${VERSION_CODENAME} main" \
        | sudo tee "$REPO_LIST_PATH" > /dev/null
    # Don't let an unrelated broken third-party repo abort here; the HashiCorp
    # repo metadata still gets fetched, which is all `vault` needs below.
    if ! apt_get update; then
        echo "Warning: 'apt-get update' reported errors; continuing." >&2
    fi
fi

# Install the vault package if it is not already installed
install_if_missing vault

echo "Vault installation check complete."
