
_all_panes() {
  tmux list-panes -a -F '#{pane_id}' | xargs -n1 tmux capture-pane -p -S - -J -N "$@" -t
}

# Usage: 11 [<index>|-<offset>] [-C] [-e] [-J] [-P]
11() {
  local phistcmd="${1:-$(( HISTCMD - 1 ))}"
  [[ "$#" -eq 0 ]] || shift
  if [[ "$phistcmd" -lt 0 ]]; then
    phistcmd=$(( HISTCMD + phistcmd ))
  fi
  local chistcmd=$(( phistcmd + 1 ))

  _all_panes "$@" | sed -n "/^!${phistcmd} /,/^!${chistcmd} /{//!p;}"
}

11fz() {
  (
    histcmd="$(_all_panes | sed -nr 's/^!([0-9]+ ).*\xEE\x82\xB0.*\xEE\x82\xB0/\1/p;' | sort -ru | fzf --ansi --preview 'source ~/.config/zsh/custom/11.zsh; 11 {+1} -e' | sed -nr 's/^([0-9]+) .*$/\1/p;')"
    [[ -n "$line" ]] || 11 $histcmd "$@"
  )
}

