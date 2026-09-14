# Managed by Termstack — macOS / zsh
export EDITOR="vim"
export VISUAL="$EDITOR"
export HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_ALL_DUPS SHARE_HISTORY

eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
eval "$(atuin init zsh)"
eval "$(direnv hook zsh)"

alias ll='eza -la --group-directories-first'
alias cat='bat --paging=never'
alias g='git'
alias lg='lazygit'
alias ccd='claude --dangerously-skip-permissions'
alias ccx='CLAUDEX_MODEL=gpt-5.6-sol claudex --dangerously-skip-permissions'

# bun completions
[ -s "/Users/jow/.bun/_bun" ] && source "/Users/jow/.bun/_bun"

# Greenrun
export PATH="/Users/jow/.greenrun/bin:$PATH"

