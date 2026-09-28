# Managed by Termstack — macOS / zsh
export EDITOR="vim"
export VISUAL="$EDITOR"
export HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_ALL_DUPS SHARE_HISTORY

# Prompt: just an arrow (red after a failed command), with a blank line
# before each prompt except the first. The folder shows in the tab title.
setopt PROMPT_SUBST
PROMPT='%(?.%F{4}.%F{1})→%f '
autoload -Uz add-zsh-hook
_blank_line() { (( ${+_prompt_started} )) && print; _prompt_started=1 }
add-zsh-hook precmd _blank_line

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
eval "$(zoxide init zsh)"
eval "$(atuin init zsh)"
eval "$(direnv hook zsh)"

alias ll='eza -la --group-directories-first'
alias cat='bat --paging=never'
alias g='git'
alias lg='lazygit'
# `ccd` = Claude Code with every permission check bypassed.
#   ccd [args...]         normal Claude Code (default auth + models)
#   ccd --seek [args...]  same, but talks to DeepSeek V4.1 Flash through OpenRouter
#                         (OpenRouter key lives in ~/.config/claude-openrouter/env)
ccd() {
  local arg seek=0
  local -a args
  for arg in "$@"; do
    if [[ $arg == --seek ]]; then seek=1; else args+=("$arg"); fi
  done

  if (( ! seek )); then
    command claude --dangerously-skip-permissions "${args[@]}"
    return
  fi

  local envfile="$HOME/.config/claude-openrouter/env"
  if [[ ! -r $envfile ]]; then
    print -u2 "ccd: cannot read $envfile"
    return 1
  fi
  source $envfile
  if [[ -z $OPENROUTER_API_KEY ]]; then
    print -u2 "ccd: OPENROUTER_API_KEY is empty in $envfile -- paste your OpenRouter key there"
    return 1
  fi

  env -u ANTHROPIC_API_KEY \
    ANTHROPIC_BASE_URL=https://openrouter.ai/api \
    ANTHROPIC_AUTH_TOKEN="$OPENROUTER_API_KEY" \
    ANTHROPIC_MODEL=deepseek/deepseek-v4.1-flash \
    ANTHROPIC_DEFAULT_OPUS_MODEL=deepseek/deepseek-v4.1-flash \
    ANTHROPIC_DEFAULT_SONNET_MODEL=deepseek/deepseek-v4.1-flash \
    ANTHROPIC_DEFAULT_HAIKU_MODEL=deepseek/deepseek-v4.1-flash \
    CLAUDE_CODE_MAX_CONTEXT_TOKENS=1048576 \
    CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1 \
    claude --dangerously-skip-permissions "${args[@]}"
}
alias ccx='CLAUDEX_MODEL=gpt-5.6-sol claudex --dangerously-skip-permissions'

# bun completions
[ -s "/Users/jow/.bun/_bun" ] && source "/Users/jow/.bun/_bun"

# Greenrun
export PATH="/Users/jow/.greenrun/bin:$PATH"


# kimi-code
export PATH="/Users/jow/.kimi-code/bin:$PATH"

[[ ":$PATH:" != *":$HOME/.config/kaku/zsh/bin:"* ]] && export PATH="$HOME/.config/kaku/zsh/bin:$PATH" # Kaku PATH Integration
[[ -f "$HOME/.config/kaku/zsh/kaku.zsh" ]] && source "$HOME/.config/kaku/zsh/kaku.zsh" # Kaku Shell Integration
