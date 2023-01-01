#!/bin/bash

set -eu

sudo dnf history > ~/.config/dotfiles/dnf.log

{
  cat ~/.bash_history && \
  sed 's/^[^;]*;//' ~/.zsh_history 
} | \
{
  rg 'pip\d? (un)?install|(un)?install -g|gem (un)?install' | \
    uniq \
    > ~/.config/dotfiles/tools.log
}

