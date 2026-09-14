#!/bin/bash
# Mirrors the windows of the "main" tmux session on each remote host into local
# sessions, so remote windows share the status bar and the window keys.
# Hosts are listed one per line in ~/.config/tmux/remote-hosts, and the private
# key used for them is named in ~/.config/tmux/remote-key (both machine-local).
# Each mirror window is tagged with @remote_host and @remote_id and runs an ssh
# attach to a single-window view of that remote window (mirror-host.sh on the host).
#
#   remote.sh sync SESSION               add / rename / drop mirror windows (run by the status bar)
#   remote.sh bootstrap                  print the curl command that prepares a new Linux box
#   remote.sh add HOST                   install mirror-host.sh on HOST and start mirroring it
#   remote.sh remove HOST                stop mirroring HOST and close its windows
#   remote.sh attach HOST RID            pane command of a mirror window; reconnects on network drops
#   remote.sh do HOST RID CMD [ARG...]   run a mirror-host.sh command: split, pane, resize, kill
#   remote.sh new HOST RID SESSION       new remote window in RID's directory, then focus its mirror
#   remote.sh rename HOST RID LID NAME   rename the remote window and its local mirror
#   remote.sh install HOST               copy mirror-host.sh to HOST

dir="$HOME/.config/tmux"
self="$dir/remote.sh"
hosts_file="$dir/remote-hosts"
key=$(cat "$dir/remote-key" 2> /dev/null) # private key path; remote-bootstrap.sh authorizes its .pub
lock="/tmp/tmux-remote-sync-$(id -u).lock"

ssh_() {
  local id=()
  [ -f "$key" ] && id=(-i "$key")
  ssh "${id[@]}" -o ControlMaster=auto -o ControlPath="$HOME/.ssh/cm-tmux-%C" -o ControlPersist=10m \
      -o ServerAliveInterval=5 -o ServerAliveCountMax=3 -o ConnectTimeout=5 "$@"
}

remote() { # remote HOST CMD [ARG...]
  local host=$1; shift
  ssh_ -o BatchMode=yes "$host" "~/.config/tmux/mirror-host.sh $(printf '%q ' "$@")"
}

hosts() { [ -f "$hosts_file" ] && grep -Ev '^[[:space:]]*(#|$)' "$hosts_file"; }

sync_host() { # sync_host SESSION HOST MIRRORS
  local s=$1 host=$2 mine want rid rname lid lname
  want=$(remote "$host" list) || return 0 # unreachable: leave its mirrors reconnecting
  mine=$(printf '%s\n' "$3" | awk -F'\t' -v h="$host" '$1 == h')

  # drop mirrors whose remote window is gone
  while IFS=$'\t' read -r _ rid lid lname; do
    [ -n "$rid" ] || continue
    printf '%s\n' "$want" | cut -f1 | grep -qxF -- "$rid" || tmux kill-window -t "$lid"
  done <<< "$mine"

  # add missing mirrors, follow remote renames
  while IFS=$'\t' read -r rid rname; do
    [ -n "$rid" ] || continue
    lid=$(printf '%s\n' "$mine" | awk -F'\t' -v r="$rid" '$2 == r { print $3 }')
    lname=$(printf '%s\n' "$mine" | awk -F'\t' -v r="$rid" '$2 == r { print $4 }')
    if [ -z "$lid" ]; then
      lid=$(tmux new-window -d -P -F '#{window_id}' -t "=$s:" -n "$rname" "$self attach $(printf '%q' "$host") $rid")
      tmux set -w -t "$lid" @remote_host "$host"
      tmux set -w -t "$lid" @remote_id "$rid"
      tmux set -w -t "$lid" automatic-rename off
    elif [ "$lname" != "$rname" ]; then
      tmux rename-window -t "$lid" "$rname"
    fi
  done <<< "$want"
}

