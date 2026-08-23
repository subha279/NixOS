#!/usr/bin/env bash

# Aurora NixOS Configuration Validator

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

FAILED=0

# UI

RESET='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'

CYAN='\033[1;36m'
MAGENTA='\033[1;35m'
GREEN='\033[1;32m'
RED='\033[1;31m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'

ok() {
    printf "  ${GREEN}✓${RESET} %s\n" "$1"
}

fail() {
    printf "  ${RED}✗${RESET} %s\n" "$1"
    FAILED=1
}

info() {
    printf "  ${YELLOW}!${RESET} %s\n" "$1"
}

section() {
    printf "\n${MAGENTA}${BOLD}==>${RESET} ${BOLD}%s${RESET}\n" "$1"
}

subsection() {
    printf "  ${BLUE}•${RESET} ${BOLD}%s${RESET}\n" "$1"
}

separator() {
    printf "${DIM}────────────────────────────────────────────────────────────${RESET}\n"
}

# Cleanup

cleanup() {
    rm -f \
        "${FLAKE_LOG:-}" \
        "${NVIM_LOG:-}" \
        "${LUA_LOG:-}" \
        2>/dev/null || true
}

trap cleanup EXIT

# Header

clear 2>/dev/null || true

printf "${CYAN}${BOLD}"
printf '╭────────────────────────────────────────────────────────────╮\n'
printf '│                                                            │\n'
printf '│              Aurora NixOS Configuration Check              │\n'
printf '│                                                            │\n'
printf '╰────────────────────────────────────────────────────────────╯\n'
printf "${RESET}"

printf "\n"
printf "${DIM}Repository:${RESET} %s\n" "$ROOT"
printf "${DIM}Branch:${RESET}     %s\n" \
    "$(git branch --show-current 2>/dev/null || printf 'unknown')"

# 1. Repository

section "Repository"

if git rev-parse --show-toplevel >/dev/null 2>&1; then
    ok "Git repository detected"
else
    fail "Not inside a Git repository"
fi

# 2. Flake

section "Flake"

FLAKE_LOG="$(mktemp)"

if nix flake check --no-build >"$FLAKE_LOG" 2>&1; then

    ok "Flake evaluation passed"

    if grep -qi "dirty" "$FLAKE_LOG"; then
        info "Git tree is dirty"
    fi

else

    fail "Flake check failed"

    printf "\n"
    cat "$FLAKE_LOG"

fi

# 3. Nix syntax

section "Nix files"

NIX_FAILED=0
NIX_COUNT=0

while IFS= read -r -d '' file; do

    NIX_COUNT=$((NIX_COUNT + 1))

    if ! nix-instantiate --parse "$file" >/dev/null 2>&1; then

        printf "  ${RED}✗${RESET} Invalid Nix syntax: %s\n" "$file"

        NIX_FAILED=1

    fi

done < <(
    find . \
        -type f \
        -name '*.nix' \
        -not -path './.git/*' \
        -print0
)

if [[ "$NIX_FAILED" -eq 0 ]]; then

    ok "All $NIX_COUNT Nix files parse correctly"

else

    fail "Nix syntax errors detected"

fi

# 4. Required files

section "Required files"

required_files=(

    "flake.nix"

    "hosts/laptop/default.nix"
    "hosts/laptop/hardware-configuration.nix"

    "home/default.nix"

    "home/neovim/default.nix"
    "home/neovim/config/init.lua"

    "home/hyprland/default.nix"
    "home/hyprland/hyprland.lua"

    "home/quickshell/default.nix"
    "home/quickshell/config/shell.qml"

    # Aurora theme architecture
    "lib/themes.nix"
    "home/theme/default.nix"

    # Wallpaper
    "home/hyprland/scripts/restore-wallpaper.sh"

)

for file in "${required_files[@]}"; do

    if [[ -f "$file" ]]; then

        ok "$file"

    else

        fail "Missing: $file"

    fi

done

# 5. Neovim files

section "Neovim"

