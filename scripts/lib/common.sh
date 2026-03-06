#!/usr/bin/env bash
# Common utility functions for dotfiles setup scripts

# Determine if we need sudo
SUDO=""
if [ "$(id -u)" -ne 0 ]; then
    SUDO="sudo"
fi

# Check if a package is installed (Debian/Ubuntu)
# Usage: pkg_installed <package-name>
pkg_installed() {
    dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q "ok installed"
}

# Check if a command is available
# Usage: cmd_available <command-name>
cmd_available() {
    command -v "$1" &> /dev/null
}

# Get installed version of a command that supports --version
# Usage: get_version <command-name>
# Returns the version string or empty if command not found
get_version() {
    "$1" --version 2>/dev/null | head -n1 | awk '{print $NF}'
}

# Install a package if not already installed
# Usage: install_if_missing <package-name>
install_if_missing() {
    local pkg="$1"
    if ! pkg_installed "$pkg"; then
        echo "Installing $pkg..."
        $SUDO apt-get install -y "$pkg"
    else
        echo "$pkg is already installed."
    fi
}

# Update package lists if needed
# Usage: update_if_needed <package-list>
update_if_needed() {
    local need_update=false
    for pkg in "$@"; do
        if ! pkg_installed "$pkg"; then
            need_update=true
            break
        fi
    done

    if [ "$need_update" = true ]; then
        echo "Updating package lists..."
        $SUDO apt-get update
    fi
}

# Install a command if not available
# Usage: install_cmd_if_missing <package-name> <command-name>
install_cmd_if_missing() {
    local pkg="$1"
    local cmd="$2"

    if ! cmd_available "$cmd"; then
        echo "Installing $pkg (provides $cmd)..."
        $SUDO apt-get install -y "$pkg"
    else
        echo "$cmd is already available."
    fi
}

# Version comparison helper
# Usage: version_compare <installed> <desired>
# Returns 0 if versions match, 1 if they differ
version_matches() {
    local installed="$1"
    local desired="$2"
    [ "$installed" = "$desired" ]
}

# Install binary from URL if version mismatch
# Usage: install_binary_if_needed <binary-name> <url> <expected-version> <version-command>
install_binary_if_needed() {
    local binary_name="$1"
    local download_url="$2"
    local expected_version="$3"
    local version_cmd="${4:-$binary_name --version}"

    if ! cmd_available "$binary_name"; then
        echo "$binary_name is not installed."
        return 0  # Needs install
    fi

    local current_version
    current_version=$(eval "$version_cmd" 2>/dev/null | awk '{print $NF}')

    if [ "$current_version" != "$expected_version" ]; then
        echo "Version mismatch for $binary_name."
        echo "  Current: $current_version"
        echo "  Desired: $expected_version"
        return 0  # Needs install
    fi

    echo "$binary_name is already at the correct version ($expected_version)."
    return 1  # No install needed
}

# Download file to temp if not already cached
# Usage: download_if_needed <url> <temp-filename>
# Returns the full path to the cached file
download_if_needed() {
    local url="$1"
    local filename="$2"
    local temp_path="/tmp/$filename"

    if [ -f "$temp_path" ]; then
        echo "$temp_path"
        return
    fi

    echo "Downloading $filename..."
    if wget -q "$url" -O "$temp_path"; then
        echo "$temp_path"
    else
        echo "Error: Failed to download $url" >&2
        return 1
    fi
}

# Extract archive to directory
# Usage: extract_archive <archive-path> <destination-dir>
extract_archive() {
    local archive="$1"
    local dest_dir="$2"

    case "$archive" in
        *.tar.gz)
            tar -C "$dest_dir" -xzf "$archive"
            ;;
        *.zip)
            unzip -q "$archive" -d "$dest_dir"
            ;;
        *)
            echo "Warning: Unknown archive format: $archive" >&2
            return 1
            ;;
    esac
}
