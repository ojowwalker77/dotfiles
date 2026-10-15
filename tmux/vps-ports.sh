#!/bin/bash
# Auto-forwards dev ports (3000-9999) listening on the VPS to localhost on this Mac.
# Host from ~/.config/tmux/remote-hosts (first line), key from remote-key.
#   vps-ports.sh run      loop: sync every 3s (used by launchd)
#   vps-ports.sh list     show forwarded ports
dir="$HOME/.config/tmux"
host=$(grep -Ev '^[[:space:]]*(#|$)' "$dir/remote-hosts" | head -1)
key=$(cat "$dir/remote-key" 2> /dev/null)
cp="$HOME/.ssh/cm-ports-%C"
ssh_() { ssh -i "$key" -o BatchMode=yes -o ControlMaster=auto -o ControlPath="$cp" -o ControlPersist=60s \
  -o ServerAliveInterval=5 -o ServerAliveCountMax=3 -o ConnectTimeout=5 "$@"; }
state="/tmp/vps-ports-$(id -u).list"; touch "$state"

sync_once() {
  want=$(ssh_ "$host" "ss -ltnH" 2> /dev/null | awk '{n=split($4,a,":"); p=a[n]; if (p>=3000 && p<=9999) print p}' | sort -un) || return
  [ -n "$want" ] || { [ -s "$state" ] && ssh_ -O exit "$host" 2> /dev/null; : > "$state"; return; }
  for p in $want; do
    grep -qx "$p" "$state" && continue
    lsof -nP -iTCP:"$p" -sTCP:LISTEN > /dev/null 2>&1 && continue # port taken locally
    ssh_ -O forward -L "127.0.0.1:$p:127.0.0.1:$p" "$host" 2> /dev/null && echo "$p" >> "$state"
  done
  for p in $(cat "$state"); do
    echo "$want" | grep -qx "$p" && continue
    ssh_ -O cancel -L "127.0.0.1:$p:127.0.0.1:$p" "$host" 2> /dev/null
    grep -vx "$p" "$state" > "$state.tmp"; mv "$state.tmp" "$state"
  done
}

case $1 in
  run) while :; do sync_once; sleep 3; done ;;
  list) cat "$state" ;;
  *) sed -n '2,5p' "$0" ;;
esac