nvim_files=(

    "home/neovim/config/init.lua"

    "home/neovim/config/lua/core/options.lua"
    "home/neovim/config/lua/core/keymaps.lua"
    "home/neovim/config/lua/core/autocmds.lua"

    "home/neovim/config/lua/lsp/init.lua"

)

for file in "${nvim_files[@]}"; do

    if [[ -f "$file" ]]; then

        ok "$file"

    else

        fail "Missing Neovim file: $file"

    fi

done

# 6. Real Neovim configuration

section "Neovim configuration"

NVIM_LOG="$(mktemp)"

if command -v nvim >/dev/null 2>&1; then

    if nvim \
        --headless \
        -u "$ROOT/home/neovim/config/init.lua" \
        '+qa!' \
        >"$NVIM_LOG" 2>&1; then

        ok "Neovim configuration loads"

    else

        fail "Neovim configuration failed to load"

        if [[ -s "$NVIM_LOG" ]]; then
            cat "$NVIM_LOG"
        fi

    fi

else

    fail "Neovim is not available"

fi

# 7. Lua

section "Lua"

LUA_LOG="$(mktemp)"

if command -v nvim >/dev/null 2>&1; then

    if nvim \
        --headless \
        -u NONE \
        "+lua local files = vim.fn.glob('$ROOT/home/**/*.lua', false, true); for _, f in ipairs(files) do local fn, err = loadfile(f); if not fn then error(f .. ': ' .. err) end end" \
        '+qa!' \
        >"$LUA_LOG" 2>&1; then

        ok "Lua files parse correctly"

    else

        fail "Lua syntax errors detected"

        cat "$LUA_LOG"

    fi

else

    info "Neovim unavailable — Lua check skipped"

fi

# 8. Quickshell

section "Quickshell"

if command -v qs >/dev/null 2>&1; then

    if systemctl --user is-active --quiet quickshell.service; then

        ok "Quickshell service is running"

    else

        info "Quickshell service is not currently running"

    fi

else

    fail "Quickshell (qs) is not available"

fi

# 9. Hyprland

section "Hyprland"

if command -v hyprctl >/dev/null 2>&1; then

    HYPR_ERRORS="$(hyprctl configerrors 2>/dev/null || true)"

    if [[ -z "$HYPR_ERRORS" ]] ||
        grep -qiE "no errors|no error" <<<"$HYPR_ERRORS"; then

        ok "No Hyprland configuration errors reported"

    else

        fail "Hyprland configuration errors detected"

        printf '%s\n' "$HYPR_ERRORS"

    fi

else

    info "hyprctl unavailable — Hyprland check skipped"

fi

# 10. Desktop dependencies

section "Desktop dependencies"

desktop_commands=(

    git

    kitty

    qs

    nmcli
    nm-applet
    blueman-applet

    brightnessctl

    wpctl

    notify-send

    awww

)

for cmd in "${desktop_commands[@]}"; do

    if command -v "$cmd" >/dev/null 2>&1; then

        ok "$cmd"

    else

        fail "Missing command: $cmd"

    fi

done

# 11. Neovim declarations

section "Neovim packages"

NVIM_CONFIG="$ROOT/home/neovim/default.nix"

if [[ -f "$NVIM_CONFIG" ]]; then

    if grep -q "programs.neovim" "$NVIM_CONFIG"; then

        ok "Neovim is managed by Home Manager"

    else

        fail "programs.neovim declaration not found"

    fi

    # Plugins

    nvim_plugins=(

        "blink-cmp"
        "nvim-lspconfig"
        "nvim-treesitter"

        "telescope-nvim"
        "plenary-nvim"

        "nvim-web-devicons"

        "gitsigns-nvim"
        "conform-nvim"
        "nvim-lint"

        "trouble-nvim"
        "which-key-nvim"

        "lualine-nvim"
        "snacks-nvim"
        "nvim-tree-lua"

    )

    for plugin in "${nvim_plugins[@]}"; do

        if grep -q "$plugin" "$NVIM_CONFIG"; then

            ok "Plugin declared: $plugin"

        else

            fail "Plugin not declared: $plugin"

        fi

    done

    # Development tools

    nvim_tools=(

        "lua-language-server"
        "stylua"

        "typescript-language-server"
        "pyright"

        "bash-language-server"
        "yaml-language-server"

        "tailwindcss-language-server"
        "dockerfile-language-server"

        "prettier"
        "ruff"

    )

    for tool in "${nvim_tools[@]}"; do

        if grep -q "$tool" "$NVIM_CONFIG"; then

            ok "Neovim tool declared: $tool"

        else

            info "Neovim tool not declared directly: $tool"

        fi

    done

