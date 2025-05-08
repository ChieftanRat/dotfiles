#!/usr/bin/env fish

set -l args $argv
set -l DRY_RUN (contains --dry-run $args)
set -l FORCE (contains --force $args)

set repo "$HOME/.dotfiles"
set config_dir "$HOME/.config"

# Function to log with emoji
function log
    echo -e "🌀 $argv"
end

# Function to handle symlink creation with checks
function link_file
    set -l src $argv[1]
    set -l dest $argv[2]

    if test -L $dest
        log "Symlink already exists: $dest"
        return
    else if test -e $dest
        if test $FORCE
            log "⚠️ Overwriting existing file: $dest"
            and rm -rf $dest
        else
            log "Skipping $dest — regular file/folder already exists. Use --force to override."
            return
        end
    end

    if test $DRY_RUN
        log "[DRY RUN] Would link $src → $dest"
    else
        ln -s $src $dest
        log "Linked $src → $dest"
    end
end

# Symlink directories (fish, nvim, rofi)
for folder in fish nvim rofi
    set src "$repo/$folder"
    set dest "$config_dir/$folder"
    link_file $src $dest
end

# Standalone file: 