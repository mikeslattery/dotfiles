#!/bin/bash
#shellcheck disable=SC2016

# Show defaults differences between vim and nvim
# except those handled by my .vimrc.

# This is used to maintain .vimrc
# to set vim defaults similar to nvim defaults.

# fedora
vim() { vimx "$@"; }

cleanit() {
  cat "$1" | sed -r '
    # no=off
    s/^no(.*)/\1=off/;
    s|^ *||;

    # path differences
    s|/tmp/\.mount_nvim[^/]*/|/|g;
    s|/vimswap|/swap|;
    s|/vimundo|/undo|;

    # Naming differences
    s|^shada|viminfo|;

    # option values not in both
    /^cpoptions=/ { s/_//; };
    /^diffopt=/ { s/,closeoff//; };
    /^display=/ { s/,msgsep//; };
    /^sessionoptions=/ { s/,terminal//; };

    # incomparable differences
    /^mouse=/ { s/=a/=/; };
    /^scroll=/ d;
    /^cdpath=/ d;

    # do not care
    /^highlight=/ d;
    /^printexpr=/ d;
    /^helpfile=/ d;
    ' | sort
}

# only include options that exist in both
cleaned() {
  cleanit "$1" | grep -f <(cleanit "$2" | sed -r 's/=.*$//; /^$/d; s/^/^/; s/$/\\b/;')
  # this isn't efficient, but who care?
}

vim  -u NONE -c 'source ~/.vimrc' +'redir! > /tmp/vs.txt | silent set! all | redir END | qa'
nvim -u NONE                      +'redir! > /tmp/ns.txt | silent set! all | redir END | qa'

diff -u0 <(cleaned /tmp/vs.txt /tmp/ns.txt) <(cleaned /tmp/ns.txt /tmp/vs.txt) | \
  sed '/^@@/d' | \
  nvim --clean - -R '+set ft=diff'

rm -f /tmp/vs.txt /tmp/ns.txt