else

    fail "Neovim Home Manager configuration missing"

fi

# 12. Configuration ownership

section "Configuration ownership"

# Neovim

if grep -q "programs.neovim" \
    "$ROOT/home/neovim/default.nix" 2>/dev/null; then

    ok "Neovim is owned by Home Manager"

else

    fail "Neovim is not owned by Home Manager"

fi

# Launcher

if grep -qE '^[[:space:]]*fuzzel[[:space:]]*$' \
    "$ROOT/modules/desktop/applications.nix" 2>/dev/null; then

    fail "Fuzzel package is still declared by the desktop module"

else

    ok "Fuzzel package is no longer declared"

fi

launcher_surfaces=(

    "home/quickshell/config/components/LauncherSurface.qml"

    "home/quickshell/config/modules/AppLauncher.qml"
    "home/quickshell/config/modules/WallpaperPicker.qml"
    "home/quickshell/config/modules/ThemePicker.qml"

    "home/quickshell/config/services/AppsService.qml"
    "home/quickshell/config/services/WallpaperService.qml"
    "home/quickshell/config/services/ThemeService.qml"

)

for surface in "${launcher_surfaces[@]}"; do

    if [[ -f "$ROOT/$surface" ]]; then

        ok "Launcher surface present: $surface"

    else

        fail "Launcher surface missing: $surface"

    fi

done

# Kitty

if grep -q "programs.kitty" \
    "$ROOT/home/kitty/default.nix" 2>/dev/null; then

    ok "Kitty is owned by Home Manager"

else

    fail "Kitty Home Manager configuration not found"

fi

# Quickshell

if grep -q "quickshell" \
    "$ROOT/home/quickshell/default.nix" 2>/dev/null; then

    ok "Quickshell is managed by Home Manager"

else

    fail "Quickshell Home Manager configuration not found"

fi

# 13. Aurora theme architecture

section "Aurora theme"

THEME_CONFIG="$ROOT/lib/themes.nix"
THEME_GENERATOR="$ROOT/home/theme/default.nix"

# Central theme database

if [[ -f "$THEME_CONFIG" ]]; then

    ok "Central Aurora theme database exists"

else

    fail "Central Aurora theme database missing"

fi

# Declarative active theme

if grep -qE '^[[:space:]]*activeTheme[[:space:]]*=' \
    "$THEME_CONFIG" 2>/dev/null; then

    ok "Theme selection is declarative"

else

    fail "Declarative activeTheme is missing"

fi

# Theme generator

if [[ -f "$THEME_GENERATOR" ]]; then

    ok "Aurora theme generator exists"

else

    fail "Aurora theme generator missing"

fi

# Validate activeTheme using Nix

THEME_EVAL="$(
    nix-instantiate \
        --eval \
        --expr \
        '(import ./lib/themes.nix).global.activeTheme' \
        2>/dev/null ||
        true
)"

if [[ "$THEME_EVAL" == '"aurora"' ]]; then

    ok "Active theme evaluates correctly: aurora"

elif [[ -n "$THEME_EVAL" ]]; then

    ok "Active theme evaluates: $THEME_EVAL"

else

    fail "Could not evaluate global.activeTheme"

fi

# Required Aurora theme fields

