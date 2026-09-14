#!/bin/sh
# Prepares a Linux box to be mirrored into a Mac's tmux (see remote.sh):
# installs tmux, authorizes the given ssh public key, installs mirror-host.sh and
# starts the "main" session. Then run the printed `remote.sh add` line on the Mac.
# `remote.sh bootstrap` on the Mac prints the full command, key included:
#
#   curl -fsSL https://raw.githubusercontent.com/ojowwalker77/dotfiles/main/tmux/remote-bootstrap.sh | sh -s -- 'ssh-ed25519 AAAA...'
set -eu

REPO=https://raw.githubusercontent.com/ojowwalker77/dotfiles/main
MAC_KEY=${1:?"usage: remote-bootstrap.sh 'ssh-ed25519 AAAA...' (get the line from remote.sh bootstrap on the Mac)"}

as_root() { if [ "$(id -u)" -eq 0 ]; then "$@"; else sudo "$@"; fi; }
has() { command -v "$1" > /dev/null 2>&1; }

if ! has tmux; then
  echo "installing tmux..."
  if   has apt-get; then as_root apt-get update -qq && as_root apt-get install -y -qq tmux
  elif has dnf;     then as_root dnf install -y -q tmux
  elif has yum;     then as_root yum install -y -q tmux
  elif has apk;     then as_root apk add -q tmux
  elif has pacman;  then as_root pacman -Sy --noconfirm tmux
  elif has zypper;  then as_root zypper -q install -y tmux
  else echo "no known package manager; install tmux and rerun" >&2; exit 1
  fi
fi

mkdir -p ~/.ssh ~/.config/tmux
chmod 700 ~/.ssh
touch ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
key_body=$(echo "$MAC_KEY" | cut -d' ' -f2)
grep -qF "$key_body" ~/.ssh/authorized_keys || echo "$MAC_KEY" >> ~/.ssh/authorized_keys

curl -fsSL "$REPO/tmux/mirror-host.sh" -o ~/.config/tmux/mirror-host.sh
chmod +x ~/.config/tmux/mirror-host.sh

# Mirrors hide this box's status bar; mouse on keeps scrolling and pane clicks working
[ -e ~/.tmux.conf ] || cat > ~/.tmux.conf << 'EOF'
set -g mouse on
set -g base-index 1
setw -g pane-base-index 1
set -g history-limit 10000
set -s escape-time 0
set -s set-clipboard on
EOF

tmux has-session -t '=main' 2> /dev/null || tmux new-session -d -s main -c "$HOME"

has sshd || [ -x /usr/sbin/sshd ] || echo "warning: no sshd here; install openssh-server so the Mac can connect" >&2

addr=""
has tailscale && addr=$(tailscale ip -4 2> /dev/null | head -1) || true
[ -n "$addr" ] || addr=$(ip -4 route get 1.1.1.1 2> /dev/null | awk '{ for (i = 1; i < NF; i++) if ($i == "src") print $(i + 1) }')
[ -n "$addr" ] || addr=$(hostname)

echo
echo "ready. on the Mac run:"
echo "  ~/.config/tmux/remote.sh add $(id -un)@$addr"
