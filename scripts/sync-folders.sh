#!/usr/bin/env bash

set -euo pipefail

# ==========================================
# Configuration
# ==========================================
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
DEST_ROOT="$HOME/.dotfiles"

# Define our source directories
BIN_SOURCE="$SCRIPT_DIR/../bin"
SHELL_SOURCE="$SCRIPT_DIR/../shell"

# ==========================================
# Clean Slate (Nuke & Pave)
# ==========================================
# We do this ONCE at the start. If we did this inside the function, 
# the second function call would delete the files from the first call.
if [ -d "$DEST_ROOT" ]; then
    echo "Cleaning existing directory: $DEST_ROOT"
    rm -rf "$DEST_ROOT"
fi

mkdir -p "$DEST_ROOT"

# ==========================================
# Reusable Function
# ==========================================
# Usage: sync_subdir "Source Path" "Destination Subfolder Name"
sync_subdir() {
    local source_path="$1"
    local dest_folder_name="$2"
    local full_dest_path="$DEST_ROOT/$dest_folder_name"

    echo "Syncing '$dest_folder_name'..."

    # Check if source exists
    if [ ! -d "$source_path" ]; then
        echo "  [SKIP] Source '$source_path' not found."
        return
    fi

    # 1. Create the specific sub-directory (e.g., ~/.dotfiles/bin)
    mkdir -p "$full_dest_path"

    # 2. Copy contents recursively
    #    "$source_path/." ensures we copy hidden files and contents
    #    into the newly created directory.
    cp -r "$source_path/." "$full_dest_path/"

    echo "  [OK] Copied to $full_dest_path"
}

# ==========================================
# Execution
# ==========================================

# Copy ../bin  ->  ~/.dotfiles/bin
sync_subdir "$BIN_SOURCE" "bin"

# Copy ./shell ->  ~/.dotfiles/shell
sync_subdir "$SHELL_SOURCE" "shell"

echo "----------------------------------------"
echo "Successfully synchronized all files to $DEST_ROOT"

