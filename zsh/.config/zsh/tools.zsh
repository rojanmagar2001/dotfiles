# tools.zsh - language runtimes, SDKs and per-tool PATH entries.
# Everything here is guarded, so a tool that is not installed is simply skipped.

# Prepend to PATH only if the directory exists and is not already present.
path_prepend() {
  [ -d "$1" ] || return 0
  case ":$PATH:" in
    *":$1:"*) ;;
    *) export PATH="$1:$PATH" ;;
  esac
}

# ------------------------------------------------------------------ General --
path_prepend "/usr/local/bin"
path_prepend "$HOME/.local/bin"       # uv, pipx, poetry and friends

# --------------------------------------------------------------------- Rust --
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

# ------------------------------------------------------------------- Node.js --
# nvm costs ~270ms to source, so load it lazily.
# The default node version is put on PATH immediately, and the full `nvm`
# function is loaded on first use.
export NVM_DIR="$XDG_CONFIG_HOME/nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
  # Put the version aliased to `default` on PATH without sourcing nvm.
  if [ -r "$NVM_DIR/alias/default" ]; then
    _nvm_default="$(<"$NVM_DIR/alias/default")"
    # `default` may be a partial version (e.g. "22"), so match the newest one.
    _nvm_bin=("$NVM_DIR/versions/node/v${_nvm_default#v}"*/bin(N/On))
    path_prepend "${_nvm_bin[1]}"
    unset _nvm_default _nvm_bin
  fi

  # Real nvm loads on first call to nvm / nvm-managed commands.
  _load_nvm() {
    unset -f nvm node npm npx corepack 2>/dev/null
    source "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"
  }
  nvm()      { _load_nvm; nvm "$@"; }
  corepack() { _load_nvm; corepack "$@"; }
fi

# --------------------------------------------------------------------- pnpm --
export PNPM_HOME="$XDG_DATA_HOME/pnpm"
path_prepend "$PNPM_HOME"

# ---------------------------------------------------------------------- Bun --
export BUN_INSTALL="$HOME/.bun"
path_prepend "$BUN_INSTALL/bin"
[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"

# --------------------------------------------------------------------- Ruby --
path_prepend "/opt/homebrew/opt/ruby/bin"
# Gem executables. Glob picks the newest gems directory without shelling out
# to `gem environment`, which costs ~90ms per shell.
_gem_bin=(/opt/homebrew/lib/ruby/gems/*/bin(N/On))
path_prepend "${_gem_bin[1]}"
unset _gem_bin

# ------------------------------------------------------------------ Flutter --
path_prepend "$HOME/development/flutter/bin"

# ----------------------------------------------------------------- Postgres --
path_prepend "/opt/homebrew/opt/libpq/bin"

# ---------------------------------------------------------------------- Lua --
export LUAVER_DIR="$HOME/.luaver"
if [ -s "$LUAVER_DIR/luaver" ]; then
  source "$LUAVER_DIR/luaver"
  path_prepend "$LUAVER_DIR/lua/5.1.5/bin"
  path_prepend "$LUAVER_DIR/luarocks/3.9.2/bin"
fi
path_prepend "$XDG_DATA_HOME/nvim/lazy-rocks/hererocks/bin"

# ---------------------------------------------------------------- Editors/AI --
path_prepend "$HOME/.opencode/bin"
path_prepend "$HOME/.antigravity/antigravity/bin"
path_prepend "$HOME/Library/Application Support/JetBrains/Toolbox/scripts"

# ---------------------------------------------------------------------- AWS --
export AWS_CLI_AUTO_PROMPT="on-partial"

# -------------------------------------------------------------------- ngrok --
# `ngrok completion` spawns a process, so generate it lazily on first tab.
if command -v ngrok >/dev/null 2>&1; then
  _ngrok_completion() {
    compdef -d ngrok
    eval "$(ngrok completion)"
    _ngrok "$@"
  }
  compdef _ngrok_completion ngrok
fi

# ------------------------------------------------------------------- Python --
export PIPENV_VENV_IN_PROJECT=1

# ------------------------------------------------------------------- Jupyter --
export JUPYTER_CONFIG_DIR="$HOME/python-notebook"
