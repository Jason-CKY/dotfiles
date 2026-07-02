#!/usr/bin/env bash
# Codex CLI Installation (Idempotent)

set -euo pipefail

if command -v codex &> /dev/null; then
    echo "Codex already installed ($(codex --version 2>/dev/null)). Skipping."
else
    echo "Installing Codex CLI via official installer..."
    curl -fsSL https://chatgpt.com/codex/install.sh | sh
fi

echo "Codex installation complete."
