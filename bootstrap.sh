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

for i in $(git ls-files | grep -vxFf .dotignore | grep -v '^etc/' ); do
  # if it's already a symlink, do nothing
  if [ ! -L "$HOME/$i" ]; then
    # Backup pre-existing files
    if [ -f "$HOME/$i" ] && [ ! -f "backup/$i" ] && ! cmp --silent "$HOME/$i" "$i"; then
      mkdir -p "$(dirname "backup/$i")"
      log mv "$HOME/$i" "backup/$i"
    fi

    # create the symlink
    mkdir -p "$(dirname "$HOME/$i")"
    log ln -sfn "$i" "$HOME/$i"
  fi
done

echo ''
echo "You can find file backups in $PWD/backup"
echo "To install new file: dotfile .config/newfile"

