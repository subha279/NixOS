#!/usr/bin/env bash

set -euo pipefail

WALLPAPER_DIR="$HOME/Wallpapers"
CACHE_DIR="$HOME/.cache/wallust"
RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

mkdir -p "$CACHE_DIR"

# ==================================================
# Notifications
# ==================================================

notify() {
  notify-send "$1" "$2" >/dev/null 2>&1 || true
}

# ==================================================
# Validate wallpaper directory
# ==================================================

if [[ ! -d "$WALLPAPER_DIR" ]]; then
  notify "Wallpaper" "Directory not found: $WALLPAPER_DIR"
  exit 1
fi

# ==================================================
# Find wallpapers
# ==================================================

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
  notify "Wallpaper" "No wallpapers found in $WALLPAPER_DIR"
  exit 1
fi

# ==================================================
# Build Fuzzel menu
#
# Column 1 = display name
# Column 2 = absolute wallpaper path
#
# Rofi extended dmenu protocol:
# \0icon\x1f<path>
# ==================================================

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

# ==================================================
# Fuzzel configuration
# ==================================================

FUZZEL_CONFIG="$CACHE_DIR/fuzzel.ini"

if [[ -f "$FUZZEL_CONFIG" ]]; then
  FUZZEL_ARGS=(
    "--config=$FUZZEL_CONFIG"
  )
else
  FUZZEL_ARGS=()
fi

# ==================================================
# Wallpaper picker
# ==================================================

selected="$(
  menu |
    fuzzel \
      "${FUZZEL_ARGS[@]}" \
      --dmenu \
      --prompt "    " \
      --placeholder "Choose wallpaper..." \
      --with-nth=1 \
      --accept-nth=2 \
      --lines=7 \
      --width=55 \
      --cache="$CACHE_DIR/fuzzel-wallpapers"
)"
# Cancel
[[ -z "$selected" ]] && exit 0

# ==================================================
# Validate selection
# ==================================================

if [[ ! -f "$selected" ]]; then
  notify "Wallpaper" "Selected wallpaper does not exist"
  exit 1
fi

# ==================================================
# Generate Wallust colors
# ==================================================

wallust run "$selected" >/dev/null 2>&1

# ==================================================
# Change wallpaper
# ==================================================

awww img "$selected" \
  --transition-type grow \
  --transition-duration 0.7 \
  >/dev/null 2>&1

# ==================================================
# Update running Kitty terminals
# ==================================================

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

# ==================================================
# Remember current wallpaper
# ==================================================

printf '%s\n' "$selected" \
  >"$CACHE_DIR/current-wallpaper"

# ==================================================
# Reload Hyprland
# ==================================================

hyprctl reload >/dev/null 2>&1 || true

# ==================================================
# Notification
# ==================================================

notify \
  "Wallust" \
  "Wallpaper changed to $(basename "$selected")"
