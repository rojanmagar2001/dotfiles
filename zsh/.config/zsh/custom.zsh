# custom.zsh - core interactive shell behaviour.
# Prompt, completion, plugins, fzf and keybindings.

# ---------------------------------------------------------------- Homebrew --
eval "$(/opt/homebrew/bin/brew shellenv)"
export HOMEBREW_NO_AUTO_UPDATE=1
BREW_PREFIX="$(brew --prefix)"

# -------------------------------------------------------------- Completion --
# Must run before plugins that hook into the completion system.
fpath=("$ZSH_CONFIG_DIR" "$BREW_PREFIX/share/zsh/site-functions" $fpath)
[ -d "$HOME/.docker/completions" ] && fpath=("$HOME/.docker/completions" $fpath)

autoload -Uz compinit
# Rebuild the completion cache at most once a day; otherwise load it as-is.
_zcompdump="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
# Builtin mkdir, so this does not depend on PATH being set up yet.
zmodload -F zsh/files b:zf_mkdir
[[ -d "${_zcompdump:h}" ]] || zf_mkdir -p "${_zcompdump:h}"
if [[ -n ${_zcompdump}(#qN.mh+24) ]]; then
  compinit -d "$_zcompdump"
else
  compinit -C -d "$_zcompdump"
fi
unset _zcompdump

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'   # Case-insensitive
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:*:git:*' script "$ZSH_CONFIG_DIR/git-completion.bash"

# ------------------------------------------------------------------ Prompt --
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
eval "$(starship init zsh)"
[ -n "$STARSHIP_THEME" ] && starship config palette "$STARSHIP_THEME"

# ------------------------------------------------------------------- zoxide --
eval "$(zoxide init zsh)"

# --------------------------------------------------------------------- fzf --
# `fzf --zsh` emits the keybindings and completion; it replaces the old ~/.fzf.zsh.
source <(fzf --zsh)

export FZF_DEFAULT_COMMAND='rg --hidden --files --glob "!.git"'
export FZF_DEFAULT_OPTS="--height 60% --layout=reverse --border"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="
  --preview 'bat -n --color=always {}'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --color=always {}'"

bindkey "ç" fzf-cd-widget   # Fix for ALT+C on macOS

# ------------------------------------------------------------------ Plugins --
# Autosuggestions first, syntax highlighting must be sourced last.
source "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

source "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
(( ${+ZSH_HIGHLIGHT_STYLES} )) || typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[path]=none
ZSH_HIGHLIGHT_STYLES[path_prefix]=none

# ------------------------------------------------------------------ Vi mode --
# ANSI cursor escape codes:
#   \e[2 q  steady block   (normal mode)
#   \e[6 q  steady beam    (insert mode)
bindkey -v
export KEYTIMEOUT=1            # Makes switching modes quicker
export VI_MODE_SET_CURSOR=true

# Called every time the keymap changes (insert <-> normal mode)
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]]; then
    echo -ne '\e[2 q'
  else
    echo -ne '\e[6 q'
  fi
}
zle -N zle-keymap-select

# Runs once when a new line editor session starts
function zle-line-init {
  zle -K viins
  echo -ne '\e[6 q'
}
zle -N zle-line-init
[[ -t 1 ]] && echo -ne '\e[6 q'   # Beam cursor on startup

# Yank to the macOS system clipboard
function vi-yank-pbcopy {
  zle vi-yank
  printf '%s' "$CUTBUFFER" | pbcopy
}
zle -N vi-yank-pbcopy
bindkey -M vicmd 'y' vi-yank-pbcopy

# Press 'v' in normal mode to edit the current line in $EDITOR
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd 'v' edit-command-line

# Keep familiar emacs-style keys that vi mode would otherwise drop
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey '^K' kill-line
bindkey -M viins '^?' backward-delete-char   # Backspace past the insert point
