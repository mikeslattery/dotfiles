#!/bin/bash

set -eu

{
    sudo dnf4 history
    sudo dnf5 history list | cat
} | grep -v upgrade > ~/.config/dotfiles/dnf.log

{
  cat ~/.bash_history
  sed 's/^[^;]*;//' ~/.zsh_history
} | \
{
    rg 'pip (un)?install|npm (un)install -g|^gem (un)?install' | \
    uniq \
    > ~/.config/dotfiles/tools.log
}

brew list --installed-on-request > ~/.config/dotfiles/brew.log

flatpak list --user --system --app > ~/.config/dotfiles/flatpak.log

# Generate script

{
    echo '#!/bin/bash'
    echo
    echo '# Brew for Linux'
    brew list --installed-on-request | sed 's/^/brew install /'

    echo
    echo '# Flatpak'
    flatpak list --app --system | \
        awk -F'\t' '{print "flatpak install --system", "flathub", $2}' \
    flatpak list --app --user | \
        awk -F'\t' '{print "flatpak install --user", "flathub", $2}' \

    echo
    echo '# Fedora dnf'
    echo '# dnf4'
    sudo dnf4 history | grep -v upgrade | awk -F'|' '{print "sudo dnf" $2}'
    echo '# dnf5'
    sudo dnf5 history list | sed -E '
        1d; /upgrade/ d;
        s/^ *[0-9]+ dnf (.*) +20[2-9][0-9]-.*$/sudo dnf \1/; s/ *$//;'

    # pip list --user --format json | jq -r '.[].name' | sed 's/^/pip /'

    echo
    echo '# tool packages.  npm, pip, gem.'

    cat ~/.config/dotfiles/tools.log

} > ~/.config/dotfiles/install-all.sh

chmod +x ~/.config/dotfiles/install-all.sh

