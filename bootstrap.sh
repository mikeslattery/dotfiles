#!/bin/bash

# Usage:
# git clone https://github.com/mikeslattery/dotfiles.git && dotfiles/bootstrap.sh

set -eux

#TODO: figure out current directory
dotfiles=~/src/dotfiles
dotlist='bin .bashrc .bash_logout .vimrc .config/i3 bin .bashrc .bash_logout .profile .selected_editor'
#TODO: .urxvt
mkdir -p ~/.backup
mkdir -p ~/.config
for i in $dotlist; do
    [ -f ~/$i ] && [ ! -f ~/.backup/$i ] && mv ~/$i ~/.backup/$i
    rm -rf ~/$i
    ln -s $dotfiles/$i ~/$i
done
unset dotlist

mkdir -p ~/.vim/swap
[ -d ~/.vim/bundle/vundle.vim ] || git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
vim +PluginInstall +qall

