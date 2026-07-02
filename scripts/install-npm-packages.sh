#!/usr/bin/env bash

# ==========================================
# Configuration
# ==========================================
NPM_CMD="npm"

# Check if a custom path argument was provided
if [ -n "$1" ]; then
    NPM_CMD="$1"
    echo "Configuration: Using custom npm at '$NPM_CMD'"
else
    echo "Configuration: Using default 'npm' from PATH"
fi

# Set these to specific numbers (e.g., "0.2.9") or "latest"
BUN_VERSION="latest"

# ==========================================
# Reusable Function
# ==========================================
# Usage: ensure_npm_package "package_name" "binary_command_name" "desired_version"
ensure_npm_package() {
    local package_name="$1"
    local binary_name="$2"
    local target_version="$3"
    local installed_version=""
    local needs_install=false

    echo "Checking $binary_name ($package_name)..."

    # 1. Resolve "latest" to a specific version number if requested
    if [ "$target_version" == "latest" ]; then
        # Use the explicit $NPM_CMD (not a bare `npm`) so version resolution uses
        # the same Node-managed npm we install with, regardless of PATH order or
        # a broken system npm shadowing it.
        # We assume internet access is available since we are in an install script.
        target_version=$("$NPM_CMD" view "$package_name" version)
        echo "  Resolved 'latest' to: $target_version"
    fi

    # 2. Check installed status
    if ! command -v "$binary_name" &> /dev/null; then
        echo "  $binary_name is not installed."
        needs_install=true
    else
        # 3. Get local version
        # We try to get the version from the binary.
        # Most modern tools support --version and output just the number or "tool x.y.z"
        # We use awk to grab the last space-delimited column which is usually the number.
        installed_version=$("$binary_name" --version | awk '{print $NF}' | sed 's/^v//')
        
        # Determine if we need to update
        if [ "$installed_version" != "$target_version" ]; then
            echo "  Version mismatch."
            echo "    Current: $installed_version"
            echo "    Target:  $target_version"
            needs_install=true
        else
            echo "  $binary_name is already at $target_version."
        fi
    fi

    # 4. Perform Install / Update
    if [ "$needs_install" = true ]; then
        echo "  Installing $package_name@$target_version..."
        # We use --force to ensure it overwrites binaries if there's a conflict
        $NPM_CMD install -g "$package_name@$target_version" --force
        echo "  [OK] Installation complete."
    fi
    echo "---"
}

# ==========================================
# Execution
# ==========================================

# Install Bun
# Note: We are using npm to install bun as requested, though bun has its own curl installer.
ensure_npm_package "bun" "bun" "$BUN_VERSION"

# Install typescript-language-server
ensure_npm_package "typescript-language-server" "typescript-language-server" "latest"

