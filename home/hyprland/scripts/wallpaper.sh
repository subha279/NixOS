#!/usr/bin/env bash

set -euo pipefail

# ============================================================================
# Aurora Wallpaper Picker
# ============================================================================
#
# Wallpaper selection is completely independent from theming.
#
# Wallpaper:
#   ~/Wallpapers
#
# State:
#   ~/.cache/aurora/current-wallpaper
#
# Theme colors:
#   lib/themes.nix
#
# IMPORTANT:
#   This script NEVER generates colors.
#   This script NEVER invokes legacy dynamic color generator.
# ============================================================================

WALLPAPER_DIR="$HOME/Wallpapers"
CACHE_DIR="$HOME/.cache/aurora"
CURRENT_WALLPAPER="$CACHE_DIR/current-wallpaper"

mkdir -p "$CACHE_DIR"

# ============================================================================
# Notifications
# ============================================================================

notify() {
    notify-send "$1" "$2" >/dev/null 2>&1 || true
}

# ============================================================================
# Validate wallpaper directory
# ============================================================================

if [[ ! -d "$WALLPAPER_DIR" ]]; then
    notify \
        "Wallpaper" \
        "Directory not found: $WALLPAPER_DIR"

    exit 1
fi

# ============================================================================
# Find wallpapers
# ============================================================================

mapfile -t wallpapers < <(
    find "$WALLPAPER_DIR" \
        -type f \
        \( \
            -iname '*.jpg' \
            -o -iname '*.jpeg' \
            -o -iname '*.png' \
            -o -iname '*.webp' \
        \) |
        sort
)

if ((${#wallpapers[@]} == 0)); then
    notify \
        "Wallpaper" \
        "No wallpapers found in $WALLPAPER_DIR"

    exit 1
fi

# ============================================================================
# Build Fuzzel menu
# ============================================================================

menu() {

    local wallpaper
    local name

    for wallpaper in "${wallpapers[@]}"; do

        name="$(basename "$wallpaper")"

        printf '%s\t%s\0icon\x1f%s\n' \
            "$name" \
            "$wallpaper" \
            "$wallpaper"

    done
}

# ============================================================================
# Wallpaper picker
# ============================================================================
#
# Fuzzel uses the Aurora-generated theme:
#
#   ~/.config/aurora/active-fuzzel.conf
#
# through the normal Fuzzel configuration.
# ============================================================================

selected="$(
    menu |
        fuzzel \
            --dmenu \
            --prompt "    " \
            --placeholder "Choose wallpaper..." \
            --with-nth=1 \
            --accept-nth=2 \
            --lines=7 \
            --width=55 \
            --cache="$CACHE_DIR/fuzzel-wallpapers"
)"

# ============================================================================
# Cancel
# ============================================================================

[[ -z "$selected" ]] && exit 0

# ============================================================================
# Validate selection
# ============================================================================

if [[ ! -f "$selected" ]]; then

    notify \
        "Wallpaper" \
        "Selected wallpaper does not exist"

    exit 1
fi

# ============================================================================
# Change wallpaper
# ============================================================================

awww img "$selected" \
    --transition-type grow \
    --transition-duration 0.7 \
    >/dev/null 2>&1

# ============================================================================
# Remember current wallpaper
# ============================================================================

printf '%s\n' "$selected" > "$CURRENT_WALLPAPER"

# ============================================================================
# Reload Hyprland
# ============================================================================
#
# Wallpaper changes do not regenerate the theme.
#
# The Aurora theme remains controlled by:
#
#   lib/themes.nix
#
# ============================================================================

hyprctl reload \
    >/dev/null 2>&1 || true

# ============================================================================
# Notification
# ============================================================================

notify \
    "Wallpaper" \
    "Wallpaper changed to $(basename "$selected")"
