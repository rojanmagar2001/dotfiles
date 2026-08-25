# ~/.zshenv - sourced by every zsh (interactive, non-interactive, scripts).
# Keep this to environment variables only. No output, no prompts, nothing slow.

# XDG Base Directory specification
export XDG_CONFIG_HOME="$HOME/.config"    # Config files
export XDG_CACHE_HOME="$HOME/.cache"      # Cache files
export XDG_DATA_HOME="$HOME/.local/share" # Application data
export XDG_STATE_HOME="$HOME/.local/state"# Logs and state files

# Where the modular zsh config lives
export ZSH_CONFIG_DIR="$XDG_CONFIG_HOME/zsh"

# Locale
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"

# Themes (onedark or nord)
export TMUX_THEME="nord"
export NVIM_THEME="nord"
export STARSHIP_THEME="nord"
export WEZTERM_THEME="nord"

# Editor
export EDITOR="nvim"
export VISUAL="nvim"
export MANPAGER='nvim +Man!'

# Hide computer name in terminal
export DEFAULT_USER="$USER"

# Build flags for software linking against Homebrew's zlib / bzip2
export LDFLAGS="-L/usr/local/opt/zlib/lib -L/usr/local/opt/bzip2/lib"
export CPPFLAGS="-I/usr/local/opt/zlib/include -I/usr/local/opt/bzip2/include"

# Secrets - not tracked in git
[ -f "$HOME/.env" ] && source "$HOME/.env"
