# dotfiles

zsh setup (oh-my-zsh, powerlevel10k, zsh-syntax-highlighting, eza aliases) and vim setup (vim-plug, coc.nvim, NERDTree, fzf, airline, onedark).

```
common/.p10k.zsh     powerlevel10k prompt config (shared)
common/vim/          .vimrc, coc-settings.json, keymap cheat sheet (shared)
mac/.zshrc           macOS zshrc
mac/.zprofile        Homebrew, Docker, Python PATH setup
linux/.zshrc         Linux zshrc (no osascript aliases, eza fallback)
linux/.zprofile      optional Linuxbrew / Docker PATH
install-mac.sh       macOS setup
install-linux.sh     Linux setup (apt / dnf / pacman / zypper)
```

## Install

```sh
git clone <repo-url> ~/dotfiles
cd ~/dotfiles
./install-mac.sh     # macOS
./install-linux.sh   # Linux
```

The scripts install packages, oh-my-zsh, the theme/plugin, a Nerd Font, vim-plug
and the vim plugins, then symlink the config files into `$HOME`. coc extensions
are installed by vim on first launch. Existing files are moved to
`~/.dotfiles-backup/<timestamp>/` first. Re-running is safe.

Machine-specific settings go in `~/.zshrc.local` (sourced at the end, not tracked).
