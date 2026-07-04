#!/usr/bin/env bash
# Sync Pi configuration to ~/.pi

set -euo pipefail

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
CONFIG_DIR="$SCRIPT_DIR/../config"

mkdir -p "$HOME/.pi"
cp -r "$CONFIG_DIR/pi/"* "$HOME/.pi/"

# Pi shares the canonical Claude skills via a symlink (matching OpenCode and
# Codex). ~/.claude/skills is created by setup-dotfiles.sh, which runs before
# this script in install.sh; the symlink resolves once that dir exists.
mkdir -p "$HOME/.pi/agent"
rm -rf "$HOME/.pi/agent/skills"
ln -sfn "$HOME/.claude/skills" "$HOME/.pi/agent/skills"

# Ensure Pi's extensions directory exists so `herdr integration install pi`
# (run later by install-herdr.sh) can drop in its agent-state extension.
# Herdr aborts the pi integration with "pi extension directory not found" if
# this dir is missing, even when Pi itself is installed.
mkdir -p "$HOME/.pi/agent/extensions"
