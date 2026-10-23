# Homebrew (Apple Silicon: /opt/homebrew, Intel: /usr/local)
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv zsh)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv zsh)"
fi

# Docker Desktop
[[ -d "$HOME/.docker/bin" ]] && export PATH="$PATH:$HOME/.docker/bin"

# Python 3.14 (python.org installer)
[[ -d /Library/Frameworks/Python.framework/Versions/3.14/bin ]] && \
  export PATH="/Library/Frameworks/Python.framework/Versions/3.14/bin:$PATH"
