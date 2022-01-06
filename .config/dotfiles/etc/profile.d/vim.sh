
for f in /usr/bin/vim /usr/bin/vimx /usr/bin/vi; do
  if [[ -x "$f" ]]; then
    export EDITOR="$f"
  fi
done

