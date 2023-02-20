if [ -x "$HOME/.local/bin/nvim" ] && [ -z "$EDITOR" ]; then
  export EDITOR="$HOME/.local/bin/nvim"
  export SUDO_EDITOR="$EDITOR"
fi
