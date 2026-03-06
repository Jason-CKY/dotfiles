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

# Claude configuration
mkdir -p $HOME/.claude
cp -r $CONFIG_DIR/claude/* $HOME/.claude/

# OpenCode configuration - symlink Claude Code commands and skills
mkdir -p "$HOME/.config/opencode/commands"
mkdir -p "$HOME/.config/opencode/skills"
cp -r $CONFIG_DIR/opencode/* $HOME/.config/opencode/

