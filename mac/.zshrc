if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

if [[ -z "$CLAUDECODE" ]]; then
  alias ls='eza --icons --color=auto'
  alias ll='eza --icons -alF'
  alias la='eza --icons -A'
fi

#alias rm='trash-put'

alias szrc="source ~/.zshrc"
alias zrc="vim ~/.zshrc"
alias vrc="vim ~/.vimrc"
alias docs="cd ~/Documents"
alias desk="cd ~/Desktop"
alias night="redshift -O 2400"
alias day="redshift -x"

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

export EDITOR="vim"

unsetopt inc_append_history
unsetopt share_history

alias bg1='osascript -e "tell application \"Terminal\" to set current settings of front window to settings set \"bg1\""'
alias bg2='osascript -e "tell application \"Terminal\" to set current settings of front window to settings set \"bg2\""'

# Added by JetBrains IDE (only present on machines where it has been set up)
[[ -d "$HOME/.cmake-deps/cmake/mac/aarch64/bin" ]] && export PATH="$HOME/.cmake-deps/cmake/mac/aarch64/bin:$PATH"
[[ -d "$HOME/.cmake-deps/ninja/mac/aarch64" ]] && export PATH="$HOME/.cmake-deps/ninja/mac/aarch64:$PATH"

# Machine-specific overrides that should not live in the repo
[[ ! -f ~/.zshrc.local ]] || source ~/.zshrc.local