theme_fields=(

    "background"
    "surface"
    "surfaceHover"
    "surfaceActive"

    "border"
    "borderFocus"
    "separator"

    "text"
    "textSecondary"
    "textMuted"

    "accent"
    "accentHover"
    "accentActive"
    "accentMuted"
    "accentForeground"

    "success"
    "warning"
    "error"
    "info"

)

for field in "${theme_fields[@]}"; do

    if grep -qE "^[[:space:]]*$field[[:space:]]*=" \
        "$THEME_CONFIG" 2>/dev/null; then

        ok "Theme color defined: $field"

    else

        fail "Theme color missing: $field"

    fi

done

# 14. Central fonts / UI

section "Global typography"

# Interface font

if grep -qE '^[[:space:]]*interface[[:space:]]*=' \
    "$THEME_CONFIG" 2>/dev/null; then

    ok "Central interface font defined"

else

    fail "Central interface font missing"

fi

# Terminal font

if grep -qE '^[[:space:]]*terminal[[:space:]]*=' \
    "$THEME_CONFIG" 2>/dev/null; then

    ok "Central terminal font defined"

else

    fail "Central terminal font missing"

fi

# Emoji font

if grep -qE '^[[:space:]]*emoji[[:space:]]*=' \
    "$THEME_CONFIG" 2>/dev/null; then

    ok "Central emoji font defined"

else

    fail "Central emoji font missing"

fi

# UI font size

if grep -qE '^[[:space:]]*fontSize[[:space:]]*=' \
    "$THEME_CONFIG" 2>/dev/null; then

    ok "Central UI font size defined"

else

    fail "Central UI font size missing"

fi

# Detect hard-coded terminal font in Kitty

KITTY_CONFIG="$ROOT/home/kitty/config/kitty.conf"

if [[ -f "$KITTY_CONFIG" ]]; then

    if grep -qE \
        '^[[:space:]]*font_family[[:space:]]+' \
        "$KITTY_CONFIG"; then

        fail "Kitty contains a hard-coded font_family"

    else

        ok "Kitty font family is centrally managed"

    fi

    if grep -qE \
        '^[[:space:]]*font_size[[:space:]]+' \
        "$KITTY_CONFIG"; then

        fail "Kitty contains a hard-coded font_size"

    else

        ok "Kitty font size is centrally managed"

    fi

else

    fail "Kitty configuration missing"

fi

# 15. Wallpaper / theme separation

section "Wallpaper / theme separation"

WALLPAPER_SERVICE="$ROOT/home/quickshell/config/services/WallpaperService.qml"
RESTORE_SCRIPT="$ROOT/home/hyprland/scripts/restore-wallpaper.sh"

# Wallpaper picker

if grep -qiE \
    'wallust|wallust run|\.cache/wallust|stylix-colors' \
    "$WALLPAPER_SERVICE" 2>/dev/null; then

    fail "Wallpaper picker still contains legacy theme generation"

else

    ok "Wallpaper picker is independent from Wallust"

fi

# Wallpaper restore

if grep -qiE \
    'wallust|wallust run|\.cache/wallust|stylix-colors' \
    "$RESTORE_SCRIPT" 2>/dev/null; then

    fail "Wallpaper restore still contains legacy theme generation"

else

    ok "Wallpaper restore is independent from Wallust"

fi

# Wallpaper state location

if grep -q '\.cache/aurora/current-wallpaper' \
    "$WALLPAPER_SERVICE" 2>/dev/null; then

    ok "Wallpaper state uses Aurora cache"

else

    fail "Wallpaper picker does not use Aurora wallpaper state"

fi

if grep -q '\.cache/aurora/current-wallpaper' \
    "$RESTORE_SCRIPT" 2>/dev/null; then

    ok "Wallpaper restore uses Aurora cache"

else

    fail "Wallpaper restore does not use Aurora wallpaper state"

fi

# Legacy Wallust directory

if [[ ! -d "$ROOT/home/hyprland/wallust" ]]; then

    ok "Legacy Wallust configuration removed"

else

    fail "Legacy Wallust configuration still exists"

