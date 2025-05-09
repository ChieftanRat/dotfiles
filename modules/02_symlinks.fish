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

# Define list of source:target pairs
set -l symlinks \
    "$HOME/.dotfiles/nvim:~/.config/nvim" \
    "$HOME/.dotfiles/fish:~/.config/fish" \
    "$HOME/.dotfiles/rofi:~/.config/rofi"

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
