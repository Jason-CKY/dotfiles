#!/bin/bash

# --- 1. Aesthetic Configuration ---
# ANSI Colors
RESET="\033[0m"
BOLD="\033[1m"
CYAN="\033[36m"
BLUE="\033[34m"
MAGENTA="\033[35m"
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
GRAY="\033[90m"

# Icons (Standard Unicode, works in most modern terminals)
ICON_MODEL="🤖"
ICON_DIR="📂"
ICON_GIT="🌿"
ICON_REMOTE="🔗"

# --- 2. Process Input (JSON) ---
# Read the JSON input from stdin
input=$(cat)

# Extract fields with jq
MODEL=$(echo "$input" | jq -r '.model.display_name // "Claude"')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)

# --- 3. Build Context Progress Bar ---
BAR_WIDTH=10
FILLED=$((PCT * BAR_WIDTH / 100))
((FILLED<0)) && FILLED=0
((FILLED>BAR_WIDTH)) && FILLED=$BAR_WIDTH
EMPTY=$((BAR_WIDTH - FILLED))

FULL_BLOCKS="▓▓▓▓▓▓▓▓▓▓"
EMPTY_BLOCKS="░░░░░░░░░░"

BAR_STR="${FULL_BLOCKS:0:$FILLED}${EMPTY_BLOCKS:0:$EMPTY}"

# Determine Bar Color based on usage
if [ "$PCT" -lt 50 ]; then
    BAR_COLOR="$GREEN"
elif [ "$PCT" -lt 80 ]; then
    BAR_COLOR="$YELLOW"
else
    BAR_COLOR="$RED"
fi

# --- 4. System Information (CWD & Git) ---

# Get Current Working Directory (replace $HOME with ~)
CWD="${PWD/#$HOME/\~}"

# Git Info
GIT_INFO=""
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    # Get Branch Name
    BRANCH=$(git rev-parse --abbrev-ref HEAD)
    
    # Get Remote URL
    REMOTE_URL=$(git config --get remote.origin.url)
    
    # Clean Remote URL for aesthetics (remove .git, remove protocol)
    # Transforms 'git@github.com:user/repo.git' -> 'github.com/user/repo'
    CLEAN_REMOTE=$(echo "$REMOTE_URL" | sed -E 's/^(https:\/\/|git@)//' | sed 's/\.git$//' | sed 's/:/\//')
    
    # Format Git Section
    GIT_INFO=" ${GRAY}|${RESET} ${MAGENTA}${ICON_GIT} ${BRANCH}${RESET} ${GRAY}(${CLEAN_REMOTE})${RESET}"
fi

# --- 5. Final Output ---
# Layout: [Model] [Bar %] | [Dir] [Git]

echo -e "${BOLD}${CYAN}[${ICON_MODEL} ${MODEL}]${RESET} ${BAR_COLOR}${BAR_STR} ${PCT}%${RESET} ${GRAY}|${RESET} ${BLUE}${ICON_DIR} ${CWD}${RESET}${GIT_INFO}"