fi

# Legacy generated cache

if [[ -d "$HOME/.cache/wallust" ]]; then

    info "Legacy ~/.cache/wallust still exists"

else

    ok "Legacy Wallust cache removed"

fi

# Repository-wide legacy references

LEGACY_REFS="$(
    grep -RInE \
        'wallust|wallust-wayland|wallust\.run|wallust run|\.cache/wallust|stylix-colors' \
        home \
        modules \
        lib \
        scripts \
        --exclude-dir=.git \
        --exclude='*.lock' \
        --exclude='check.sh' \
        2>/dev/null ||
        true
)"

if [[ -z "$LEGACY_REFS" ]]; then

    ok "No legacy Wallust/stylix-colors references in active configuration"

else

    fail "Legacy Wallust/stylix-colors references remain"

    printf "\n"
    printf '%s\n' "$LEGACY_REFS"

fi

# 16. Generated configuration

section "Generated configuration"

generated_files=(

    "$HOME/.config/aurora/active-theme"
    "$HOME/.config/aurora/active-theme.lua"
    "$HOME/.config/aurora/active-kitty.conf"
    "$HOME/.config/aurora/active-starship.toml"

    "$HOME/.config/quickshell/shell.qml"
    "$HOME/.config/hypr/hyprland.lua"

)

for file in "${generated_files[@]}"; do

    if [[ -e "$file" ]]; then

        ok "$file"

    else

        info "Not currently generated: $file"

    fi

done

# 17. Generated theme sanity

section "Generated theme sanity"

ACTIVE_THEME_LUA="$HOME/.config/aurora/active-theme.lua"
ACTIVE_KITTY="$HOME/.config/aurora/active-kitty.conf"
ACTIVE_STARSHIP="$HOME/.config/aurora/active-starship.toml"

# active-theme.lua

if [[ -f "$ACTIVE_THEME_LUA" ]]; then

    if grep -q 'colors' "$ACTIVE_THEME_LUA"; then

        ok "Generated Aurora Lua theme contains colors"

    else

        fail "Generated Aurora Lua theme has no colors"

    fi

else

    info "Aurora Lua theme not generated yet"

fi

# Kitty theme

if [[ -f "$ACTIVE_KITTY" ]]; then

    if grep -q '^foreground ' "$ACTIVE_KITTY" &&
        grep -q '^background ' "$ACTIVE_KITTY"; then

        ok "Generated Kitty theme contains core colors"

    else

        fail "Generated Kitty theme is incomplete"

    fi

else

    info "Aurora Kitty theme not generated yet"

fi

# Starship theme

if [[ -f "$ACTIVE_STARSHIP" ]]; then

    ok "Generated Starship theme exists"

else

    info "Aurora Starship theme not generated yet"

fi

# 18. Aurora layer rules

section "Aurora layer rules"

LAYER_RULES="$ROOT/home/hyprland/config/layerules.lua"

if [[ -f "$LAYER_RULES" ]]; then

    ok "Layer rules file exists"

    # Every Wayland namespace declared by a Quickshell surface needs a matching layer rule.

    for ns in aurora-bar aurora-popup aurora-notifications aurora-launcher; do

        if grep -q "namespace = \"\\^${ns}\\\$\"" \
            "$LAYER_RULES" 2>/dev/null; then

            ok "Layer rule declared: $ns"

        else

            fail "Layer rule missing: $ns"

        fi

    done

else

    fail "Hyprland layer rules file not found"

fi

# 18b. Notification delivery

section "Notification delivery"

NOTIF_SERVER="$ROOT/home/quickshell/config/services/NotificationServer.qml"
QUICKSHELL_NIX="$ROOT/home/quickshell/default.nix"
NOTIF_MODULE="$ROOT/modules/notifications/default.nix"

