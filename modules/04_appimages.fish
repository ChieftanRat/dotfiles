#!/usr/bin/env fish

# Load logging functions
source "$HOME/.dotfiles/modules/_log.fish"

# Allow dry-run mode
set dryrun (contains -- --dry-run $argv) && log "💡 Dry-run enabled. No changes will be made."

# Directory to store AppImages
set appimage_dir "$HOME/.local/bin/appimages"
set desktop_dir "$HOME/.local/share/applications"

mkdir -p "$appimage_dir" "$desktop_dir"

# Check internet
if not ping -c 1 archlinux.org > /dev/null 2>&1
    fatal "No internet connection. Skipping AppImage setup."
end

# Define AppImages [Name] [URL]
set appimages \
    "Equibop" \
    "https://github.com/Equicord/Equibop/releases/latest/download/Equibop-linux-x86_64.AppImage"

# Process entries two at a time
for i in (seq 1 2 (count $appimages))
    set name $appimages[$i]
    set url $appimages[(math $i + 1)]

    set filename "$name.AppImage"
    set path "$appimage_dir/$filename"
    set desktop_file "$desktop_dir/$name.desktop"

    # Download AppImage
    if not test -f "$path"
        log "⬇️  Downloading $name..."
        if test "$dryrun"
            log "[DRY RUN] Would curl $url to $path"
        else
            curl -L "$url" -o "$path"
            chmod +x "$path"
            log "✅ $name downloaded to $path"
        end
    else
        log "ℹ️  $name already exists at $path"
    end

    # Create desktop entry
    if not test -f "$desktop_file"
        log "📌 Creating desktop entry for $name..."
        if test "$dryrun"
            log "[DRY RUN] Would create $desktop_file"
        else
            echo "[Desktop Entry]
Type=Application
Name=$name
Exec=$path
Icon=application-default-icon
Terminal=false
Categories=Utility;" > "$desktop_file"
            update-desktop-database "$desktop_dir"
            log "✅ Desktop entry for $name created."
        end
    else
        log "ℹ️  Desktop entry for $name already exists."
    end
end
