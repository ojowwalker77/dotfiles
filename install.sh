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
brew bundle --file="$DOTFILES/Brewfile" --no-lock

# ─── Shell ───
link "$DOTFILES/zsh/.zshrc"     "$HOME/.zshrc"
link "$DOTFILES/zsh/.zprofile"  "$HOME/.zprofile"

# ─── Git ───
link "$DOTFILES/git/.gitconfig" "$HOME/.gitconfig"

# ─── Ghostty ───
link "$DOTFILES/ghostty/config" "$HOME/.config/ghostty/config"

# ─── Tmux ───
link "$DOTFILES/tmux/.tmux.conf" "$HOME/.tmux.conf"
mkdir -p "$HOME/.config/tmux"
for f in "$DOTFILES"/tmux/*.sh; do
    link "$f" "$HOME/.config/tmux/$(basename "$f")"
done

# ─── Aerospace ───
link "$DOTFILES/aerospace/.aerospace.toml" "$HOME/.aerospace.toml"

# ─── Zed ───
mkdir -p "$HOME/.config/zed/themes"
link "$DOTFILES/zed/settings.json" "$HOME/.config/zed/settings.json"
link "$DOTFILES/zed/keymap.json"   "$HOME/.config/zed/keymap.json"
link "$DOTFILES/zed/themes/obsidian.json" "$HOME/.config/zed/themes/obsidian.json"

# ─── Neovim ───
mkdir -p "$HOME/.config/nvim/lua/pilot/actions" "$HOME/.config/nvim/lua/pilot/ui"
link "$DOTFILES/nvim/init.lua"                      "$HOME/.config/nvim/init.lua"
link "$DOTFILES/nvim/lua/pilot/init.lua"             "$HOME/.config/nvim/lua/pilot/init.lua"
link "$DOTFILES/nvim/lua/pilot/openrouter.lua"       "$HOME/.config/nvim/lua/pilot/openrouter.lua"
link "$DOTFILES/nvim/lua/pilot/actions/lookup.lua"   "$HOME/.config/nvim/lua/pilot/actions/lookup.lua"
link "$DOTFILES/nvim/lua/pilot/ui/float.lua"         "$HOME/.config/nvim/lua/pilot/ui/float.lua"

# ─── Oh My Posh ───
mkdir -p "$HOME/.config/ohmyposh"
link "$DOTFILES/ohmyposh/config.toml" "$HOME/.config/ohmyposh/config.toml"

# ─── Starship ───
link "$DOTFILES/starship/starship.toml" "$HOME/.config/starship.toml"

# ─── Lazygit ───
mkdir -p "$HOME/.config/lazygit"
link "$DOTFILES/lazygit/config.yml" "$HOME/.config/lazygit/config.yml"

# ─── Ripgrep ───
mkdir -p "$HOME/.config/ripgrep"
link "$DOTFILES/ripgrep/config" "$HOME/.config/ripgrep/config"

# ─── Eza ───
mkdir -p "$HOME/.config/eza"
link "$DOTFILES/eza/theme.yml" "$HOME/.config/eza/theme.yml"

# ─── Barik ───
mkdir -p "$HOME/.config/barik"
link "$DOTFILES/barik/config.toml" "$HOME/.config/barik/config.toml"

# ─── Make tmux scripts executable ───
chmod +x "$DOTFILES"/tmux/*.sh

echo ""
info "Done! Restart your terminal or run: source ~/.zshrc"
