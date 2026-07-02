#!/usr/bin/env bash
# Dotfiles Symlinking

set -euo pipefail

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
CONFIG_DIR="$SCRIPT_DIR/../config"
echo "Creating configuration files for dotfiles..."

# Shell configurations (zsh)
cp $CONFIG_DIR/shell/.zshrc $HOME/.zshrc
cp $SCRIPT_DIR/../shell/.aliases $HOME/.aliases

# Starship prompt config (shared by bash + zsh)
mkdir -p "$HOME/.config"
cp "$CONFIG_DIR/starship/starship.toml" "$HOME/.config/starship.toml"

# The managed .zshrc initializes Starship for zsh. For bash we append the init
# to ~/.bashrc idempotently (guarded by a grep) so we never clobber the user's
# existing bash config or add duplicate lines on repeated runs.
BASHRC="$HOME/.bashrc"
if ! { [ -f "$BASHRC" ] && grep -q "starship init bash" "$BASHRC"; }; then
    {
        echo ''
        echo '# Initialize Starship prompt (added by dotfiles)'
        echo 'command -v starship >/dev/null 2>&1 && eval "$(starship init bash)"'
    } >> "$BASHRC"
fi

# npm configuration
cp $CONFIG_DIR/npm/.npmrc $HOME/.npmrc

# Bun configuration
cp $CONFIG_DIR/bun/.bunfig.toml $HOME/.bunfig.toml

# UV configuration
mkdir -p $HOME/.config/uv
cp $CONFIG_DIR/uv/uv.toml $HOME/.config/uv/uv.toml

# Claude configuration. The Claude skills dir is the single canonical skills set
# shared by every agent (OpenCode, Pi, Codex) via symlinks. Wipe it before
# copying so any skill no longer present in this repo is removed (exact mirror),
# rather than left behind from a previous install.
mkdir -p "$HOME/.claude"
rm -rf "$HOME/.claude/skills"
cp -r "$CONFIG_DIR"/claude/* "$HOME/.claude/"

# OpenCode configuration; its skills are a symlink to the canonical Claude skills.
mkdir -p "$HOME/.config/opencode"
cp -r "$CONFIG_DIR"/opencode/* "$HOME/.config/opencode/"
rm -rf "$HOME/.config/opencode/skills"
ln -sfn "$HOME/.claude/skills" "$HOME/.config/opencode/skills"

# Codex reads user-level skills from ~/.agents/skills; point it at the same set.
mkdir -p "$HOME/.agents"
rm -rf "$HOME/.agents/skills"
ln -sfn "$HOME/.claude/skills" "$HOME/.agents/skills"
