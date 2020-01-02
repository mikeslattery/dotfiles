#!/bin/bash

# Usage:
# git clone https://github.com/mikeslattery/dotfiles.git && dotfiles/bootstrap.sh

# Supports install of:
# tmux zsh vim git openssh
# optional: ack ag 7zip python2

# Requires: bash vim
# Best with: git

set -euo pipefile
set -x

dotfiles=~/src/dotfiles

#TODO: change bootstrap to:
# curl -sSfL https://raw.githubusercontent.com/mikeslattery/dotfiles/master/bootstrap.sh | /bin/bash
installDotfiles() {
    command -v git || {
        sudo apt install git-all
        #TODO: alias pkg depending on OS: fedora/rhel, Arch, debian/ubuntu, termux, server-only
        # yum, apt, pkg, pacman -S
    }

    [[ -d $dotfiles ]] || {
        mkdir -p $dotfiles
        git clone https://github.com/mikeslattery/dotfiles.git $dotfiles
    }
}

linkConfigs() {
    #TODO: figure out current directory
    dotlist='bin .bashrc .bash_logout .vimrc .config/i3 bin .bashrc .bash_logout .profile .selected_editor'
    #TODO: .urxvt
    #TODO: .i3/config
    mkdir -p ~/.{backup,config}
    for i in $dotlist; do
        #TODO: backup to this project as a subdirectory.  add that to gitignore
        [ -f ~/$i ] && [ ! -f ~/.backup/$i ] && mv ~/$i ~/.backup/$i
        rm -rf ~/$i
        ln -s $dotfiles/$i ~/$i
    done
}

hostLinks() {
    #TODO: if using msys2, func alias ln to mklink /j
    #mkdir /c/home
    #cmd /c "mklink /j C:\\home\\$USER $(cygpath -w ~)"
    #cmd /c "mklink /j C:\\tmp $(cygpath -w /tmp)"

    # Cygwin
    [[ ! -d /cygdrive/c ]] || [[ -d /Users ]] || {
        ln -s /cygdrive/c/Users /Users
        ln -s /cygdrive/c/Users/$USER/src ~/src
        ln -s /cygdrive/c/Users/$USER/Downloads ~/Downloads
    }

    #TODO: use uname for this
    ## msys64
    #[[ -d /msys64 ]] || {
    #    mklink /J C:\msys64\home\$USER\src C:\Users\$USER\src
    #    mklink /J C:\msys64\home\$USER\Downloads C:\Users\$USER\Downloads
    #    mklink /J C:\msys64\Users C:\Users
    #}

    # WSL
    [[ ! -d /mnt/c ]] || [[ -d /c ]] || {
        ln -s /mnt/c/Users/$USER/src ~/src
        sudo ln -s /mnt/c /c
        sudo mkdir /cygdrive
        sudo ln -s /mnt/c /cygdrive/c
        sudo ln -s /mnt/c/Users /Users
        ln -s /mnt/c/Users/$USER/Downloads ~/Downloads

        #TODO: better impl and move to .myprofile
        # Only works with a full path
        cygpath() { sed 's|^[cC]:|/mnt/c|; s|\\|/|g;' <<<"$1"; }
        # Only works with full paths under /mnt/c
        cygpathw() { sed -r 's|^/c\b|C:|; s|^/(mnt|cygdrive)/c\b|C:|; s|/|\\|g;' <<<"$1"; }
    }
}

setupVim() {
    mkdir -p ~/.vim/swap
    [ -d ~/.vim/bundle/vundle.vim ] || git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
    vim +PluginInstall +qall
}

main() {
    hostLinks
    installDotfiles
    linkConfigs

    chmod -w ~/bin/*
}

main "$@"