sync_windows() {
  local s=$1 mirrors host rid lid lname
  mirrors=$(tmux list-windows -t "=$s" -F '#{@remote_host}	#{@remote_id}	#{window_id}	#{window_name}' | awk -F'\t' '$2 != ""')

  # close mirrors of hosts no longer listed
  while IFS=$'\t' read -r host rid lid lname; do
    [ -n "$rid" ] || continue
    hosts | grep -qxF -- "$host" || tmux kill-window -t "$lid"
  done <<< "$mirrors"

  for host in $(hosts); do
    sync_host "$s" "$host" "$mirrors" &
  done
  wait
}

sync_all() {
  tmux list-sessions -F '#{session_name}' | while read -r s; do
    lockf -t 10 "$lock" "$self" _sync "$s"
  done
}

attach() { # attach HOST RID
  while :; do
    ssh_ -t "$1" "~/.config/tmux/mirror-host.sh attach $2"
    [ $? -eq 255 ] || exit 0 # window closed or detached; only ssh failures retry
    printf '\033[2m%s unreachable, retrying...\033[0m\n' "$1"
    sleep 3
  done
}

new_window() { # new_window HOST RID SESSION
  local host=$1 s=$3 nid lid
  nid=$(remote "$host" new "$2") || return
  lockf -t 10 "$lock" "$self" _sync "$s"
  lid=$(tmux list-windows -t "=$s" -F '#{@remote_host} #{@remote_id} #{window_id}' |
    awk -v h="$host" -v r="$nid" '$1 == h && $2 == r { print $3 }')
  [ -n "$lid" ] && tmux select-window -t "$lid"
}

install_host() {
  ssh_ "$1" 'mkdir -p ~/.config/tmux && cat > ~/.config/tmux/mirror-host.sh && chmod +x ~/.config/tmux/mirror-host.sh' \
    < "$dir/mirror-host.sh"
}

add_host() {
  local host=$1
  if ! ssh_ -o BatchMode=yes -o StrictHostKeyChecking=accept-new "$host" true; then
    echo "can't ssh to $host; run remote-bootstrap.sh there first" >&2
    return 1
  fi
  install_host "$host" || return
  remote "$host" list > /dev/null || { echo "tmux isn't working on $host" >&2; return 1; }
  hosts | grep -qxF -- "$host" || echo "$host" >> "$hosts_file"
  sync_all
  echo "mirroring $host"
}

remove_host() {
  local host=$1 w
  if [ -f "$hosts_file" ]; then
    grep -vxF -- "$host" "$hosts_file" > "$hosts_file.tmp"
    mv "$hosts_file.tmp" "$hosts_file"
  fi
  tmux list-windows -a -F '#{@remote_host} #{window_id}' | awk -v h="$host" '$1 == h { print $2 }' |
    while read -r w; do tmux kill-window -t "$w"; done
}

bootstrap() {
  [ -f "$key.pub" ] || { echo "no public key: put the private key path in $dir/remote-key" >&2; return 1; }
  printf "curl -fsSL %s | sh -s -- '%s tmux-remote'\n" \
    https://raw.githubusercontent.com/ojowwalker77/dotfiles/main/tmux/remote-bootstrap.sh "$(cut -d' ' -f1,2 "$key.pub")"
}

case $1 in
  sync)      lockf -s -t 0 "$lock" "$self" _sync "$2" ;;
  _sync)     sync_windows "$2" ;;
  bootstrap) bootstrap ;;
  add)       add_host "$2" ;;
  remove)  remove_host "$2" ;;
  attach)  attach "$2" "$3" ;;
  do)      remote "$2" "$4" "$3" "${@:5}" ;;
  new)     new_window "$2" "$3" "$4" ;;
  rename)  remote "$2" rename "$3" "$5" && tmux rename-window -t "$4" "$5" ;;
  install) install_host "$2" ;;
  *)       sed -n '2,17p' "$self" >&2; exit 2 ;;
esac
