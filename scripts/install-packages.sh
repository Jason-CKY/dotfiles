#!/usr/bin/env bash
# System Package Management

set -euo pipefail

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
source "$SCRIPT_DIR/lib/common.sh"

# Update package lists if needed
update_if_needed nano

# Install packages
install_if_missing nano
install_if_missing openssl
install_if_missing jq
