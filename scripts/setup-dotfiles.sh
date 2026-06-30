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

# npm configuration
cp $CONFIG_DIR/npm/.npmrc $HOME/.npmrc

# Bun configuration
cp $CONFIG_DIR/bun/.bunfig.toml $HOME/.bunfig.toml

# UV configuration
mkdir -p $HOME/.config/uv
cp $CONFIG_DIR/uv/uv.toml $HOME/.config/uv/uv.toml

# Claude configuration
mkdir -p $HOME/.claude
cp -r $CONFIG_DIR/claude/* $HOME/.claude/

# OpenCode configuration
mkdir -p $HOME/.config/opencode
cp -r $CONFIG_DIR/opencode/* $HOME/.config/opencode/

# Share Claude skills with Codex (~/.agents/skills -> ~/.claude/skills)
mkdir -p "$HOME/.agents"
ln -sfn "$HOME/.claude/skills" "$HOME/.agents/skills"
