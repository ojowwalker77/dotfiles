# dotfiles

macOS setup: zsh, git, Ghostty, tmux, AeroSpace and a Brewfile.

## Install

```sh
git clone https://github.com/ojowwalker77/dotfiles ~/dotfiles
~/dotfiles/install.sh
```

`install.sh` installs Homebrew if missing, runs `brew bundle`, and symlinks each
config into place (an existing file is moved to `<name>.bak` first).

| Repo path                   | Linked to                    |
| --------------------------- | ---------------------------- |
| `zsh/.zshrc`, `zsh/.zprofile` | `~/.zshrc`, `~/.zprofile`  |
| `git/.gitconfig`            | `~/.gitconfig`               |
| `ghostty/config`            | `~/.config/ghostty/config`   |
| `tmux/.tmux.conf`           | `~/.tmux.conf`               |
| `tmux/*.sh`, `tmux/remote.conf` | `~/.config/tmux/`        |
| `aerospace/.aerospace.toml` | `~/.aerospace.toml`          |

## tmux

No prefix: every binding is Hyper (CapsLock mapped to Ctrl+Option+Shift) plus a key.

| Keys                    | Action                              |
| ----------------------- | ----------------------------------- |
| Hyper `1`–`9`, Hyper `n` | select window / next window        |
| Hyper `c`               | new window                          |
| Hyper `\` / Hyper `-`   | split right / split down            |
| Hyper `h j k l`, arrows | move between panes                  |
| Hyper `H J K L`         | resize pane                         |
| Hyper `x`               | kill pane                           |
| Hyper `,`               | rename window                       |
| Hyper `i` / `o` / `[`   | session picker / rename / new session |
| Hyper `r`               | reload config                       |

The status bar shows the window list on the left and CPU temperature
(`cpu-temp.sh`) and disk usage (`stats.sh`) on the right.

### Remote windows

Windows from a tmux session on other Linux machines appear in the local window
list, drawn in yellow, next to the local ones (purple when current, grey
otherwise). The same keys work on both:

- Hyper `1`–`9` / Hyper `n` switch between local and remote windows alike.
- Inside a remote window, splits, pane moves, resizes and Hyper `x` act on the
  remote tmux; Hyper `c` opens a new window on that machine, in the same directory.
- Remote windows created elsewhere (e.g. by attaching to the box directly) show
  up within ~5 seconds; closed ones disappear.
- If the connection drops, the window shows `retrying` and reconnects on its
  own. The remote session keeps running either way.

Each box keeps one permanent tmux session named `main`. For every remote window
the Mac opens an ssh connection (shared through one ControlMaster socket) that
attaches to a private session holding just that window, with the remote status
bar hidden.

#### Setup on the Mac

Two machine-local files, not in this repo:

```sh
# private key used for the boxes (its .pub is what boxes authorize)
echo ~/.ssh/id_ed25519 > ~/.config/tmux/remote-key

# boxes to mirror, one ssh destination per line (managed by `remote.sh add/remove`)
touch ~/.config/tmux/remote-hosts
```

#### Add a Linux box

1. On the Mac, print the bootstrap command (it embeds your public key):

   ```sh
   ~/.config/tmux/remote.sh bootstrap
   ```

   It looks like:

   ```sh
   curl -fsSL https://raw.githubusercontent.com/ojowwalker77/dotfiles/main/tmux/remote-bootstrap.sh | sh -s -- 'ssh-ed25519 AAAA... tmux-remote'
   ```

2. Run that on the box. It installs tmux if needed, authorizes the key, installs
   `~/.config/tmux/mirror-host.sh`, starts the `main` session and prints the
   next command. The box needs an ssh server the Mac can reach (directly or
   over Tailscale).

3. Back on the Mac, run the printed line:

   ```sh
   ~/.config/tmux/remote.sh add user@100.x.y.z
   ```

   Any ssh destination works, including a `Host` alias from `~/.ssh/config`.

#### Other commands

```sh
~/.config/tmux/remote.sh remove user@host   # stop mirroring a box, close its windows
~/.config/tmux/remote.sh install user@host  # push an updated mirror-host.sh to a box
~/.config/tmux/remote.sh                    # list all commands
```

Don't add the same machine twice under different names (alias and IP): its
windows would show up twice.

#### Files

| File                          | Where   | Role                                              |
| ----------------------------- | ------- | ------------------------------------------------- |
| `tmux/remote.sh`              | Mac     | sync, attach/reconnect, key pass-through, add/remove |
| `tmux/remote.conf`            | Mac     | Hyper bindings that forward pane keys in remote windows |
| `tmux/mirror-host.sh`         | box     | lists windows, creates the one-window views, runs pane commands |
| `tmux/remote-bootstrap.sh`    | box     | one-time setup via curl                           |
