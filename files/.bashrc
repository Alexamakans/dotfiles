export DOTFILES=$HOME/code/github.com/Alexamakans/dotfiles

alias ns="sudo nixos-rebuild switch --flake ~/dotfiles#$(hostname) --option experimental-features 'nix-command flakes'"
alias nsbuild="sudo nixos-rebuild build --flake ~/dotfiles#$(hostname) --option experimental-features 'nix-command flakes'"
alias nstest="sudo nixos-rebuild test --flake ~/dotfiles#$(hostname) --option experimental-features 'nix-command flakes'"
alias dots="cd ~/dotfiles"

# git aliases

alias gs="git status"
alias gp="git pull"
alias gps="git push"
alias gc="git commit"
alias gca="git commit -am"
alias gco="git checkout"
alias gl="git log"
alias gd="git diff"
alias gpu='git push -u origin $(git rev-parse --abbrev-ref HEAD)'
alias gpom='git pull origin $(git remote show origin | sed -n "/HEAD branch/s/.*: //p")'

# git env vars

export GIT_EDITOR=nvim

# nvim aliases

alias n="nvim ."
alias nt="nvim"

# TODO: source entire dir
source $HOME/dotfiles/files/.bashrc.d/10-nvim-profile-selector-functions
