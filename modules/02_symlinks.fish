#!/usr/bin/env fish

source "$HOME/.dotfiles/modules/_log.fish"

set -l DRY_RUN 0
for arg in $argv
    if test "$arg" = "--dry-run"
        set DRY_RUN 1
    end
end

set -l FORCE 0
for arg in $argv
    if test "$arg" = "--force"
        set FORCE 1
    end
end

log "🔗 Starting symlink creation..."

# Source logging (ensure it's available before logging anything)
if test -f "$DOTFILES/modules/_log.fish"
    source "$DOTFILES/modules/_log.fish"
end

# Ensure the wallpapers target directory exists
set -l pictures_wall_dir "$HOME/Pictures/wallpapers"
if not test -d "$pictures_wall_dir"
    mkdir -p "$pictures_wall_dir"
    log "📁 Created $pictures_wall_dir"
end

# Symlink definitions
set -l symlinks \
    "$HOME/.dotfiles/nvim:$HOME/.config/nvim" \
    "$HOME/.dotfiles/fish:$HOME/.config/fish" \
    "$HOME/.dotfiles/rofi:$HOME/.config/rofi" \
    "$HOME/.dotfiles/wallpapers:$pictures_wall_dir" \
    "$HOME/.dotfiles/modules/aliases.fish:$HOME/.config/fish/conf.d/aliases.fish"

# Process each pair
for pair in $symlinks
    set -l src (echo $pair | cut -d ':' -f 1)
    set -l dest (eval echo (echo $pair | cut -d ':' -f 2))

    if test -e $dest
        if test $FORCE -eq 1
            if test $DRY_RUN -eq 1
                log "[DRY RUN] Would remove $dest before linking."
            else
                log "⚠️  Overwriting existing file: $dest"
                rm -rf "$dest"
            end
        else
            log "⚠️  Skipping $dest — already exists. Use --force to override."
            continue
        end
    end

    if test $DRY_RUN -eq 1
        log "[DRY RUN] Would link $src → $dest"
    else
        ln -s "$src" "$dest"
        log "📎 Linked $src → $dest"
    end
end

log "✅ Symlink setup completed"
