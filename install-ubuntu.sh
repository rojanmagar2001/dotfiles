#!/usr/bin/env bash
# One-time Ubuntu setup for this dotfiles repo.
#
# Installs everything from apt that the stowed configs need, adds the
# WezTerm apt repo (not packaged for Ubuntu), and stows every package
# except `aerospace` (a macOS-only tiling window manager).
#
# Run with sudo, from anywhere:
#   sudo bash ~/dotfiles/install-ubuntu.sh
#
# Tools with no Ubuntu package (Neovim, lazygit, yazi, herdr, nvm/Node, tpm)
# are installed separately, per-user, without sudo - see the project chat
# for how those were set up.

set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
  echo "Run this with sudo: sudo bash $0" >&2
  exit 1
fi

REAL_USER="${SUDO_USER:-$(logname)}"
REAL_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Updating apt and installing packages"
apt-get update
apt-get install -y \
  stow \
  tmux \
  git \
  zsh \
  build-essential \
  unzip \
  eza \
  bat \
  fd-find \
  ripgrep \
  fzf \
  zoxide \
  zsh-autosuggestions \
  zsh-syntax-highlighting \
  xclip \
  wl-clipboard \
  xdotool \
  jq \
  unrar \
  p7zip-full

# Debian/Ubuntu renames these two to avoid clashing with other packages.
# Symlink them to the names these dotfiles (and most docs) expect.
install -d -o "$REAL_USER" -g "$REAL_USER" "$REAL_HOME/.local/bin"
[ -x /usr/bin/batcat ] && ln -sf /usr/bin/batcat "$REAL_HOME/.local/bin/bat"
[ -x /usr/bin/fdfind ] && ln -sf /usr/bin/fdfind "$REAL_HOME/.local/bin/fd"
chown -h "$REAL_USER:$REAL_USER" "$REAL_HOME/.local/bin/bat" "$REAL_HOME/.local/bin/fd" 2>/dev/null || true

echo "==> Installing fastfetch (not packaged for Ubuntu; grabbing the .deb release)"
if ! command -v fastfetch >/dev/null 2>&1; then
  FF_URL=$(curl -fsSL https://api.github.com/repos/fastfetch-cli/fastfetch/releases/latest \
    | grep -oE '"browser_download_url": *"[^"]*fastfetch-linux-amd64\.deb"' | cut -d'"' -f4)
  curl -fL -o /tmp/fastfetch.deb "$FF_URL"
  apt-get install -y /tmp/fastfetch.deb
  rm -f /tmp/fastfetch.deb
else
  echo "fastfetch already installed, skipping"
fi

echo "==> Adding the WezTerm apt repo (not in Ubuntu's own repos)"
if ! command -v wezterm >/dev/null 2>&1; then
  curl -fsSL https://apt.fury.io/wez/gpg.key | gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
  echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' \
    > /etc/apt/sources.list.d/wezterm.list
  apt-get update
  apt-get install -y wezterm
else
  echo "wezterm already installed, skipping"
fi

echo "==> Stowing dotfiles (all packages except aerospace, which is macOS-only)"
cd "$DOTFILES_DIR"
PACKAGES=(claude codex fastfetch ghostty herdr nvim opencode starship tmux vim wezterm zsh)
BACKUP_DIR="$REAL_HOME/.dotfiles-backup-$(date +%Y%m%d%H%M%S)"

# Ask stow what it would do first, and move aside exactly the real files/dirs
# it reports as conflicts, so it doesn't refuse to run.
for pkg in "${PACKAGES[@]}"; do
  conflicts=$(sudo -u "$REAL_USER" stow -n --target="$REAL_HOME" --dir="$DOTFILES_DIR" "$pkg" 2>&1 \
    | grep 'existing target is' | sed -E 's/.*: //')
  for rel in $conflicts; do
    target="$REAL_HOME/$rel"
    if [ -e "$target" ] || [ -L "$target" ]; then
      mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
      mv "$target" "$BACKUP_DIR/$rel"
      echo "backed up existing $target -> $BACKUP_DIR/$rel"
    fi
  done
done

sudo -u "$REAL_USER" stow --target="$REAL_HOME" --dir="$DOTFILES_DIR" "${PACKAGES[@]}"

echo
echo "==> Done."
echo "Backed-up originals (if any): $BACKUP_DIR"
echo "Start a new shell (or 'exec zsh') to pick everything up."
echo "Not installed by this script (already done, or skipped as macOS-only/optional):"
echo "  - Neovim, lazygit, yazi, herdr, nvm+Node, tpm: installed to ~/.local (see chat)"
echo "  - starship: already present"
echo "  - aerospace: macOS-only, not applicable on Linux"
echo "  - tmux plugins: open tmux and press <prefix> + I to fetch them via tpm"
