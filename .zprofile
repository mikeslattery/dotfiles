if [ -x "$HOME/.local/bin/nvim" ] && [ -z "$EDITOR" ]; then
  export EDITOR="$HOME/.local/bin/nvim"
  export SUDO_EDITOR="$EDITOR"
fi


# Added by Toolbox App
export PATH="$PATH:/home/v747103/.local/share/JetBrains/Toolbox/scripts"

