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

# Add (or reconcile) the HashiCorp apt repository. We compare the file's exact
# desired content rather than merely checking that the file exists: a stale
# repo line left by an earlier setup (e.g. a different `${VERSION_CODENAME}`
# after an OS upgrade, or a different `signed-by` keyring path) would otherwise
# never be corrected, leaving apt unable to fetch the package index — which
# surfaces later as "Unable to locate package vault".
# shellcheck disable=SC1091
source /etc/os-release
REPO_LIST_PATH="/etc/apt/sources.list.d/hashicorp.list"
REPO_LINE="deb [signed-by=${KEYRING_PATH}] https://apt.releases.hashicorp.com ${VERSION_CODENAME} main"

repo_changed=false
if [ -f "$REPO_LIST_PATH" ] && [ "$(<"$REPO_LIST_PATH")" = "$REPO_LINE" ]; then
    echo "HashiCorp apt repository already configured at $REPO_LIST_PATH."
else
    if [ -f "$REPO_LIST_PATH" ]; then
        echo "Reconciling stale HashiCorp apt repository at $REPO_LIST_PATH..."
    else
        echo "Adding HashiCorp apt repository..."
    fi
    echo "$REPO_LINE" | sudo tee "$REPO_LIST_PATH" > /dev/null
    repo_changed=true
fi

# Refresh the package index before installing. This must run whenever the repo
# was just (re)written OR whenever `vault` is still missing — apt's cached index
# for this repo may be stale/empty even when the .list already exists, and
# `apt-get install` fails with "Unable to locate package" if it isn't refreshed.
# Don't let an unrelated broken third-party repo abort here; the HashiCorp repo
# metadata still gets fetched, which is all `vault` needs below.
if [ "$repo_changed" = true ] || ! pkg_installed vault; then
    echo "Refreshing apt package lists..."
    if ! apt_get update; then
        echo "Warning: 'apt-get update' reported errors; continuing." >&2
    fi
fi

# Install the vault package if it is not already installed
install_if_missing vault

echo "Vault installation check complete."
