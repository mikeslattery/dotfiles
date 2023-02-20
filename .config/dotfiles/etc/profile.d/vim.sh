
for f in /usr/bin/vim /usr/bin/vimx /usr/bin/vi ~/.local/bin/nvim /usr/bin/nvim; do
  if [[ -x "$f" ]]; then
    export EDITOR="$f"
  fi
done

