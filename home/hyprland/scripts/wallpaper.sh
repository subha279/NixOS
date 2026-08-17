#!/usr/bin/env bash

set -euo pipefail

# ============================================================================
# Aurora Wallpaper Picker
# ============================================================================
#
# Wallpaper selection is completely independent from theming.
#
# Wallpaper source:
#   ~/Wallpapers
#
# Aurora state:
#   ~/.cache/aurora/current-wallpaper
#
# Wallpaper thumbnails:
#   ~/.cache/aurora/wallpaper-thumbnails
#
# Theme:
#   ~/.config/aurora/active-theme.lua
#
# IMPORTANT:
#   This script NEVER generates colors.
#   This script NEVER invokes Wallust.
#   Wallpaper selection and theme selection remain separate.
# ============================================================================

WALLPAPER_DIR="$HOME/Wallpapers"

AURORA_CACHE="$HOME/.cache/aurora"

CURRENT_WALLPAPER="$AURORA_CACHE/current-wallpaper"

THUMBNAIL_DIR="$AURORA_CACHE/wallpaper-thumbnails"

FUZZEL_CACHE="$AURORA_CACHE/fuzzel-wallpapers"

THUMBNAIL_SIZE="420x260"

mkdir -p \
    "$AURORA_CACHE" \
    "$THUMBNAIL_DIR"

# ============================================================================
# Notifications
# ============================================================================

notify() {
    notify-send "$1" "$2" >/dev/null 2>&1 || true
}

# ============================================================================
# Dependency check
# ============================================================================

if ! command -v awww >/dev/null 2>&1; then
    notify \
        "Wallpaper" \
        "awww is not installed"

    exit 1
fi

if ! command -v fuzzel >/dev/null 2>&1; then
    notify \
        "Wallpaper" \
        "Fuzzel is not installed"

    exit 1
fi

if ! command -v magick >/dev/null 2>&1; then
    notify \
        "Wallpaper" \
        "ImageMagick is required for wallpaper previews"

    exit 1
fi

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
#
# Supported:
#
#   JPG
#   JPEG
#   PNG
#   WEBP
#   GIF
#
# ImageMagick converts everything to PNG thumbnails for Fuzzel.
# ============================================================================

mapfile -t wallpapers < <(
    find "$WALLPAPER_DIR" \
        -type f \
        \( \
        -iname '*.jpg' \
        -o -iname '*.jpeg' \
        -o -iname '*.png' \
        -o -iname '*.webp' \
        -o -iname '*.gif' \
        \) \
        -print0 |
        sort -z |
        tr '\0' '\n'
)

if ((${#wallpapers[@]} == 0)); then

    notify \
        "Wallpaper" \
        "No wallpapers found in $WALLPAPER_DIR"

    exit 1
fi

# ============================================================================
# Thumbnail path
# ============================================================================
#
# We use SHA-256 of the absolute wallpaper path.
#
# This prevents problems with:
#
#   spaces
#   parentheses
#   unicode
#   duplicate filenames
#   nested directories
#
# Example:
#
#   ~/.cache/aurora/wallpaper-thumbnails/
#       8f2d....png
# ============================================================================

thumbnail_path() {

    local wallpaper="$1"

    local hash

    hash="$(
        printf '%s' "$wallpaper" |
            sha256sum |
            cut -d' ' -f1
    )"

    printf '%s/%s.png\n' \
        "$THUMBNAIL_DIR" \
        "$hash"
}

# ============================================================================
# Generate thumbnail
# ============================================================================
#
# Fuzzel's dmenu image protocol expects PNG/SVG icons.
#
# Therefore every wallpaper gets converted into a PNG thumbnail.
#
# The original wallpaper is NEVER modified.
# ============================================================================

generate_thumbnail() {

    local wallpaper="$1"

    local thumbnail="$2"

    # ------------------------------------------------------------------------
    # Reuse existing thumbnail when it is newer than the wallpaper.
    # ------------------------------------------------------------------------

    if [[ -f "$thumbnail" ]] &&
        [[ "$thumbnail" -nt "$wallpaper" ]]; then

        return 0
    fi

    # ------------------------------------------------------------------------
    # Create temporary file.
    # ------------------------------------------------------------------------

    local temporary

    temporary="${thumbnail}.tmp.$$"

    # ------------------------------------------------------------------------
    # Generate attractive cropped preview.
    #
    # -thumbnail keeps quality high while limiting dimensions.
    #
    # ^ means:
    #   fill the requested geometry
    #
    # extent crops the remaining excess.
    #
    # This gives Fuzzel consistent preview dimensions.
    # ------------------------------------------------------------------------

    if magick \
        "$wallpaper" \
        -auto-orient \
        -thumbnail "${THUMBNAIL_SIZE}^" \
        -gravity center \
        -extent "$THUMBNAIL_SIZE" \
        -strip \
        -quality 88 \
        PNG:"$temporary" \
        2>/dev/null; then

        mv -f \
            "$temporary" \
            "$thumbnail"

        return 0

    fi

    # ------------------------------------------------------------------------
    # Thumbnail generation failed.
    # ------------------------------------------------------------------------

    rm -f "$temporary"

    return 1
}

# ============================================================================
# Build Fuzzel menu
# ============================================================================
#
# Format:
#
#   DISPLAY NAME<TAB>REAL WALLPAPER PATH
#       NUL icon separator
#           PNG THUMBNAIL
#
# Fuzzel displays:
#
#   DISPLAY NAME
#
# and returns:
#
#   REAL WALLPAPER PATH
#
# ============================================================================

menu() {

    local wallpaper

    local name

    local thumbnail

    for wallpaper in "${wallpapers[@]}"; do

        name="$(basename "$wallpaper")"

        thumbnail="$(thumbnail_path "$wallpaper")"

        # --------------------------------------------------------------------
        # Generate preview.
        # --------------------------------------------------------------------

        if generate_thumbnail \
            "$wallpaper" \
            "$thumbnail"; then

            printf \
                '%s\t%s\0icon\x1f%s\n' \
                "$name" \
                "$wallpaper" \
                "$thumbnail"

        else

            # ---------------------------------------------------------------
            # Even if preview generation fails, keep the wallpaper usable.
            # ---------------------------------------------------------------

            printf \
                '%s\t%s\n' \
                "$name" \
                "$wallpaper"

        fi

    done
}

# ============================================================================
# Wallpaper picker
# ============================================================================

selected="$(
    menu |
        fuzzel \
            --dmenu \
            --prompt "    " \
            --placeholder "Choose wallpaper..." \
            --with-nth=1 \
            --accept-nth=2 \
            --match-nth=1 \
            --lines=7 \
            --width=55 \
            --cache="$FUZZEL_CACHE"
)"

# ============================================================================
# Cancel
# ============================================================================

if [[ -z "$selected" ]]; then
    exit 0
fi

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
# Apply wallpaper
# ============================================================================

if ! awww img "$selected" \
    --transition-type grow \
    --transition-duration 0.7 \
    >/dev/null 2>&1; then

    notify \
        "Wallpaper" \
        "Failed to apply wallpaper"

    exit 1
fi

# ============================================================================
# Remember current wallpaper
# ============================================================================

printf '%s\n' "$selected" >"$CURRENT_WALLPAPER"

# ============================================================================
# Reload Hyprland
# ============================================================================
#
# This does NOT regenerate the theme.
#
# Aurora theme selection remains independent.
# ============================================================================

hyprctl reload \
    >/dev/null 2>&1 || true

# ============================================================================
# Notification
# ============================================================================

notify \
    "Wallpaper" \
    "Wallpaper changed to $(basename "$selected")"
