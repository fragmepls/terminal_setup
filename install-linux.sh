#!/usr/bin/env bash
# Sets up zsh + oh-my-zsh + powerlevel10k on Linux and links the dotfiles from this repo.
# Supports apt (Debian/Ubuntu), dnf (Fedora/RHEL), pacman (Arch) and zypper (openSUSE).
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZSH_DIR="$HOME/.oh-my-zsh"
ZSH_CUSTOM="${ZSH_CUSTOM:-$ZSH_DIR/custom}"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m==>\033[0m %s\n' "$*"; }

SUDO=""
[[ $EUID -ne 0 ]] && SUDO="sudo"

# --- Packages -------------------------------------------------------------
# Required packages must succeed; optional ones (eza, redshift) may be
# missing from older distro repos, so each is attempted on its own.
# vim variants below are built with +clipboard, needed for clipboard=unnamedplus.
REQUIRED=(zsh git curl unzip fontconfig)
OPTIONAL=(eza redshift)

if command -v apt-get >/dev/null; then
  $SUDO apt-get update
  REQUIRED+=(vim-gtk3 nodejs npm ripgrep)
  install() { $SUDO apt-get install -y "$@"; }
elif command -v dnf >/dev/null; then
  REQUIRED+=(vim-enhanced vim-X11 nodejs ripgrep)
  install() { $SUDO dnf install -y "$@"; }
elif command -v pacman >/dev/null; then
  $SUDO pacman -Sy --noconfirm
  REQUIRED+=(gvim nodejs npm ripgrep)
  install() { $SUDO pacman -S --needed --noconfirm "$@"; }
elif command -v zypper >/dev/null; then
  REQUIRED+=(gvim nodejs npm ripgrep)
  install() { $SUDO zypper install -y "$@"; }
else
  warn "Unknown package manager; install these manually: ${REQUIRED[*]} ${OPTIONAL[*]}"
  install() { return 1; }
fi

info "Installing packages"
install "${REQUIRED[@]}" || warn "Some required packages failed to install"
for pkg in "${OPTIONAL[@]}"; do
  install "$pkg" || warn "Could not install $pkg (optional, skipping)"
done

# --- Nerd font for powerlevel10k icons ------------------------------------
FONT_DIR="$HOME/.local/share/fonts"
if ! fc-list 2>/dev/null | grep -qi "MesloLGS Nerd Font"; then
  info "Installing MesloLGS Nerd Font"
  mkdir -p "$FONT_DIR"
  tmp="$(mktemp -d)"
  curl -fsSL -o "$tmp/Meslo.zip" \
    https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip
  unzip -oq "$tmp/Meslo.zip" -d "$FONT_DIR"
  rm -rf "$tmp"
  fc-cache -f "$FONT_DIR" >/dev/null || true
fi

# --- oh-my-zsh + plugins --------------------------------------------------
if [[ ! -d "$ZSH_DIR" ]]; then
  info "Installing oh-my-zsh"
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

clone() { # clone <url> <dest>
  if [[ -d "$2" ]]; then
    git -C "$2" pull --ff-only -q || true
  else
    git clone --depth=1 "$1" "$2"
  fi
}
info "Installing powerlevel10k and zsh-syntax-highlighting"
clone https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

# --- Symlinks -------------------------------------------------------------
link() { # link <repo file> <target>
  if [[ -e "$2" || -L "$2" ]] && [[ "$(readlink "$2")" != "$1" ]]; then
    mkdir -p "$BACKUP_DIR"
    mv "$2" "$BACKUP_DIR/"
    info "Backed up $2 -> $BACKUP_DIR/"
  fi
  ln -sfn "$1" "$2"
  info "Linked $2 -> $1"
}
link "$DOTFILES/linux/.zshrc"     "$HOME/.zshrc"
link "$DOTFILES/linux/.zprofile"  "$HOME/.zprofile"
link "$DOTFILES/common/.p10k.zsh" "$HOME/.p10k.zsh"

# --- Vim + vim-plug -------------------------------------------------------
mkdir -p "$HOME/.vim/autoload"
link "$DOTFILES/common/vim/.vimrc"              "$HOME/.vimrc"
link "$DOTFILES/common/vim/coc-settings.json"   "$HOME/.vim/coc-settings.json"
if [[ ! -f "$HOME/.vim/autoload/plug.vim" ]]; then
  info "Installing vim-plug"
  curl -fsSLo "$HOME/.vim/autoload/plug.vim" \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi
info "Installing vim plugins"
vim -E -s -u "$HOME/.vimrc" +'PlugInstall --sync' +qa </dev/null || true

# --- Default shell --------------------------------------------------------
ZSH_BIN="$(command -v zsh)"
if [[ "$(getent passwd "$USER" | cut -d: -f7)" != "$ZSH_BIN" ]]; then
  info "Setting zsh as default shell"
  grep -qx "$ZSH_BIN" /etc/shells || echo "$ZSH_BIN" | $SUDO tee -a /etc/shells >/dev/null
  # via sudo so it also works for passwordless users (cloud VMs, Lima, WSL)
  $SUDO chsh -s "$ZSH_BIN" "$USER" || warn "chsh failed; run: chsh -s $ZSH_BIN"
fi

info "Done. Set your terminal font to 'MesloLGS Nerd Font'."

# Drop straight into the new shell when run from a terminal
if [[ -t 0 && -t 1 ]]; then exec zsh -l; fi
