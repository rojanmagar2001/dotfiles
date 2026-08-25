# ~/.zshrc - sourced by interactive shells only.
# This file is a loader. Real configuration lives in $ZSH_CONFIG_DIR.

: "${ZSH_CONFIG_DIR:=$HOME/.config/zsh}"

# History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_ALL_DUPS   # Never keep a duplicate of an older entry
setopt HIST_IGNORE_SPACE      # Commands starting with a space are not recorded
setopt HIST_REDUCE_BLANKS     # Trim superfluous whitespace before saving
setopt SHARE_HISTORY          # Share history across concurrent shells
setopt EXTENDED_HISTORY       # Record timestamps

# Directory navigation
setopt AUTO_CD                # `foo` acts as `cd foo` when foo is a directory
setopt AUTO_PUSHD             # Keep a stack of visited directories
setopt PUSHD_IGNORE_DUPS
setopt INTERACTIVE_COMMENTS   # Allow # comments at the interactive prompt

# Load config modules, in order. Each is optional.
#   custom.zsh    - shell behaviour: prompt, completion, plugins, keybindings
#   tools.zsh     - language runtimes and per-tool PATH/env
#   aliases.zsh   - aliases
#   functions.zsh - shell functions
#   work.zsh      - work-specific config (not tracked)
#   local.zsh     - machine-specific overrides (not tracked)
for _zsh_module in custom tools aliases functions work local; do
  [ -r "$ZSH_CONFIG_DIR/$_zsh_module.zsh" ] && source "$ZSH_CONFIG_DIR/$_zsh_module.zsh"
done
unset _zsh_module
