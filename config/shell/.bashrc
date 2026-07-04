# ~/.bashrc: executed by bash(1) for interactive shells.

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# --- History ---
HISTFILE="$HOME/.bash_history"
HISTSIZE=10000
HISTFILESIZE=10000
# ignoreboth = ignore duplicate lines and lines starting with a space;
# erasedups = drop all previous duplicates of a command from the history.
HISTCONTROL=ignoreboth:erasedups
shopt -s histappend          # append rather than overwrite the history file
# Share history across concurrent sessions: after each command, append this
# session's new entries and re-read anything other sessions have added.
PROMPT_COMMAND="history -a; history -n; ${PROMPT_COMMAND:-}"

# --- Shell options ---
shopt -s autocd 2>/dev/null  # `cd` by typing a directory name (bash 4+)
shopt -s extglob             # richer (extended) globbing
shopt -s checkwinsize        # keep LINES/COLUMNS current after each command

# --- Completion ---
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

# --- Environment ---
# Load environment variables (PATH, etc.) BEFORE the prompt init below, so that
# tools installed under ~/.local/bin (e.g. starship) are discoverable by the
# `command -v` check even in a fresh login shell whose PATH doesn't yet include
# them (e.g. `wsl ~` from Windows Terminal).
if [ -f "$HOME/.dotfiles/shell/.exports" ]; then
    source "$HOME/.dotfiles/shell/.exports"
fi

# --- Prompt ---
# Use Starship (cross-shell prompt) when available; otherwise fall back to a
# simple built-in colored prompt.
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init bash)"
else
    PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
fi

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Load aliases
if [ -f "$HOME/.dotfiles/shell/.aliases" ]; then
    source "$HOME/.dotfiles/shell/.aliases"
fi

# UV shell completion (only if uv is installed). stderr is suppressed so a uv
# hiccup (e.g. a config key from a newer uv than the one installed) can never
# spam an error on every new shell.
if command -v uv >/dev/null 2>&1; then
    eval "$(uv generate-shell-completion bash 2>/dev/null)"
fi

unset ANTHROPIC_AUTH_TOKEN
unset ANTHROPIC_BASE_URL
