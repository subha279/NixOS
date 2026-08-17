#!/usr/bin/env bash

# ============================================================================
# Aurora NixOS Configuration Validator
# ============================================================================
#
# Repository:
#
#   NixOS
#   ├── hosts/
#   ├── modules/
#   ├── home/
#   ├── lib/
#   └── scripts/
#
# Validates:
#   • Git repository
#   • Flake evaluation
#   • Nix syntax
#   • Required files
#   • Neovim configuration
#   • Lua syntax
#   • Quickshell
#   • Hyprland
#   • Desktop dependencies
#   • Neovim package declarations
#   • Plugin declarations
#   • Configuration ownership
#   • Aurora static theme architecture
#   • Wallpaper/theme separation
#   • Generated Aurora configuration
#   • Hyprland layer rules
#   • Git working tree
#
# Theme architecture:
#
#   lib/themes.nix
#        │
#        ├── activeTheme
#        ├── fonts
#        ├── icons
#        ├── cursor
#        ├── UI values
#        └── colors
#               │
#               ├── Stylix
#               ├── Hyprland
#               ├── Kitty
#               ├── Fuzzel
#               ├── QuickShell
#               ├── Neovim
#               └── Starship
#
# Wallpaper:
#
#   Wallpaper is image-only.
#   It MUST NOT generate colors.
#
# Wallust:
#
#   Removed from the Aurora theme pipeline.
#
# ============================================================================

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

FAILED=0

# ============================================================================
# UI
# ============================================================================

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

# ============================================================================
# Cleanup
# ============================================================================

cleanup() {
    rm -f \
        "${FLAKE_LOG:-}" \
        "${NVIM_LOG:-}" \
        "${LUA_LOG:-}" \
        2>/dev/null || true
}

trap cleanup EXIT

# ============================================================================
# Header
# ============================================================================

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

# ============================================================================
# 1. Repository
# ============================================================================

section "Repository"

if git rev-parse --show-toplevel >/dev/null 2>&1; then
    ok "Git repository detected"
else
    fail "Not inside a Git repository"
fi

# ============================================================================
# 2. Flake
# ============================================================================

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

# ============================================================================
# 3. Nix syntax
# ============================================================================

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

# ============================================================================
# 4. Required files
# ============================================================================

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

    # Fuzzel
    "home/fuzzel/fuzzel.ini"

    # Wallpaper
    "home/hyprland/scripts/launcher.sh"
    "home/hyprland/scripts/wallpaper.sh"
    "home/hyprland/scripts/restore-wallpaper.sh"

)

for file in "${required_files[@]}"; do

    if [[ -f "$file" ]]; then

        ok "$file"

    else

        fail "Missing: $file"

    fi

done

# ============================================================================
# 5. Neovim files
# ============================================================================

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

# ============================================================================
# 6. Real Neovim configuration
# ============================================================================

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

# ============================================================================
# 7. Lua
# ============================================================================

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

# ============================================================================
# 8. Quickshell
# ============================================================================

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

# ============================================================================
# 9. Hyprland
# ============================================================================

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

# ============================================================================
# 10. Desktop dependencies
# ============================================================================

section "Desktop dependencies"

