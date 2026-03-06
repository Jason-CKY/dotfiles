#!/usr/bin/env bash
# Idempotent Provisioning Script

set -euo pipefail

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"

source "$SCRIPT_DIR/shell/.exports"

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

# Function to check if apt is locked (This check is less reliable and often redundant if dpkg locks are checked, but kept for completeness)
wait_for_apt_lock() {
    while ps aux | grep -v grep | grep -E 'apt|apt-get|aptitude' >/dev/null; do
        echo "Another apt process is running... waiting..."
        sleep 2
    done
}

# Wait for both locks
wait_for_dpkg_lock
wait_for_apt_lock
echo "Package manager locks are free. Proceeding..."

# --- Execute Installation Scripts ---

# Run each installation script in order

echo "Running dotfiles setup script..."
$SCRIPT_DIR/scripts/setup-dotfiles.sh

echo "Running sync folders script..."
$SCRIPT_DIR/scripts/sync-folders.sh

echo "Running package installation script..."
$SCRIPT_DIR/scripts/install-packages.sh

echo "Running Node.js environment setup script..."
$SCRIPT_DIR/scripts/setup-node.sh

echo "Running UV (Python Environment) setup script..."
$SCRIPT_DIR/scripts/setup-uv.sh

echo "Running Golang setup script..."
$SCRIPT_DIR/scripts/setup-go.sh

echo "Running opencode-ai installation script..."
$SCRIPT_DIR/scripts/install-opencode.sh

echo "Script finished. All components are configured."

