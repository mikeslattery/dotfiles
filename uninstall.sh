#!/bin/sh

# Uninstall of dotfiles.

# Unlinks files.
# Copy files from project to home
# Copy backup files.

# Usage: ~/src/dotfiles/uninstall.sh

set -eu

echo "Uninstall dotfiles..."
echo ''

cd "$(dirname "$0")"

log() {
  echo "+ $*"
  "$@"
}

git ls-files | grep -vxFf .dotignore | grep -v '^etc/' | xargs -d"\n" -tI{} cp -a "$PWD/{}" "$HOME/{}"
log cp -av "backup/" "$HOME/"

echo ''
find backup -type f
echo 'Hit enter to delete above backup files: '
read -r
log rm -rf backup/

echo ''
echo 'Complete.'

