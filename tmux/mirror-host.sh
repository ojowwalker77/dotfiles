#!/bin/sh
# Host side of the tmux window mirror, driven over ssh by ~/.config/tmux/remote.sh
# on the Mac (install with `remote.sh install`). All windows live in the session
# "main"; each mirror attaches to a private session "_m<id>" holding only that
# window, so the window stays put while mirrors come and go.
S=main

ensure() { tmux has-session -t "=$S" 2>/dev/null || tmux new-session -d -s "$S" -c "$HOME"; }
path_of() { tmux display -p -t "$1" '#{pane_current_path}'; }

cmd=$1; shift
case $cmd in
  list)
    ensure
    tmux list-windows -t "=$S" -F '#{window_id}	#{window_name}' ;;
  attach)
    w=$1 m="_m${1#@}"
    tmux list-windows -a -F '#{window_id}' | grep -qxF "$w" || exit 3
    if ! tmux has-session -t "=$m" 2>/dev/null; then
      tmp=$(tmux new-session -d -P -F '#{window_id}' -s "$m")
      tmux link-window -s "$w" -t "=$m:"
      tmux kill-window -t "$tmp"
    fi
    exec tmux attach -t "=$m" \; set status off \; set destroy-unattached on ;;
  split)  tmux split-window "-$2" -t "$1" -c "$(path_of "$1")" ;;
  pane)   tmux select-pane "-$2" -t "$1" ;;
  resize) tmux resize-pane "-$2" -t "$1" 5 ;;
  kill)   tmux kill-pane -t "$1" ;;
  new)    ensure; tmux new-window -d -P -F '#{window_id}' -t "=$S:" -c "$(path_of "$1")" ;;
  rename) tmux rename-window -t "$1" "$2" ;;
  *)      echo "usage: mirror-host.sh list|attach|split|pane|resize|kill|new|rename" >&2; exit 2 ;;
esac
