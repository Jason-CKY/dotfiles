#!/usr/bin/env bash
# Nerd Font installation (JetBrainsMono)
#
# Installs the JetBrainsMono Nerd Font so the Starship prompt's powerline arrows
# and tool icons render. Idempotent throughout.
#
#   1. Linux: installs into the user font dir (~/.local/share/fonts) for Linux
#      apps. Skipped when fontconfig already reports the family.
#   2. WSL: Windows Terminal renders using a *Windows*-installed font, so the
#      Linux install alone leaves icons broken. When running under WSL this
#      script also installs the same TTFs into the Windows *per-user* fonts
#      store (no admin needed) and registers them via reg.exe. Best-effort: if
#      any interop step is unavailable it warns and prints manual instructions.

set -euo pipefail

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
# shellcheck source=scripts/lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

FONT_NAME="JetBrainsMono"                 # Nerd Fonts release asset name
FONT_FAMILY="JetBrainsMono Nerd Font"     # fontconfig family name
FONTS_DIR="$HOME/.local/share/fonts"
FONT_DEST="$FONTS_DIR/$FONT_NAME"
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${FONT_NAME}.zip"

# Download + extract the Nerd Font TTFs into "$1" (skips redundant downloads when
# the dir already has TTFs). Ensures curl's helpers are present first.
fetch_ttfs_into() {
    local dest="$1"
    # Already populated? Reuse it.
    if compgen -G "$dest/*.ttf" >/dev/null 2>&1; then
        return 0
    fi
    install_if_missing unzip
    mkdir -p "$dest"
    local tmp
    tmp="$(mktemp -d)"
    # shellcheck disable=SC2064  # expand $tmp now, not at trap time
    trap "rm -rf '$tmp'" RETURN
    if ! curl -fsSL "$FONT_URL" -o "$tmp/$FONT_NAME.zip"; then
        echo "Error: failed to download $FONT_URL" >&2
        return 1
    fi
    # Extract only the .ttf files (skip licenses/readmes).
    unzip -q -o "$tmp/$FONT_NAME.zip" '*.ttf' -d "$dest"
}

# --- 1. Linux font install ---------------------------------------------------
# Capture to a here-string first: piping `fc-list | grep -q` would let grep close
# the pipe early, and under `set -o pipefail` fc-list's SIGPIPE exit would make
# the check spuriously report "not found".
install_font_linux() {
    local font_list
    font_list="$(fc-list 2>/dev/null || true)"
    if grep -qi "$FONT_FAMILY" <<<"$font_list"; then
        echo "$FONT_FAMILY already installed for Linux. Skipping."
        return 0
    fi

    install_if_missing fontconfig
    echo "Installing $FONT_FAMILY for Linux..."
    fetch_ttfs_into "$FONT_DEST"
    fc-cache -f "$FONTS_DIR" >/dev/null 2>&1
    echo "$FONT_FAMILY installed to $FONT_DEST."
}

# --- 2. Windows (WSL) font install -------------------------------------------
# Install the standard JetBrainsMono Nerd Font family into the Windows per-user
# fonts store and register it, so Windows Terminal can select it. Idempotent:
# skips when the family is already registered under HKCU.
install_font_windows() {
    command -v reg.exe >/dev/null 2>&1 || {
        echo "reg.exe not available; cannot auto-install the font on Windows." >&2
        return 1
    }
    command -v wslpath >/dev/null 2>&1 || return 1

    local regkey='HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Fonts'
    # Already registered? Nothing to do. Capture to a here-string first: piping
    # `reg.exe | grep -q` lets grep close the pipe early, and under `pipefail`
    # reg.exe's SIGPIPE exit would make the check spuriously report "not found".
    local reg_dump
    reg_dump="$(reg.exe query "$regkey" 2>/dev/null || true)"
    if grep -qi "${FONT_NAME}NerdFont" <<<"$reg_dump"; then
        echo "$FONT_FAMILY already installed for Windows. Skipping."
        return 0
    fi

    # Resolve the Windows user profile (e.g. C:\Users\name) from the registry.
    local userprofile_dos win_profile win_fonts win_fonts_dos
    userprofile_dos="$(reg.exe query 'HKCU\Volatile Environment' /v USERPROFILE 2>/dev/null \
        | tr -d '\r' | awk '/USERPROFILE/ {print $NF}')"
    [ -n "$userprofile_dos" ] || { echo "Could not resolve Windows USERPROFILE." >&2; return 1; }

    win_fonts_dos="$userprofile_dos\\AppData\\Local\\Microsoft\\Windows\\Fonts"
    win_profile="$(wslpath -u "$userprofile_dos" 2>/dev/null)" || return 1
    win_fonts="$win_profile/AppData/Local/Microsoft/Windows/Fonts"
    mkdir -p "$win_fonts" || return 1

    # Make sure we have the TTFs locally (the Linux step may have been skipped).
    fetch_ttfs_into "$FONT_DEST" || return 1

    echo "Installing $FONT_FAMILY into the Windows per-user fonts store..."
    local installed=0 f base name
    # Only the standard (non-NL) NerdFont family — the one Starship expects.
    for f in "$FONT_DEST/${FONT_NAME}NerdFont"*.ttf; do
        [ -e "$f" ] || continue
        base="$(basename "$f")"
        cp -f "$f" "$win_fonts/$base"
        # Registry value name is a cosmetic label; Windows reads the real family
        # name from the file. Data is the full Windows path to the TTF.
        name="${base%.ttf} (TrueType)"
        reg.exe add "$regkey" /v "$name" /t REG_SZ /d "$win_fonts_dos\\$base" /f >/dev/null 2>&1
        installed=$((installed + 1))
    done

    [ "$installed" -gt 0 ] || { echo "No standard $FONT_FAMILY TTFs found to install." >&2; return 1; }
    echo "Installed & registered $installed $FONT_FAMILY files on Windows."
    cat <<EOF

NOTE (WSL): the font is now installed on Windows. To see the icons:
  1. Fully close Windows Terminal (all windows) and reopen it so it picks up
     the newly installed font.
  2. Settings -> your profile (or Defaults) -> Appearance -> Font face ->
     "$FONT_FAMILY Mono" (or "$FONT_FAMILY").
EOF
}

install_font_linux

if grep -qi microsoft /proc/version 2>/dev/null; then
    install_font_windows || echo "Warning: Windows-side font install failed; set the font manually." >&2
fi
