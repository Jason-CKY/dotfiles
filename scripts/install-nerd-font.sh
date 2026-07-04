#!/usr/bin/env bash
# Nerd Font installation (JetBrainsMono)
#
# Installs the JetBrainsMono Nerd Font into the user font directory so the
# Starship prompt's powerline arrows and tool icons render. Idempotent: skips
# if the font is already registered with fontconfig.
#
# NOTE (WSL): this installs the font for *Linux* apps only. If you use Windows
# Terminal, you must also install the font on the Windows side and select it in
# your profile (the script prints instructions when it detects WSL).

set -euo pipefail

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
# shellcheck source=scripts/lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

FONT_NAME="JetBrainsMono"                 # Nerd Fonts release asset name
FONT_FAMILY="JetBrainsMono Nerd Font"     # fontconfig family name
FONTS_DIR="$HOME/.local/share/fonts"
FONT_DEST="$FONTS_DIR/$FONT_NAME"
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${FONT_NAME}.zip"

# Idempotency: already known to fontconfig? Nothing to do.
# Capture to a here-string first: piping `fc-list | grep -q` would let grep close
# the pipe early, and under `set -o pipefail` fc-list's SIGPIPE exit would make
# the check spuriously report "not found".
FONT_LIST="$(fc-list 2>/dev/null || true)"
if grep -qi "$FONT_FAMILY" <<<"$FONT_LIST"; then
    echo "$FONT_FAMILY already installed. Skipping."
    exit 0
fi

# Ensure the tools we need are present.
install_if_missing fontconfig
install_if_missing unzip

echo "Installing $FONT_FAMILY..."
mkdir -p "$FONT_DEST"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

if ! curl -fsSL "$FONT_URL" -o "$TMP_DIR/$FONT_NAME.zip"; then
    echo "Error: failed to download $FONT_URL" >&2
    exit 1
fi

# Extract only the .ttf files (skip licenses/readmes), then refresh the cache.
unzip -q -o "$TMP_DIR/$FONT_NAME.zip" '*.ttf' -d "$FONT_DEST"
fc-cache -f "$FONTS_DIR" >/dev/null 2>&1
echo "$FONT_FAMILY installed to $FONT_DEST."

# On WSL the Linux font install does not affect Windows Terminal, which renders
# using a Windows-installed font. Point the user at the manual step.
if grep -qi microsoft /proc/version 2>/dev/null; then
    cat <<EOF

NOTE (WSL detected): the font was installed for Linux apps only. For Windows
Terminal you must also install it on the Windows side:
  1. Download: $FONT_URL
  2. Unzip, select the .ttf files, right-click -> Install
  3. Windows Terminal -> Settings -> your profile -> Appearance ->
     Font face -> "$FONT_FAMILY"
EOF
fi
