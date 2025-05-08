# ========================
# 🐟 Custom Fish Config
# ========================

# --- Zoxide override for 'cd'
if type -q zoxide
    zoxide init fish --cmd cd | source
end

# --- Aliases
alias nv='nvim'
alias dotfiles='git -C ~/.dotfiles'
alias reshell='source ~/.config/fish/config.fish'
alias ..='cd ..'
alias ...='cd ../..'

alias gs='git status'
alias gl='git log --oneline --graph --decorate --all'
alias ga='git add .'
alias gc='git commit -m'
alias gp='git push'
alias gpo='git push origin HEAD'

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

# Optional combined refresh alias
alias refreshall='source ~/.config/fish/config.fish'

# Aesthetic: shorten prompt directory length
set -g fish_prompt_pwd_dir_length 2

# Optional machine overrides
if test -f ~/.dotfiles/.localrc
    source ~/.dotfiles/.localrc
end
