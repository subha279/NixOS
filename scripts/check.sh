#!/usr/bin/env bash

# ============================================================================
# NixOS Configuration Validator
# ============================================================================
#
# Designed for this repository:
#
#   NixOS
#   ├── hosts/
#   ├── modules/
#   ├── home/
#   └── scripts/
#
# Important:
#
# Neovim plugins and extraPackages are managed by Home Manager.
# Therefore we validate their DECLARATION and the REAL Neovim configuration,
# rather than trying to discover them from a bare `nvim -u NONE` process.
# ============================================================================

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

FAILED=0

# ============================================================================
# Helpers
# ============================================================================

ok() {
    printf '  ✓ %s\n' "$1"
}

fail() {
    printf '  ✗ %s\n' "$1"
    FAILED=1
}

info() {
    printf '  ! %s\n' "$1"
}

section() {
    printf '\n\033[1;35m==> %s\033[0m\n' "$1"
}

# ============================================================================
# Header
# ============================================================================

printf '\033[1;36m'
printf '╭──────────────────────────────────────────────╮\n'
printf '│          NixOS Configuration Check           │\n'
printf '╰──────────────────────────────────────────────╯\n'
printf '\033[0m'

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

    if grep -q "dirty" "$FLAKE_LOG"; then
        info "Git tree is dirty"
    fi

else

    fail "Flake check failed"
    cat "$FLAKE_LOG"

fi

rm -f "$FLAKE_LOG"

# ============================================================================
# 3. Nix syntax
# ============================================================================

section "Nix files"

NIX_FAILED=0
NIX_COUNT=0

while IFS= read -r -d '' file; do

    NIX_COUNT=$((NIX_COUNT + 1))

    if ! nix-instantiate --parse "$file" >/dev/null 2>&1; then
        printf '  ✗ Invalid Nix syntax: %s\n' "$file"
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

    "home/fuzzel/default.nix"
)

for file in "${required_files[@]}"; do

    if [[ -f "$file" ]]; then
        ok "$file"
    else
        fail "Missing: $file"
    fi

done

# ============================================================================
# 5. Neovim
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

rm -f "$NVIM_LOG"

# ============================================================================
# 7. Lua
# ============================================================================

section "Lua"

LUA_LOG="$(mktemp)"

if command -v nvim >/dev/null 2>&1; then

    if nvim \
        --headless \
        -u NONE \
        '+lua local files = vim.fn.glob("'"$ROOT"'/home/**/*.lua", false, true); for _, f in ipairs(files) do local fn, err = loadfile(f); if not fn then error(f .. ": " .. err) end end' \
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

rm -f "$LUA_LOG"

# ============================================================================
# 8. Quickshell
# ============================================================================

section "Quickshell"

if command -v qs >/dev/null 2>&1; then

    if systemctl --user is-active --quiet quickshell; then
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
    qs
    nmcli
    nm-applet
    blueman-applet
    brightnessctl
    wpctl
    notify-send
    awww
    wallust
    kitty
)

for cmd in "${desktop_commands[@]}"; do

    if command -v "$cmd" >/dev/null 2>&1; then
        ok "$cmd"
    else
        fail "Missing command: $cmd"
    fi

done

# ============================================================================
# 11. Neovim declaration
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
    # LSP / formatter tools
    # ------------------------------------------------------------------------

    nvim_tools=(
        "lua-language-server"
        "rust-analyzer"
        "typescript-language-server"
        "pyright"
        "clang-tools"
        "nixd"
        "bash-language-server"
        "vscode-langservers-extracted"
        "yaml-language-server"
        "marksman"
        "tailwindcss-language-server"
        "dockerfile-language-server"
        "taplo"
        "stylua"
        "prettier"
        "ruff"
        "nixfmt"
        "shfmt"
    )

    for tool in "${nvim_tools[@]}"; do

        if grep -q "$tool" "$NVIM_CONFIG"; then
            ok "Tool declared: $tool"
        else
            fail "Tool not declared: $tool"
        fi

    done

else

    fail "Neovim Home Manager module not found"

fi

# ============================================================================
# 12. Configuration ownership
# ============================================================================

section "Configuration ownership"

# ---------------------------------------------------------------------------
# Neovim
# ---------------------------------------------------------------------------

if grep -qE '^[[:space:]]*neovim[[:space:]]*$' \
    "$ROOT/modules/packages/default.nix" 2>/dev/null; then

    fail "Neovim is still declared in modules/packages/default.nix"

else

    ok "Neovim is owned by Home Manager"

fi

# ---------------------------------------------------------------------------
# Fuzzel
# ---------------------------------------------------------------------------

if grep -qE '^[[:space:]]*fuzzel[[:space:]]*$' \
    "$ROOT/modules/desktop/applications.nix" 2>/dev/null &&
    [[ -f "$ROOT/home/fuzzel/default.nix" ]]; then

    ok "Fuzzel package/config ownership is clean"

else

    info "Fuzzel ownership could not be verified"

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
# 13. Generated configuration
# ============================================================================

section "Generated configuration"

generated_files=(
    "$HOME/.config/fuzzel/fuzzel.ini"
    "$HOME/.config/quickshell/shell.qml"
    "$HOME/.config/hypr/hyprland.lua"
)

for file in "${generated_files[@]}"; do

    if [[ -e "$file" ]]; then
        ok "$file"
    else
        info "Not currently deployed: $file"
    fi

done

# ============================================================================
# Final result
# ============================================================================

printf '\n'

if [[ "$FAILED" -eq 0 ]]; then

    printf '\033[1;32m'
    printf '╭──────────────────────────────────────────────╮\n'
    printf '│          ✓ Configuration is healthy          │\n'
    printf '╰──────────────────────────────────────────────╯\n'
    printf '\033[0m'

    printf '\n'
    printf 'Safe to run:\n'
    printf '  sudo nixos-rebuild switch --flake .#laptop\n'

    exit 0

else

    printf '\033[1;31m'
    printf '╭──────────────────────────────────────────────╮\n'
    printf '│       ✗ Problems require attention           │\n'
    printf '╰──────────────────────────────────────────────╯\n'
    printf '\033[0m'

    printf '\n'
    printf 'Fix the problems above before rebuilding.\n'

    exit 1

fi
