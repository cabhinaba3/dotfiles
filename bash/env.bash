#!/usr/bin/env bash
# Shell environment and history tuning

export HISTSIZE=50000
export HISTFILESIZE=100000
export HISTCONTROL=ignoreboth
export HISTTIMEFORMAT="%Y-%m-%d %T "

if command -v nvim &>/dev/null; then
    export EDITOR="nvim"
    export VISUAL="nvim"
fi

export TERMINAL="alacritty"
