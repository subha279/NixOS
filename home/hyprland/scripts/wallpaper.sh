#!/usr/bin/env bash

set -euo pipefail


# ============================================================
# Aurora Wallpaper Picker
# ============================================================
#
# Wallpaper selection uses Fuzzel.
#
# Fuzzel's theme comes from:
#
#   ~/.config/aurora/active-fuzzel.conf
#
# Wallust is temporarily retained below for the remaining
# legacy dynamic-color pipeline.
#
# It will be removed in a later migration step.
#
# ============================================================


WALLPAPER_DIR="$HOME/Wallpapers"

CACHE_DIR="$HOME/.cache/wallust"

RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"


mkdir -p "$CACHE_DIR"


# ============================================================
# Notifications
# ============================================================

notify() {
    notify-send "$1" "$2" >/dev/null 2>&1 || true
}


# ============================================================
# Validate Wallpaper Directory
# ============================================================

if [[ ! -d "$WALLPAPER_DIR" ]]; then

    notify \
        "Wallpaper" \
        "Directory not found: $WALLPAPER_DIR"

    exit 1

fi


# ============================================================
# Find Wallpapers
# ============================================================

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


# ============================================================
# Build Fuzzel Menu
# ============================================================
#
# Column 1:
#   Display name
#
# Column 2:
#   Absolute wallpaper path
#
# Icon:
#   Wallpaper itself
#
# ============================================================

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


# ============================================================
# Wallpaper Picker
# ============================================================
#
# We deliberately do NOT pass a Wallust Fuzzel configuration.
#
# Fuzzel loads:
#
#   ~/.config/fuzzel/fuzzel.ini
#
# which includes:
#
#   ~/.config/aurora/active-fuzzel.conf
#
# ============================================================

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


# ============================================================
# Cancel
# ============================================================

[[ -z "$selected" ]] && exit 0


# ============================================================
# Validate Selection
# ============================================================

if [[ ! -f "$selected" ]]; then

    notify \
        "Wallpaper" \
        "Selected wallpaper does not exist"

    exit 1

fi


# ============================================================
# Generate Wallust Colors
# ============================================================
#
# TEMPORARY
#
# Wallust is still used by the remaining legacy theme
# consumers. This will be removed after those consumers
# have migrated to Aurora.
#
# ============================================================

if command -v wallust >/dev/null 2>&1; then

    wallust run "$selected" \
        >/dev/null 2>&1 || true

fi


# ============================================================
# Change Wallpaper
# ============================================================

awww img "$selected" \
    --transition-type grow \
    --transition-duration 0.7 \
    >/dev/null 2>&1


# ============================================================
# Update Running Kitty Terminals
# ============================================================
#
# TEMPORARY LEGACY WALLUST SUPPORT
#
# Aurora theme switching already handles Kitty directly.
#
# This block is retained only because wallpaper changes still
# generate Wallust colors for the old pipeline.
#
# It will be removed when Wallust is completely retired.
#
# ============================================================

KITTY_COLORS="$CACHE_DIR/kitty.conf"


if [[ -f "$KITTY_COLORS" ]]; then


    while IFS= read -r socket; do


        kitten @ \
            --to "unix:$socket" \
            set-colors \
            --configured \
            --all \
            "$KITTY_COLORS" \
            >/dev/null 2>&1 || true


    done < <(

        find "$RUNTIME_DIR" \
            -maxdepth 1 \
            -type s \
            -name 'kitty-*' \
            -printf '%p\n' \
            2>/dev/null

    )

fi


# ============================================================
# Remember Current Wallpaper
# ============================================================

printf '%s\n' "$selected" \
    > "$CACHE_DIR/current-wallpaper"


# ============================================================
# Reload Hyprland
# ============================================================
#
# The current Hyprland theme remains Wallust-driven for now.
#
# This will be removed from the wallpaper pipeline when
# Hyprland finishes migrating to Aurora.
#
# ============================================================

hyprctl reload \
    >/dev/null 2>&1 || true


# ============================================================
# Notification
# ============================================================

notify \
    "Wallpaper" \
    "Wallpaper changed to $(basename "$selected")"
