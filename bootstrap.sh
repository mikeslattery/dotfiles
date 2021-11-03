#!/bin/sh

# Initial install of dotfiles.

# Creates symlinks from home files to dotfiles.
# Idempotent.
# Meant only to be called by download.sh,
# but may also be called if files missing.
# Requires: git, gnu cp

# Manual Usage: ~/src/dotfiles/bootstrap.sh

set -eu

echo "Installing dotfiles..."
echo ''

cd "$(dirname "$0")"

mkdir -p backup

log() {
  echo "+ $*"
  "$@"
}

files() { git ls-files | grep -vxf .dotignore; }

files | xargs dirname | sort -u | xargs -r -t -I{} mkdir -p "$HOME"/{}
files | xargs -r -I{} -t cp -s -a "$PWD"/{} ~/{}

echo ''
echo "To install new file: dotfile .config/newfile"