if [[ -f "$NOTIF_SERVER" ]]; then

    # services/qmldir registers NotificationServer.qml as a composite type called NotificationServer.

    if grep -q "import Quickshell.Services.Notifications as "         "$NOTIF_SERVER" 2>/dev/null; then

        ok "Notification server import is aliased"

    else

        fail "Notification server import is not aliased (daemon will not bind)"

    fi

    if grep -qE "^[[:space:]]+NotificationServer \{"         "$NOTIF_SERVER" 2>/dev/null; then

        fail "Unqualified NotificationServer instantiation (shadows itself)"

    else

        ok "Notification server instantiated through its namespace"

    fi

else

    fail "NotificationServer.qml not found"

fi

if grep -q "org.freedesktop.Notifications.service"     "$QUICKSHELL_NIX" 2>/dev/null; then

    ok "D-Bus activation declared for org.freedesktop.Notifications"

else

    fail "No D-Bus activation: apps that notify before the shell starts lose it"

fi

if grep -q "WantedBy" "$QUICKSHELL_NIX" 2>/dev/null; then

    ok "quickshell.service is bound to the graphical session"

else

    fail "quickshell.service has no Install section and will never autostart"

fi

if grep -q "libnotify" "$QUICKSHELL_NIX" 2>/dev/null; then

    ok "notify-send available in the user profile"

else

    fail "libnotify missing: notify-send unavailable to scripts and keybinds"

fi

if grep -q "impl.portal.Notification" "$NOTIF_MODULE" 2>/dev/null; then

    ok "Portal notification backend declared"

else

    fail "Portal notification backend missing: sandboxed apps cannot notify"

fi

# 19. Aurora theme ownership

section "Theme ownership"

# Hyprland

HYPR_THEME="$ROOT/home/hyprland/config/theme.lua"

if [[ -f "$HYPR_THEME" ]]; then

    if grep -q 'active-theme.lua' "$HYPR_THEME" 2>/dev/null; then

        ok "Hyprland consumes Aurora active theme"

    else

        fail "Hyprland theme does not consume Aurora active theme"

    fi

else

    fail "Hyprland theme module missing"

fi

# Neovim

if grep -Rql \
    'active-theme.lua' \
    "$ROOT/home/neovim/config/lua" \
    --include='*.lua' \
    2>/dev/null; then

    ok "Neovim theme modules consume Aurora active theme"

else

    fail "Neovim does not reference Aurora active theme"

fi

# Quickshell

QUICKSHELL_ROOT="$ROOT/home/quickshell"

if grep -Rql \
    'active-theme' \
    "$QUICKSHELL_ROOT" \
    --include='*.qml' \
    --include='*.nix' \
    2>/dev/null; then

    ok "Quickshell consumes Aurora theme data"

else

    info "Could not verify Quickshell Aurora theme consumption"

fi

# 20. Git status

section "Git status"

if git diff --quiet && git diff --cached --quiet; then

    ok "Working tree clean"

else

    info "Uncommitted changes detected"

    printf "\n"

    git status --short

fi

# Final result

printf "\n"

separator

printf "\n"

if [[ "$FAILED" -eq 0 ]]; then

    printf "${GREEN}${BOLD}"
    printf '╭────────────────────────────────────────────────────────────╮\n'
    printf '│                                                            │\n'
    printf '│            ✓  Configuration is healthy                     │\n'
    printf '│                                                            │\n'
    printf '╰────────────────────────────────────────────────────────────╯\n'
    printf "${RESET}"

    printf "\n"
    printf "${DIM}Safe to run:${RESET}\n"
    printf "  ${CYAN}sudo nixos-rebuild switch --flake .#laptop${RESET}\n"

    exit 0

else

    printf "${RED}${BOLD}"
    printf '╭────────────────────────────────────────────────────────────╮\n'
    printf '│                                                            │\n'
    printf '│             ✗  Problems require attention                  │\n'
    printf '│                                                            │\n'
    printf '╰────────────────────────────────────────────────────────────╯\n'
    printf "${RESET}"

    printf "\n"
    printf "${YELLOW}Fix the problems above before rebuilding.${RESET}\n"

    exit 1

fi
