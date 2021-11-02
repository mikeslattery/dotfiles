#!/bin/sh

# Initial install of dotfiles.

# Creates symlinks from home files to dotfiles
# Creates backups for pre-existing files in home
# Idempotent
# Meant only to be called by download.sh,
# but may also be called if files missing

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

git ls-files | grep -vxf .dotignore | xargs -r -I{} -t cp -s -a --backup "$PWD"/{} ~/{}

echo 'Backups:'
find ~ -name '*~'

echo ''
echo "You can find file backups in $PWD/backup"
echo "To install new file: dotfile .config/newfile"

