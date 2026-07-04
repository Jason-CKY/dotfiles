#!/usr/bin/env bash
# Idempotent Provisioning Script

set -euo pipefail

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"

source "$SCRIPT_DIR/shell/.exports"
source "$SCRIPT_DIR/scripts/lib/common.sh"

# --- Helper Functions for Locks ---

# Function to check if dpkg is locked
wait_for_dpkg_lock() {
    echo "Waiting for dpkg and apt locks to be released..."
    while fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1 || \
          fuser /var/lib/dpkg/lock >/dev/null 2>&1 || \
          fuser /var/lib/apt/lists/lock >/dev/null 2>&1 || \
          fuser /var/cache/apt/archives/lock >/dev/null 2>&1; do
        echo "Another process is using dpkg/apt... waiting..."
        sleep 2
    done
}

# Wait for package manager locks to be released
wait_for_dpkg_lock
echo "Package manager locks are free. Proceeding..."

# Heal any dpkg state left half-configured by an interrupted apt run before the
# package scripts run (no-op when dpkg is already clean).
dpkg_ensure_configured

# --- Execute Installation Scripts ---

# Run each installation script in order

echo "Running dotfiles setup script..."
$SCRIPT_DIR/scripts/setup-dotfiles.sh

echo "Running sync folders script..."
$SCRIPT_DIR/scripts/sync-folders.sh

echo "Running Pi sync script..."
$SCRIPT_DIR/scripts/sync-pi.sh

echo "Running package installation script..."
$SCRIPT_DIR/scripts/install-packages.sh

echo "Running Node.js environment setup script..."
$SCRIPT_DIR/scripts/setup-node.sh

echo "Running Pi Coding Agent installation script..."
$SCRIPT_DIR/scripts/install-pi.sh

echo "Running Claude Code installation script..."
$SCRIPT_DIR/scripts/install-claude-code.sh

echo "Running UV (Python Environment) setup script..."
$SCRIPT_DIR/scripts/setup-uv.sh

echo "Running Golang setup script..."
$SCRIPT_DIR/scripts/setup-go.sh

echo "Running Temporal CLI installation script..."
$SCRIPT_DIR/scripts/install-temporal.sh

echo "Running Vault CLI installation script..."
$SCRIPT_DIR/scripts/install-vault.sh

echo "Running opencode-ai installation script..."
$SCRIPT_DIR/scripts/install-opencode.sh

echo "Running Codex CLI installation script..."
$SCRIPT_DIR/scripts/install-codex.sh

echo "Running Nerd Font installation script..."
$SCRIPT_DIR/scripts/install-nerd-font.sh

echo "Running Starship prompt installation script..."
$SCRIPT_DIR/scripts/install-starship.sh

echo "Script finished. All components are configured."

