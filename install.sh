#!/bin/bash
set -e

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

info() { printf "\033[1;32m→\033[0m %s\n" "$1"; }
warn() { printf "\033[1;33m!\033[0m %s\n" "$1"; }

link() {
    local src="$1" dst="$2"
    mkdir -p "$(dirname "$dst")"
    if [ -L "$dst" ]; then
        rm "$dst"
    elif [ -e "$dst" ]; then
        warn "Backing up $dst → ${dst}.bak"
        mv "$dst" "${dst}.bak"
    fi
    ln -s "$src" "$dst"
    info "Linked $dst"
}

# ─── Homebrew ───
if ! command -v brew &>/dev/null; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

info "Installing Homebrew packages..."
brew bundle --file="$DOTFILES/Brewfile"

# ─── Shell ───
link "$DOTFILES/zsh/.zshrc"     "$HOME/.zshrc"
link "$DOTFILES/zsh/.zprofile"  "$HOME/.zprofile"

# ─── Git ───
link "$DOTFILES/git/.gitconfig" "$HOME/.gitconfig"

# ─── Ghostty ───
link "$DOTFILES/ghostty/config" "$HOME/.config/ghostty/config"

# ─── Zed ───
link "$DOTFILES/zed/settings.json" "$HOME/.config/zed/settings.json"

# ─── Tmux ───
link "$DOTFILES/tmux/.tmux.conf" "$HOME/.tmux.conf"
mkdir -p "$HOME/.config/tmux"
for f in "$DOTFILES"/tmux/*.sh; do
    link "$f" "$HOME/.config/tmux/$(basename "$f")"
done
link "$DOTFILES/tmux/remote.conf" "$HOME/.config/tmux/remote.conf"

# ─── Aerospace ───
link "$DOTFILES/aerospace/.aerospace.toml" "$HOME/.aerospace.toml"

# ─── Make tmux scripts executable ───
chmod +x "$DOTFILES"/tmux/*.sh

echo ""
info "Done! Restart your terminal or run: source ~/.zshrc"
