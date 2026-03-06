#!/usr/bin/env bash
# Dotfiles Symlinking

set -euo pipefail

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
CONFIG_DIR="$SCRIPT_DIR/../config"
echo "Creating configuration files for dotfiles..."

# Shell configurations
cp $CONFIG_DIR/shell/.bashrc $HOME/.bashrc
cp $CONFIG_DIR/shell/.profile $HOME/.profile
cp $SCRIPT_DIR/../shell/.aliases $HOME/.aliases

# Git configuration
cp $CONFIG_DIR/git/.gitconfig $HOME/.gitconfig

# OpenCode configuration - remove existing and copy fresh to ensure updates are applied
rm -rf "$HOME/.config/opencode"
mkdir -p "$HOME/.config/opencode"
cp -r $CONFIG_DIR/opencode/* $HOME/.config/opencode/

