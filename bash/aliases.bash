#!/usr/bin/env bash
# Modern CLI and workflow aliases

# Modern file listing with eza
if command -v eza &>/dev/null; then
    alias ls='eza --icons --color=auto'
    alias ll='eza -la --icons --git --group-directories-first'
    alias lt='eza --tree --level=2 --icons'
else
    alias ls='ls --color=auto'
    alias ll='ls -la'
fi

# Modern cat with bat
if command -v bat &>/dev/null; then
    alias cat='bat --theme="Nord"'
elif command -v batcat &>/dev/null; then
    alias cat='batcat --theme="Nord"'
fi

# Modern grep with ripgrep
if command -v rg &>/dev/null; then
    alias grep='rg'
else
    alias grep='grep --color=auto'
fi

# Modern find with fd
if command -v fd &>/dev/null; then
    alias find='fd'
elif command -v fdfind &>/dev/null; then
    alias find='fdfind'
fi

# Modern diff with delta
if command -v delta &>/dev/null; then
    alias diff='delta'
fi

# Standard system resource monitoring (safe POSIX defaults)
if command -v htop &>/dev/null; then
    alias top='htop'
fi

alias du='du -sh'
alias df='df -h'

# On-demand system info
if command -v fastfetch &>/dev/null; then
    alias sysinfo='fastfetch'
fi

# Git shortcuts
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate -20'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'

# Directory navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
