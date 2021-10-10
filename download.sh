#!/bin/sh

# Downloads and bootstraps the dotfiles

# Usage:
# curl https://raw.githubusercontent.com/mikeslattery/dotfiles/master/download.sh | /bin/sh

set -eu

mkdir -p ~/src
mkdir ~/src/dotfiles
git clone https://github.com/mikeslattery/dotfiles.git ~/src/dotfiles

~/src/dotfiles/bootstrap.sh

