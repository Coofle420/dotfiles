# History
HISTFILE=~/.zsh_history; HISTSIZE=50000; SAVEHIST=50000
setopt SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE AUTO_CD INTERACTIVE_COMMENTS

# Completion
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

bindkey -e
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

export EDITOR=nvim
export PATH="$HOME/.local/bin:$PATH"

alias ls='ls --color=auto'; alias ll='ls -lah'; alias grep='grep --color=auto'
alias update='paru -Syu'; alias vi=nvim

[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ] && source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

command -v starship >/dev/null && eval "$(starship init zsh)"
command -v fastfetch >/dev/null && [[ -o interactive && $SHLVL -eq 1 ]] && fastfetch

# Discord: XWayland mode (push-to-talk keybinds) + GPU video encoding off (hardware AV1 encode crashed screen shares)
alias discord="/home/tree/.local/bin/discord-safe"

# opencode
export PATH=/home/tree/.opencode/bin:$PATH
