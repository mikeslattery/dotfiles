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

git ls-files | grep -vxf .dotignore | xargs -d"\n" -tI{} cp -a --remove-destination "$PWD/{}" "$HOME/{}"

echo ''
echo 'Complete.'

