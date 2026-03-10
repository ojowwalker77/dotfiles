# =============================================================================
# ZSH CONFIGURATION - Ultimate Mac Terminal Rice
# =============================================================================

# -----------------------------------------------------------------------------
# ENVIRONMENT VARIABLES
# -----------------------------------------------------------------------------
export LANG=en_US.UTF-8
export EDITOR="zed --wait"
export VISUAL="$EDITOR"

# XDG Base Directory
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

# Local binaries
export PATH="$HOME/.local/bin:$PATH"

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# -----------------------------------------------------------------------------
# ZINIT INITIALIZATION
# -----------------------------------------------------------------------------
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit if not present
if [[ ! -d "$ZINIT_HOME" ]]; then
    print -P "%F{33}Installing Zinit...%f"
    command mkdir -p "$(dirname $ZINIT_HOME)"
    command git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME" && \
        print -P "%F{34}Installation successful.%f" || \
        print -P "%F{160}Installation failed.%f"
fi

source "${ZINIT_HOME}/zinit.zsh"

# -----------------------------------------------------------------------------
# ZINIT PLUGINS
# -----------------------------------------------------------------------------

# Completions
zinit wait lucid blockf atpull'zinit creinstall -q .' for \
    zsh-users/zsh-completions

# Oh My Zsh plugins
zinit wait lucid for \
    OMZP::git \
    OMZP::sudo

# Initialize completions
autoload -Uz compinit && compinit

# Autosuggestions (history-based)
zinit wait lucid atload'_zsh_autosuggest_start' for \
    zsh-users/zsh-autosuggestions

export ZSH_AUTOSUGGEST_STRATEGY=(history completion)
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#444444"

# Syntax highlighting (must be after completions)
zinit wait lucid for \
    zdharma-continuum/fast-syntax-highlighting

# -----------------------------------------------------------------------------
# COMPLETION SETTINGS
# -----------------------------------------------------------------------------
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu select
zstyle ':completion:*' special-dirs true
zstyle ':completion:*:descriptions' format '[%d]'

# -----------------------------------------------------------------------------
# HISTORY SETTINGS
# -----------------------------------------------------------------------------
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt EXTENDED_HISTORY          # Write timestamp to history
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicates first
setopt HIST_IGNORE_DUPS          # Ignore duplicates
setopt HIST_IGNORE_ALL_DUPS      # Remove older duplicate entries
setopt HIST_IGNORE_SPACE         # Ignore commands starting with space
setopt HIST_FIND_NO_DUPS         # No duplicates in search
setopt HIST_SAVE_NO_DUPS         # Don't save duplicates
setopt SHARE_HISTORY             # Share history between sessions
setopt APPEND_HISTORY            # Append to history file

# -----------------------------------------------------------------------------
# SHELL OPTIONS
# -----------------------------------------------------------------------------
setopt AUTO_CD                   # cd by typing directory name
setopt AUTO_PUSHD                # Push directories to stack
setopt PUSHD_IGNORE_DUPS         # No duplicates in directory stack
setopt PUSHD_SILENT              # Silent pushd
setopt CORRECT                   # Command correction
setopt INTERACTIVE_COMMENTS      # Allow comments in interactive mode

# -----------------------------------------------------------------------------
# KEY BINDINGS
# -----------------------------------------------------------------------------
bindkey -e                       # Emacs key bindings
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
bindkey '^[[1;5C' forward-word   # Ctrl+Right
bindkey '^[[1;5D' backward-word  # Ctrl+Left
bindkey '^[[3~' delete-char      # Delete key

# -----------------------------------------------------------------------------
# OH MY POSH PROMPT
# -----------------------------------------------------------------------------
eval "$(oh-my-posh init zsh --config ~/.config/ohmyposh/config.toml)"

# -----------------------------------------------------------------------------
# ZOXIDE (Smart cd)
# -----------------------------------------------------------------------------
eval "$(zoxide init zsh)"

# -----------------------------------------------------------------------------
# FZF CONFIGURATION
# -----------------------------------------------------------------------------
# Initialize fzf
eval "$(fzf --zsh)"

# Obsidian theme for fzf (black + white + green)
export FZF_DEFAULT_OPTS="
  --color=fg:#999999,bg:#000000,hl:#1DCD9F
  --color=fg+:#ffffff,bg+:#111111,hl+:#4de8be
  --color=info:#1DCD9F,prompt:#1DCD9F,pointer:#ff6b6b
  --color=marker:#1DCD9F,spinner:#169976,header:#ffc107
  --color=border:#333333
  --height=40%
  --layout=reverse
  --border=sharp
  --no-bold
  --bind='ctrl-/:toggle-preview'
"

