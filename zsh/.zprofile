
eval "$(/opt/homebrew/bin/brew shellenv zsh)"

export PATH="$HOME/.local/bin:$PATH"

# >>> Codex installer >>>
# <<< Codex installer <<<

eval "$(/opt/homebrew/bin/brew shellenv)"

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init.zsh 2>/dev/null || :
