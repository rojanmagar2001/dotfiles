# aliases.zsh

# ------------------------------------------------------------------- System --
alias c='clear'
alias e='exit'
alias reload='exec zsh'
alias shutdown='sudo shutdown now'
alias restart='sudo reboot'
alias path='echo -e ${PATH//:/\\n}'

# ----------------------------------------------------------------------- ls --
alias ls='eza --icons=always --group-directories-first'
alias ll='eza --icons=always --group-directories-first --long --git'
alias la='eza --icons=always --group-directories-first --long --all --git'
alias lt='eza --icons=always --tree --level=2'

# -------------------------------------------------------------------- Files --
alias cat='bat --paging=never'
alias catp='bat --plain --paging=never'

# ---------------------------------------------------------------- Directories --
alias doc="cd $HOME/Documents"
alias dow="cd $HOME/Downloads"
alias dev="cd $HOME/development"
alias dots="cd $HOME/.dotfiles"

# ------------------------------------------------------------------ Editors --
alias vi='nvim'
alias v='nvim'

# --------------------------------------------------------------------- Git --
alias g='git'
alias ga='git add'
alias gf='git fetch'
alias gs='git status'
alias gss='git status -s'
alias gup='git fetch && git rebase'
alias gl='git pull'
alias glo='git pull origin'
alias gb='git branch'
alias gbr='git branch -r'
alias gd='git diff'
alias gds='git diff --staged'
alias gco='git checkout'
alias gcob='git checkout -b'
alias gre='git remote'
alias gres='git remote show'
alias glg='git log --graph --max-count=10 --decorate --pretty=oneline --abbrev-commit'
alias gm='git merge'
alias gp='git push'
alias gpo='git push origin'
alias gc='git commit -v'
alias gcm='git commit -m'
alias gcmnv='git commit --no-verify -m'
alias gcanenv='git commit --amend --no-edit --no-verify'
alias gtd='git tag --delete'
alias gtdr='git tag --delete origin'

# Git + fzf. See functions.zsh for the pickers these wrap.
alias gafzf='git ls-files -m -o --exclude-standard | grep -v "__pycache__" | fzf -m --print0 | xargs -0 -o -t git add'
alias grmfzf='git ls-files -m -o --exclude-standard | fzf -m --print0 | xargs -0 -o -t git rm'
alias grfzf='git diff --name-only | fzf -m --print0 | xargs -0 -o -t git restore'
alias grsfzf='git diff --name-only | fzf -m --print0 | xargs -0 -o -t git restore --staged'
alias gcofzf='git branch | sed "s/^[* ] //" | fzf | xargs git checkout'

alias lg='lazygit'

# ------------------------------------------------------------------- Docker --
alias d='docker'
alias dc='docker compose'
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'

# --------------------------------------------------------------- Kubernetes --
alias k='kubectl'

# ---------------------------------------------------------------------- Misc --
alias tf='terraform'