# Use fd for fzf (faster than find, exclude junk)
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow \
  --exclude .git \
  --exclude node_modules \
  --exclude .cache \
  --exclude Cache \
  --exclude Caches \
  --exclude CacheStorage \
  --exclude Library \
  --exclude Pictures \
  --exclude Movies \
  --exclude Music \
  --exclude Photos\ Library.photoslibrary \
  --exclude "*.photoslibrary" \
  --exclude Applications \
  --exclude .Trash \
  --exclude .npm \
  --exclude .cargo \
  --exclude .rustup \
  --exclude __pycache__ \
  --exclude "*.pyc" \
  --exclude .venv \
  --exclude venv \
  --exclude dist \
  --exclude build \
  --exclude .next \
  --exclude .nuxt'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow \
  --exclude .git \
  --exclude node_modules \
  --exclude .cache \
  --exclude Cache \
  --exclude Caches \
  --exclude Library \
  --exclude .Trash'

# Preview with bat for CTRL-T
export FZF_CTRL_T_OPTS="
  --preview 'bat --style=numbers --color=always --line-range :500 {}'
"

# Preview directories with eza for ALT-C
export FZF_ALT_C_OPTS="
  --preview 'eza --tree --color=always --icons --level=2 {}'
"

# Better history search
export FZF_CTRL_R_OPTS="
  --preview 'echo {}'
  --preview-window down:3:hidden:wrap
  --bind 'ctrl-/:toggle-preview'
"

# -----------------------------------------------------------------------------
# EZA ALIASES (Modern ls replacement)
# -----------------------------------------------------------------------------
# Obsidian theme colors for eza
# #1DCD9F = 29;205;159  #169976 = 22;153;118  #4de8be = 77;232;190
# #ff6b6b = 255;107;107  #ffc107 = 255;193;7  #ffffff = 255;255;255
# #888888 = 136;136;136  #555555 = 85;85;85  #444444 = 68;68;68
export EZA_COLORS="\
di=1;38;2;29;205;159:\
ln=3;38;2;77;232;190:\
ex=38;2;22;153;118:\
ur=38;2;255;255;255:\
uw=38;2;29;205;159:\
ux=38;2;77;232;190:\
ue=38;2;77;232;190:\
gr=38;2;136;136;136:\
gw=38;2;22;153;118:\
gx=38;2;22;153;118:\
tr=38;2;85;85;85:\
tw=38;2;255;193;7:\
tx=38;2;85;85;85:\
su=38;2;255;107;107:\
sf=38;2;255;107;107:\
xa=38;2;85;85;85:\
sn=38;2;255;255;255:\
sb=38;2;22;153;118:\
nb=38;2;85;85;85:\
nk=38;2;255;255;255:\
nm=38;2;29;205;159:\
ng=38;2;255;193;7:\
nt=38;2;255;107;107:\
ub=38;2;85;85;85:\
uk=38;2;22;153;118:\
um=38;2;22;153;118:\
ug=38;2;22;153;118:\
ut=38;2;22;153;118:\
da=38;2;85;85;85:\
uu=38;2;29;205;159:\
uR=38;2;255;107;107:\
un=38;2;136;136;136:\
gu=38;2;22;153;118:\
gR=38;2;255;107;107:\
gn=38;2;85;85;85:\
lc=38;2;85;85;85:\
lm=38;2;255;193;7:\
ga=38;2;29;205;159:\
gm=38;2;255;193;7:\
gd=38;2;255;107;107:\
gv=38;2;77;232;190:\
gt=38;2;29;205;159:\
gi=38;2;68;68;68:\
gc=1;38;2;255;107;107:\
Gm=38;2;29;205;159:\
Go=38;2;22;153;118:\
Gc=38;2;29;205;159:\
Gd=38;2;255;193;7:\
lp=38;2;22;153;118:\
cc=38;2;255;107;107:\
bO=38;2;255;107;107:\
hd=1;4;38;2;29;205;159:\
xx=38;2;85;85;85:\
im=38;2;22;153;118:\
vi=38;2;22;153;118:\
mu=38;2;22;153;118:\
cr=38;2;255;193;7:\
do=38;2;255;255;255:\
co=38;2;255;193;7:\
tm=38;2;68;68;68:\
cm=38;2;85;85;85:\
bu=38;2;22;153;118:\
sc=38;2;255;255;255"

alias ls='eza --color=always --group-directories-first --icons=always'
alias ll='eza -la --icons=always --group-directories-first --git'
alias la='eza -a --icons=always --group-directories-first'
alias lt='eza --tree --level=2 --icons=always'
alias l='eza -l --icons=always --group-directories-first'
alias tree='eza --tree --icons=always'

# -----------------------------------------------------------------------------
# BAT CONFIGURATION (Syntax highlighted cat)
# -----------------------------------------------------------------------------
export BAT_THEME="base16"
alias cat='bat --paging=never'
alias catp='bat --plain'

# -----------------------------------------------------------------------------
# RIPGREP CONFIGURATION
# -----------------------------------------------------------------------------
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep/config"

# -----------------------------------------------------------------------------
# GIT ALIASES
# -----------------------------------------------------------------------------
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit -m'
alias gca='git commit -a -m'
alias gco='git checkout'
alias gd='git diff'
alias gds='git diff --staged'
alias gl='git log --oneline --graph --decorate -10'
alias gla='git log --oneline --graph --decorate --all'
alias gp='git push'
alias gpl='git pull'
alias gs='git status -sb'
alias gb='git branch'
alias gf='git fetch --all --prune'

