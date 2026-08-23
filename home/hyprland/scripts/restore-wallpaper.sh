#!/usr/bin/env bash

set -euo pipefail

# Aurora Wallpaper Restore

CACHE_FILE="$HOME/.cache/aurora/current-wallpaper"

# Nothing to restore

if [[ ! -f "$CACHE_FILE" ]]; then
    exit 0
fi

WALLPAPER="$(cat "$CACHE_FILE")"

# Wallpaper was removed

if [[ ! -f "$WALLPAPER" ]]; then
    exit 0
fi

# Give the Wayland session / awww daemon a moment

sleep 1

# Restore wallpaper

awww img "$WALLPAPER" \
    --transition-type none \
    >/dev/null 2>&1
