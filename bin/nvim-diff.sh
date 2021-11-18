#!/bin/bash
#shellcheck disable=SC2016

cd /tmp || exit 1

touch /tmp/.vimrc
# Use this one only if you have an empty init.vim
 vim                                            +'redir! > vs.txt | set all | redir END | qa'
#vim  -u /tmp/.vimrc                            +'redir! > vs.txt | set all | redir END | qa'
#vim  --clean +'source $VIMRUNTIME/defaults.vim | redir! > vs.txt | set all | redir END | qa'
 nvim --clean                                   +'set loadplugins | redir! > ns.txt | set all | redir END | qa'
#nvim                                           +'redir! > ns.txt | set all | redir END | qa'

cleanit() {
  cat "$1" | sed -r 's/^ +//; /^.{17} / { s/ +/\n/g; };' | sed -r 's/^no(.*)/\1 off/;' | sort
}

diff -u0 <(cleanit vs.txt) <(cleanit ns.txt) > diff.txt

cat diff.txt | sed '/^@@/d' | vim - -R

