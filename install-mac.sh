#!/usr/bin/env bash
# Sets up zsh + oh-my-zsh + powerlevel10k on macOS and links the dotfiles from this repo.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZSH_DIR="$HOME/.oh-my-zsh"
ZSH_CUSTOM="${ZSH_CUSTOM:-$ZSH_DIR/custom}"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }

# --- Homebrew -------------------------------------------------------------
if ! command -v brew >/dev/null; then
  info "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

info "Installing packages"
# vim from Homebrew has +clipboard; node is needed by coc.nvim, ripgrep by :Rg
brew install git zsh vim node ripgrep eza redshift
brew install --cask font-meslo-lg-nerd-font || true

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
link "$DOTFILES/mac/.zshrc"      "$HOME/.zshrc"
link "$DOTFILES/mac/.zprofile"   "$HOME/.zprofile"
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
if [[ "$(dscl . -read "/Users/$USER" UserShell | awk '{print $2}')" != */zsh ]]; then
  info "Setting zsh as default shell"
  chsh -s /bin/zsh
fi

info "Done. Set your terminal font to 'MesloLGS Nerd Font', then run: exec zsh"
