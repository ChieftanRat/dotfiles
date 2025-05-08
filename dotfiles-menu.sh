#!/bin/bash
set -euo pipefail

# Set paths
DOTFILES="$HOME/.dotfiles"
MODULES="$DOTFILES/modules"
LOG_DIR="$DOTFILES/logs"
LOG_FILE="$LOG_DIR/menu.log"

# Setup detection
SETUP_FLAG="$DOTFILES/.setup_done"
IS_FIRST_RUN=true
if [ -f "$SETUP_FLAG" ]; then
    IS_FIRST_RUN=false
fi

# Load shared helpers (if available)
if [ -f "$MODULES/_env.sh" ]; then
    source "$MODULES/_env.sh"
else
    # Fallback ANSI colors
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    CYAN='\033[0;36m'
    NC='\033[0m'
    echo -e "${YELLOW}⚠ Missing _env.sh — continuing with fallback colors.${NC}"
fi

# Basic fallback fatal() if _log.sh hasn't been sourced yet
if ! type fatal &>/dev/null; then
  fatal() {
    echo -e "${RED}✖ $1${NC}"
    exit 1
  }
fi

# Basic menu (for new users)
function show_basic_menu() {
    clear
    echo -e "${CYAN}⚙ Dotfiles Dashboard - $(date '+%A, %d %B %Y | %I:%M %p') [User: $(whoami)]${NC}"
    echo
    echo "1) Run full bootstrap"
    echo "2) Install Flatpak"
    echo "3) Apply SDDM theme"
    echo "4) Set wallpaper"
    echo "5) Help"
    echo "6) Exit"
	echo
}

# Advanced menu (after setup complete)
function show_advanced_menu() {
    clear
    echo -e "${CYAN}⚙ Dotfiles Dashboard - $(date '+%A, %d %B %Y | %I:%M %p') [User: $(whoami)]${NC}"
    echo
    echo "1) Run full bootstrap"
    echo "2) Install Flatpak"
    echo "3) Apply SDDM theme"
    echo "4) Set wallpaper"
    echo "5) Switch cursors"
    echo "6) Manual dotfiles sync"
    echo "7) Update Flatpaks"
    echo "8) Clean logs older than 7 days"
    echo "9) Smart dotfiles sync (feature branch aware)"
    echo "10) Safe dotfiles sync (stash-aware)"
    echo "11) Cleanup: stashes & old logs"
    echo "12) View CLI flag reference for dotfiles tools"
    echo "13) Dry run: Preview dotfiles sync changes"
    echo "14) Refresh dotfiles repo"
    echo "15) Help"
    echo "16) Exit"
}

# Help info
function show_help() {
    clear
	echo
    echo -e "${CYAN}${BOLD}HELP MENU:${NC}"
    if [ "$IS_FIRST_RUN" = true ]; then
        echo "1: Bootstrap your dotfiles (initial setup)"
        echo "2: Install Flatpak support"
        echo "3: Apply SDDM login screen theme"
        echo "4: Set a desktop wallpaper"
        echo "5: Show this help screen"
        echo "6: Exit this menu"
    else
        echo "1–4: Same as above"
        echo "5: Switch your cursor theme"
        echo "6: Manually push/pull dotfiles"
        echo "7: Flatpak system updates"
        echo "8: Clean logs (older than 7 days)"
        echo "9: Branch-aware dotfiles sync"
        echo "10: Safe sync (stash-aware)"
        echo "11: Clean stashes and logs"
        echo "12: CLI flags reference for your dotfiles tools"
        echo "13: Dry run: preview sync changes"
        echo "14: Refresh your dotfiles repo"
        echo "15: This help screen"
        echo "16: Exit"
    fi
    echo
    read -n 1 -s -r -p "Press any key to return to the menu..."
}