desktop_commands=(

    git

    fuzzel
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

# ============================================================================
# 11. Neovim declarations
# ============================================================================

section "Neovim packages"

NVIM_CONFIG="$ROOT/home/neovim/default.nix"

if [[ -f "$NVIM_CONFIG" ]]; then

    if grep -q "programs.neovim" "$NVIM_CONFIG"; then

        ok "Neovim is managed by Home Manager"

    else

        fail "programs.neovim declaration not found"

    fi

    # ------------------------------------------------------------------------
    # Plugins
    # ------------------------------------------------------------------------

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

    # ------------------------------------------------------------------------
    # Development tools
    # ------------------------------------------------------------------------

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

# ============================================================================
# 12. Configuration ownership
# ============================================================================

section "Configuration ownership"

# ---------------------------------------------------------------------------
# Neovim
# ---------------------------------------------------------------------------

if grep -q "programs.neovim" \
    "$ROOT/home/neovim/default.nix" 2>/dev/null; then

    ok "Neovim is owned by Home Manager"

else

    fail "Neovim is not owned by Home Manager"

fi

# ---------------------------------------------------------------------------
# Fuzzel
# ---------------------------------------------------------------------------

if grep -qE '^[[:space:]]*fuzzel[[:space:]]*$' \
    "$ROOT/modules/desktop/applications.nix" 2>/dev/null; then

    ok "Fuzzel is declared by the desktop module"

else

    fail "Fuzzel package declaration not found"

fi

# ---------------------------------------------------------------------------
# Kitty
# ---------------------------------------------------------------------------

if grep -q "programs.kitty" \
    "$ROOT/home/kitty/default.nix" 2>/dev/null; then

    ok "Kitty is owned by Home Manager"

else

    fail "Kitty Home Manager configuration not found"

fi

# ---------------------------------------------------------------------------
# Quickshell
# ---------------------------------------------------------------------------

if grep -q "quickshell" \
    "$ROOT/home/quickshell/default.nix" 2>/dev/null; then

    ok "Quickshell is managed by Home Manager"

else

    fail "Quickshell Home Manager configuration not found"

fi

# ============================================================================
# 13. Aurora theme architecture
# ============================================================================

section "Aurora theme"

THEME_CONFIG="$ROOT/lib/themes.nix"
THEME_GENERATOR="$ROOT/home/theme/default.nix"

# ---------------------------------------------------------------------------
# Central theme database
# ---------------------------------------------------------------------------

if [[ -f "$THEME_CONFIG" ]]; then

    ok "Central Aurora theme database exists"

else

    fail "Central Aurora theme database missing"

fi

# ---------------------------------------------------------------------------
# Declarative active theme
# ---------------------------------------------------------------------------

if grep -qE '^[[:space:]]*activeTheme[[:space:]]*=' \
    "$THEME_CONFIG" 2>/dev/null; then

    ok "Theme selection is declarative"

else

    fail "Declarative activeTheme is missing"

fi

# ---------------------------------------------------------------------------
# Theme generator
# ---------------------------------------------------------------------------

if [[ -f "$THEME_GENERATOR" ]]; then

    ok "Aurora theme generator exists"

else

    fail "Aurora theme generator missing"

fi

# ---------------------------------------------------------------------------
# Validate activeTheme using Nix
# ---------------------------------------------------------------------------

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

# ---------------------------------------------------------------------------
# Required Aurora theme fields
# ---------------------------------------------------------------------------

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

# ============================================================================
# 14. Central fonts / UI
# ============================================================================

section "Global typography"

# ---------------------------------------------------------------------------
# Interface font
# ---------------------------------------------------------------------------

if grep -qE '^[[:space:]]*interface[[:space:]]*=' \
    "$THEME_CONFIG" 2>/dev/null; then

    ok "Central interface font defined"

else

    fail "Central interface font missing"

fi

# ---------------------------------------------------------------------------
# Terminal font
# ---------------------------------------------------------------------------

if grep -qE '^[[:space:]]*terminal[[:space:]]*=' \
    "$THEME_CONFIG" 2>/dev/null; then

    ok "Central terminal font defined"

else

    fail "Central terminal font missing"

fi

# ---------------------------------------------------------------------------
# Emoji font
# ---------------------------------------------------------------------------

if grep -qE '^[[:space:]]*emoji[[:space:]]*=' \
    "$THEME_CONFIG" 2>/dev/null; then

    ok "Central emoji font defined"

else

    fail "Central emoji font missing"

fi

# ---------------------------------------------------------------------------
# UI font size
# ---------------------------------------------------------------------------

if grep -qE '^[[:space:]]*fontSize[[:space:]]*=' \
    "$THEME_CONFIG" 2>/dev/null; then

    ok "Central UI font size defined"

else

    fail "Central UI font size missing"

fi

# ---------------------------------------------------------------------------
# Detect hard-coded terminal font in Kitty
# ---------------------------------------------------------------------------

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

# ============================================================================
# 15. Wallpaper / theme separation
# ============================================================================

section "Wallpaper / theme separation"

WALLPAPER_SCRIPT="$ROOT/home/hyprland/scripts/wallpaper.sh"
RESTORE_SCRIPT="$ROOT/home/hyprland/scripts/restore-wallpaper.sh"

# ---------------------------------------------------------------------------
# Wallpaper picker
# ---------------------------------------------------------------------------

if grep -qiE \
    'wallust|wallust run|\.cache/wallust|stylix-colors' \
    "$WALLPAPER_SCRIPT" 2>/dev/null; then

    fail "Wallpaper picker still contains legacy theme generation"

else

    ok "Wallpaper picker is independent from Wallust"

fi

# ---------------------------------------------------------------------------
# Wallpaper restore
# ---------------------------------------------------------------------------

if grep -qiE \
    'wallust|wallust run|\.cache/wallust|stylix-colors' \
    "$RESTORE_SCRIPT" 2>/dev/null; then

    fail "Wallpaper restore still contains legacy theme generation"

else

    ok "Wallpaper restore is independent from Wallust"

fi

# ---------------------------------------------------------------------------
# Wallpaper state location
# ---------------------------------------------------------------------------

if grep -q '\.cache/aurora/current-wallpaper' \
    "$WALLPAPER_SCRIPT" 2>/dev/null; then

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

# ---------------------------------------------------------------------------
# Legacy Wallust directory
# ---------------------------------------------------------------------------

if [[ ! -d "$ROOT/home/hyprland/wallust" ]]; then

    ok "Legacy Wallust configuration removed"

else

    fail "Legacy Wallust configuration still exists"

fi

# ---------------------------------------------------------------------------
# Legacy generated cache
# ---------------------------------------------------------------------------

if [[ -d "$HOME/.cache/wallust" ]]; then

    info "Legacy ~/.cache/wallust still exists"

else

    ok "Legacy Wallust cache removed"

fi

# ---------------------------------------------------------------------------
# Repository-wide legacy references
# ---------------------------------------------------------------------------
#
# README/history files are intentionally excluded from this runtime check.
# The active configuration itself must contain none of these references.
#

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

# ============================================================================
# 16. Generated configuration
# ============================================================================

section "Generated configuration"

generated_files=(

    "$HOME/.config/aurora/active-theme"
    "$HOME/.config/aurora/active-theme.lua"
    "$HOME/.config/aurora/active-kitty.conf"
    "$HOME/.config/aurora/active-fuzzel.conf"
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

# ============================================================================
# 17. Generated theme sanity
# ============================================================================

section "Generated theme sanity"

ACTIVE_THEME_LUA="$HOME/.config/aurora/active-theme.lua"
ACTIVE_KITTY="$HOME/.config/aurora/active-kitty.conf"
ACTIVE_FUZZEL="$HOME/.config/aurora/active-fuzzel.conf"
ACTIVE_STARSHIP="$HOME/.config/aurora/active-starship.toml"

# ---------------------------------------------------------------------------
# active-theme.lua
# ---------------------------------------------------------------------------

if [[ -f "$ACTIVE_THEME_LUA" ]]; then

    if grep -q 'colors' "$ACTIVE_THEME_LUA"; then

        ok "Generated Aurora Lua theme contains colors"

    else

        fail "Generated Aurora Lua theme has no colors"

    fi

else

    info "Aurora Lua theme not generated yet"

fi

# ---------------------------------------------------------------------------
# Kitty theme
# ---------------------------------------------------------------------------

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

# ---------------------------------------------------------------------------
# Fuzzel theme
# ---------------------------------------------------------------------------

if [[ -f "$ACTIVE_FUZZEL" ]]; then

    if grep -qE '^\[colors\]' "$ACTIVE_FUZZEL"; then

        ok "Generated Fuzzel theme contains colors"

    else

        fail "Generated Fuzzel theme is incomplete"

    fi

else

    info "Aurora Fuzzel theme not generated yet"

fi

# ---------------------------------------------------------------------------
# Starship theme
# ---------------------------------------------------------------------------

if [[ -f "$ACTIVE_STARSHIP" ]]; then

    ok "Generated Starship theme exists"

else

    info "Aurora Starship theme not generated yet"

fi

# ============================================================================
# 18. Aurora layer rules
# ============================================================================

section "Aurora layer rules"

LAYER_RULES="$ROOT/home/hyprland/config/layerules.lua"

if [[ -f "$LAYER_RULES" ]]; then

    ok "Layer rules file exists"

    if grep -q 'namespace = "\^launcher\$"' \
        "$LAYER_RULES" 2>/dev/null; then

        ok "Launcher blur rule declared"

    else

        fail "Launcher blur rule missing"

    fi

    if grep -q 'namespace = "\^aurora-notifications\$"' \
        "$LAYER_RULES" 2>/dev/null; then

        ok "Aurora notification blur rule declared"

    else

        fail "Aurora notification blur rule missing"

    fi

else

    fail "Hyprland layer rules file not found"

fi

# ============================================================================
# 19. Aurora theme ownership
# ============================================================================

section "Theme ownership"

# ---------------------------------------------------------------------------
# Hyprland
# ---------------------------------------------------------------------------

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

# ---------------------------------------------------------------------------
# Neovim
# ---------------------------------------------------------------------------

if grep -Rql \
    'active-theme.lua' \
    "$ROOT/home/neovim/config/lua" \
    --include='*.lua' \
    2>/dev/null; then

    ok "Neovim theme modules consume Aurora active theme"

else

    fail "Neovim does not reference Aurora active theme"

fi

# ---------------------------------------------------------------------------
# Quickshell
# ---------------------------------------------------------------------------

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

# ============================================================================
# 20. Git status
# ============================================================================

section "Git status"

if git diff --quiet && git diff --cached --quiet; then

    ok "Working tree clean"

else

    info "Uncommitted changes detected"

    printf "\n"

    git status --short

fi

# ============================================================================
# Final result
# ============================================================================

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
