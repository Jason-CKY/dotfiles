#!/usr/bin/env bash
# Sync Pi configuration to ~/.pi

set -euo pipefail

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
CONFIG_DIR="$SCRIPT_DIR/../config"

mkdir -p "$HOME/.pi"
cp -r "$CONFIG_DIR/pi/"* "$HOME/.pi/"
