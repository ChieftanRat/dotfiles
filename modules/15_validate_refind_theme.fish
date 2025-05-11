#!/usr/bin/env fish
set -euo pipefail

function validate_refind_theme
    if not set -q argv[1]
        echo "Usage: validate_refind_theme.fish <theme-name>"
        return 1
    end

    set theme $argv[1]
    set theme_dir /boot/EFI/refind/themes/$theme
    set theme_conf $theme_dir/theme.conf

    echo "🔍 Validating theme: $theme"
    if test -f $theme_conf
        echo "✅ Found: $theme_conf"
    else
        echo "❌ theme.conf not found at $theme_conf"
        return 1
    end

    echo "--- Asset Check ---"
    set missing 0
    grep -Eo 'themes/[^ ]+\.(png|jpg|bmp|ttf|conf)' $theme_conf | while read -l rel_path
        set full_path /boot/EFI/refind/$rel_path
        if test -f $full_path
            echo "✅ Found: $rel_path"
        else
            echo "❌ Missing: $rel_path"
            set missing 1
        end
    end

    if test $missing -eq 1
        echo "🚨 Some assets are missing!"
        return 1
    else
        echo "🎉 All assets accounted for."
        return 0
    end
end

validate_refind_theme $argv
