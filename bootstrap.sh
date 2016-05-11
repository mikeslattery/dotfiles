#!/bin/bash

# Usage:
# git clone https://github.com/mikeslattery/dotfiles.git && dotfiles/bootstrap.sh

set -eux

dotfiles=~/src/dotfiles
dotlist='bin .bashrc .bash_logout .vimrc .vim .config/i3 bin .bashrc .bash_logout .profile .selected_editor .urxvt'
for i in $dotlist; do
    #mv ~/$i $dotfiles/$i
    ln -s $dotfiles/$i ~/$i
done

unset dotlist

