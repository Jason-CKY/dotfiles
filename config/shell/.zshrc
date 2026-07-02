# ~/.zshrc: executed by zsh(1) for interactive shells.

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# --- History ---
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt APPEND_HISTORY        # append rather than overwrite the history file
setopt SHARE_HISTORY         # share history across concurrent sessions
setopt HIST_IGNORE_ALL_DUPS  # don't record duplicate commands
setopt HIST_IGNORE_SPACE     # don't record commands starting with a space

# --- Shell options ---
setopt AUTO_CD               # `cd` by typing a directory name
setopt EXTENDED_GLOB         # richer globbing
setopt INTERACTIVE_COMMENTS  # allow `#` comments in interactive shells

# --- Completion ---
autoload -Uz compinit && compinit

# --- Prompt ---
autoload -Uz colors && colors
PROMPT='%F{green}%n@%m%f:%F{blue}%~%f %# '

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

# Load environment variables
if [ -f "$HOME/.dotfiles/shell/.exports" ]; then
    source "$HOME/.dotfiles/shell/.exports"
fi

# UV shell completion (only if uv is installed). stderr is suppressed so a uv
# hiccup (e.g. a config key from a newer uv than the one installed) can never
# spam an error on every new shell.
if command -v uv >/dev/null 2>&1; then
    eval "$(uv generate-shell-completion zsh 2>/dev/null)"
fi

unset ANTHROPIC_AUTH_TOKEN
unset ANTHROPIC_BASE_URL
