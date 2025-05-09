# ========================
# 🐟 Custom Fish Config
# ========================
source /usr/share/cachyos-fish-config/cachyos-config.fish
# --- Zoxide override for 'cd'
if type -q zoxide
    zoxide init fish --cmd cd | source
end

# --- Aliases
alias nv='nvim'
alias dotfiles='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias dfs='dotfiles status -uno'
alias reload='source ~/.config/fish/config.fish'
alias ..='cd ..'
alias ...='cd ../..'

alias update='yay -Syu'
alias flatupdate='flatpak update'
alias reload='hyprctl reload'
alias ff='fastfetch'
alias cleanlog='rm ~/.dotfiles/logs/*.log'

# Safe Removals & Disk Cleanup
alias rm='rm -i'                         # Confirm before deleting
alias rmall='rm -rf'                     # Dangerous: use with care
alias cleanpkg='sudo pacman -Rns $(pacman -Qtdq)'  # Remove unused packages

# Script & Config Utilities
alias edconf='nv ~/.config/fish/config.fish'
alias eddot='nv ~/.dotfiles'
alias edboot='nv ~/.dotfiles/bootstrap.sh'
alias edlog='nv ~/.dotfiles/modules/_log.sh'

# File & Directory Management
alias mkd='mkdir -p'              # Create directory with parents
alias lt='ls -ltrh'               # Sorted by time, human readable
alias ll='ls -lah'                # Long list format including hidden
alias c='clear'                   # Quick clear

# Aesthetic: shorten prompt directory length
set -g fish_prompt_pwd_dir_length 2

# Optional machine overrides
if test -f ~/.dotfiles/.localrc
    source ~/.dotfiles/.localrc
end

set -Ux PATH $PATH /opt/nvim

# Source custom dotfiles aliases
if test -f ~/.dotfiles/modules/aliases.fish
    source ~/.dotfiles/modules/aliases.fish
end