# Lazygit
alias lg='lazygit'

# Quick commits
alias wip='git add . && git commit -m "wip"'
alias wipp='git add . && git commit -m "wip" && git push'

# Claude
alias cc='claude'
alias ccd='claude --dangerously-skip-permissions'

# mkdir + cd (uses existing mkcd function)
alias mkc='mkcd'

# Dev utilities
alias ports='lsof -i -P -n | grep LISTEN'
alias cls='clear && ls'
alias nuke='rm -rf node_modules package-lock.json bun.lockb'
alias sizeof='du -sh'
alias weather='curl wttr.in/?0'
alias cheat='curl cheat.sh/'

# Git power moves
alias yolo='git add . && git commit -m "$(curl -s whatthecommit.com/index.txt)"'
alias uncommit='git reset --soft HEAD~1'
alias amend='git commit --amend --no-edit'
alias stash='git stash -u'
alias pop='git stash pop'
alias main='git checkout main && git pull'
alias whoops='git reset --hard HEAD'
alias please='sudo !!'

# Port management
killport() { lsof -ti:$1 | xargs kill -9 2>/dev/null && echo "Killed port $1" || echo "Nothing on port $1"; }

# -----------------------------------------------------------------------------
# USEFUL ALIASES
# -----------------------------------------------------------------------------
# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'

# Safety
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Utilities
alias c='clear'
alias h='history'
alias reload='source ~/.zshrc'
alias path='echo -e ${PATH//:/\\n}'
alias now='date +"%Y-%m-%d %H:%M:%S"'

# Network
alias ip='curl -s https://ipinfo.io/ip'
alias localip='ipconfig getifaddr en0'

# Homebrew
alias brewup='brew update && brew upgrade && brew cleanup'

# Quick edit configs
alias zshrc='${EDITOR:-vim} ~/.zshrc'
alias ghosttyrc='${EDITOR:-vim} ~/.config/ghostty/config'
alias promptrc='${EDITOR:-vim} ~/.config/ohmyposh/config.toml'

# -----------------------------------------------------------------------------
# USEFUL FUNCTIONS
# -----------------------------------------------------------------------------

# Create directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Find in history
fh() {
    print -z $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed -E 's/ *[0-9]*\*? *//' | sed -E 's/\\/\\\\/g')
}

# Search and open file in editor
fe() {
    local file
    file=$(fzf --preview 'bat --style=numbers --color=always --line-range :500 {}')
    [[ -n "$file" ]] && ${EDITOR:-vim} "$file"
}

# Search and open file in vim
fzfo() {
    local file
    file=$(fzf --preview 'bat --style=numbers --color=always --line-range :500 {}')
    [[ -n "$file" ]] && vim "$file"
}

# cd with fzf
fcd() {
    local dir
    dir=$(fd --type d --hidden --follow --exclude .git | fzf --preview 'eza --tree --color=always --icons --level=2 {}')
    [[ -n "$dir" ]] && cd "$dir"
}

# Git log with fzf
fgl() {
    git log --oneline --color=always | fzf --ansi --preview 'git show --color=always {1}'
}

# Kill process with fzf
fkill() {
    local pid
    pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
    if [ "x$pid" != "x" ]; then
        echo $pid | xargs kill -${1:-9}
    fi
}


# -----------------------------------------------------------------------------
# TERMINAL MODE: Set to "tmux" or "ghostty"
# -----------------------------------------------------------------------------
TERMINAL_MODE="ghostty"  # Change to "tmux" to use tmux instead

if [ "$TERMINAL_MODE" = "tmux" ]; then
    # Auto-start tmux
    if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
        tmux attach -t main 2>/dev/null || tmux new -s main
    fi
elif [ "$TERMINAL_MODE" = "ghostty" ] && [ -z "$TMUX" ]; then
    # Start Ghostty status daemon (updates title bar)
    if [ -f ~/.config/ghostty/status-daemon.sh ]; then
        # Kill any existing daemon, start fresh in background
        pkill -f "status-daemon.sh" 2>/dev/null
        ~/.config/ghostty/status-daemon.sh &>/dev/null &
        disown
    fi
fi

# -----------------------------------------------------------------------------
# LOCAL CUSTOMIZATIONS
# -----------------------------------------------------------------------------
# Load local customizations if they exist
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local



# Added by Antigravity
export PATH="/Users/jow/.antigravity/antigravity/bin:$PATH"
export PATH="$HOME/.claude/local/node_modules/.bin:$PATH"


# Claude Matrix CLI
export PATH="$HOME/.claude/matrix/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"

# Added by Antigravity
export PATH="/Users/jow/.antigravity/antigravity/bin:$PATH"
export PATH="/Users/jow/.cache/.bun/bin:$PATH"

# Added by Antigravity
export PATH="/Users/jow/.antigravity/antigravity/bin:$PATH"

# Added by Antigravity
export PATH="/Users/jow/.antigravity/antigravity/bin:$PATH"
