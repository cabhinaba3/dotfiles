#!/usr/bin/env bash
# Third-party tool integrations (FZF, Starship prompt)

# FZF Nord theme and finder command
if command -v fzf &>/dev/null; then
    export FZF_DEFAULT_OPTS=" \
    --color=fg:#D8DEE9,bg:#2E3440,hl:#81A1C1 \
    --color=fg+:#ECEFF4,bg+:#3B4252,hl+:#81A1C1 \
    --color=info:#EBCB8B,prompt:#A3BE8C,pointer:#B48EAD \
    --color=marker:#B48EAD,spinner:#EBCB8B,header:#4C566A"

    if command -v fd &>/dev/null; then
        export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
    elif command -v fdfind &>/dev/null; then
        export FZF_DEFAULT_COMMAND='fdfind --type f --hidden --exclude .git'
    fi

    [ -f ~/.fzf.bash ] && source ~/.fzf.bash
fi

# Starship Prompt
if command -v starship &>/dev/null; then
    eval "$(starship init bash)"
fi