# Loop menu
while true; do
    if [ "$IS_FIRST_RUN" = true ]; then
        show_basic_menu
    else
        show_advanced_menu
    fi

    read -p "Choose an option: " opt

    case "$opt" in
        1)  [ -f "$DOTFILES/bootstrap.sh" ] && bash "$DOTFILES/bootstrap.sh" && touch "$SETUP_FLAG" || fatal "[MISSING] bootstrap.sh" ;;
        2)  [ -f "$MODULES/03_flatpaks.sh" ] && bash "$MODULES/03_flatpaks.sh" || fatal "[MISSING] 03_flatpaks.sh" ;;
        3)  [ -f "$MODULES/05_sddm_theme.sh" ] && bash "$MODULES/05_sddm_theme.sh" || fatal "[MISSING] 05_sddm_theme.sh" ;;
        4)  [ -f "$MODULES/10_set_wallpaper.sh" ] && bash "$MODULES/10_set_wallpaper.sh" || fatal "[MISSING] 10_set_wallpaper.sh" ;;
        5)  [ "$IS_FIRST_RUN" = true ] && show_help || ([ -f "$MODULES/12_cursor_switcher.sh" ] && bash "$MODULES/12_cursor_switcher.sh" || fatal "[MISSING] 12_cursor_switcher.sh") ;;
        6)  [ "$IS_FIRST_RUN" = true ] && { echo -e "${GREEN}Exiting... Thank you!${NC}"; break; } || ([ -f "$MODULES/sync/dotfiles-sync.sh" ] && bash "$MODULES/sync/dotfiles-sync.sh" || fatal "[MISSING] dotfiles-sync.sh") ;;
        7)  [ -f "$MODULES/03_flatpaks.sh" ] && bash "$MODULES/03_flatpaks.sh" || fatal "[MISSING] 03_flatpaks.sh" ;;
        8)  [ -f "$MODULES/14_log_cleanup.sh" ] && bash "$MODULES/14_log_cleanup.sh" || fatal "[MISSING] 14_log_cleanup.sh" ;;
        9)  [ -f "$MODULES/sync/dotfiles-sync.sh" ] && bash "$MODULES/sync/dotfiles-sync.sh" || fatal "[MISSING] dotfiles-sync.sh" ;;
        10) [ -f "$MODULES/sync/dotfiles-sync-safe.sh" ] && bash "$MODULES/sync/dotfiles-sync-safe.sh" || fatal "[MISSING] dotfiles-sync-safe.sh" ;;
        11) [ -f "$MODULES/sync/dotfiles-cleanup.sh" ] && bash "$MODULES/sync/dotfiles-cleanup.sh" || fatal "[MISSING] dotfiles-cleanup.sh" ;;
        12)
            clear
            echo ""
            echo "📘 CLI Flag Reference"
            echo ""
            echo "➡ dotfiles-cleanup.sh"
            echo "  --logs-only       Only archive/remove logs"
            echo "  --stashes-only    Only remove autosync Git stashes"
            echo "  --links-only      Only remove orphaned symlinks"
            echo "  --days <N>        Change log retention (default: 7)"
            echo "  --silent          Skip all prompts"
            echo "  --force           Force cleanup without confirmation"
            echo "  --no-archive      Delete logs instead of archiving"
            echo ""
            echo "➡ dotfiles-view-logs.sh"
            echo "  --index 1 3 5     Select archive(s) by number"
            echo "  --filter <word>   Filter logs by name (e.g., sync)"
            echo "  --preview <file>  View specific log from temp/"
            echo "  --silent          Extract without prompts or viewing"
            echo "  --keep            Keep extracted logs after viewing"
            echo ""
            read -n 1 -s -r -p "Press any key to return to menu"
            ;;
		13)
		{
			echo -e "\n🧪 Running dry run for dotfiles sync..."
			bash "$HOME/.dotfiles/modules/dotfiles-sync.sh" --dry-run
			read -n 1 -s -r -p "Press any key to return to the menu"
		}
		;;

		14)
		{
			git -C "$DOTFILES" pull --rebase \
				&& echo -e "${GREEN}✓ Repo refreshed!${NC}" \
				|| fatal "[ERROR] Git pull failed."

			read -n 1 -s -r -p "Press any key to return to menu"
		}
		;;

        15) show_help ;;
        16) echo -e "${GREEN}Exiting... Thank you for using the dotfiles manager!${NC}"; break ;;
        *)  echo -e "${RED}Invalid choice. Try again.${NC}"; sleep 1 ;;
    esac
done
