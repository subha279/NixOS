#!/usr/bin/env bash
set -Eeuo pipefail

# ============================================================================
# Sunflower Installer / System Manager
# ============================================================================
# One entry point for:
#   - Fresh installation from the Sunflower live ISO
#   - Existing-system configuration
#   - Update / rebuild / dry-build / rollback
#   - Validation and maintenance
#
# Fresh install flow:
#   Live ISO -> ask identity -> select disk -> partition -> format -> mount
#   -> copy Sunflower -> configure variables -> generate hardware config
#   -> nixos-install -> set user password -> finish
#
# IMPORTANT:
#   --dry-run NEVER partitions, formats, mounts, copies, or installs.
# ============================================================================

VERSION="2.0"
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
VARS_REL="lib/variables.nix"
FLAKE_NAME="sunflower"
FLAKE_TARGET="$ROOT#$FLAKE_NAME"

CI_TARGET="/mnt"
CI_ESP_LABEL="EFI"
CI_ROOT_LABEL="nixos"
CI_ESP_SIZE="+1G"
M_KEEP_GENERATIONS=2

CI_DRY_RUN=0
CI_DISK=""
CI_ESP=""
CI_ROOT_PART=""
CI_MOUNTED=0

SUNFLOWER_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/sunflower"
UI_THEME_FILE=""

# ============================================================================
# UI
# ============================================================================

if [[ -t 1 ]]; then IS_TTY=1; else IS_TTY=0; fi

UI_COLOR=1
[[ -n "${NO_COLOR:-}" ]] && UI_COLOR=0
[[ "${TERM:-}" == "dumb" ]] && UI_COLOR=0
[[ "$IS_TTY" -eq 0 ]] && UI_COLOR=0

UI_TRUECOLOR=0
if [[ "$UI_COLOR" -eq 1 ]]; then
    case "${COLORTERM:-}" in
    truecolor | 24bit) UI_TRUECOLOR=1 ;;
    esac
    case "${TERM:-}" in
    *-direct* | *-256color | kitty | xterm-kitty | alacritty | foot | wezterm)
        UI_TRUECOLOR=1
        ;;
    esac
fi

UI_UNICODE=1
case "${LC_ALL:-${LC_CTYPE:-${LANG:-}}}" in
*UTF-8* | *utf-8* | *UTF8* | *utf8*) ;;
*) UI_UNICODE=0 ;;
esac
[[ "${TERM:-}" == "dumb" ]] && UI_UNICODE=0
[[ "$IS_TTY" -eq 0 ]] && UI_UNICODE=0

UI_WIDTH=64

ui_refresh_width() {
    UI_WIDTH=64

    if [[ "$IS_TTY" -eq 1 ]]; then
        UI_WIDTH="$(tput cols 2>/dev/null || printf '64')"

        if ((UI_WIDTH > 74)); then
            UI_WIDTH=74
        fi

        if ((UI_WIDTH < 40)); then
            UI_WIDTH=40
        fi
    fi
}

if [[ -r "$SUNFLOWER_CONFIG_DIR/active-theme" ]]; then
    UI_THEME_ID="$(tr -d '[:space:]' <"$SUNFLOWER_CONFIG_DIR/active-theme" 2>/dev/null || true)"
    if [[ -n "${UI_THEME_ID:-}" &&
        -r "$SUNFLOWER_CONFIG_DIR/themes/$UI_THEME_ID.json" ]]; then
        UI_THEME_FILE="$SUNFLOWER_CONFIG_DIR/themes/$UI_THEME_ID.json"
    fi
fi

ui_hex() {
    local key="$1" fallback="$2" hex=""
    if [[ -n "$UI_THEME_FILE" ]]; then
        hex="$(
            grep -o "\"$key\"[[:space:]]*:[[:space:]]*\"#[0-9a-fA-F]\{6\}\"" \
                "$UI_THEME_FILE" 2>/dev/null |
                head -1 |
                grep -o '#[0-9a-fA-F]\{6\}' || true
        )"
    fi
    printf '%s' "${hex:-$fallback}"
}

ui_fg() {
    local hex
    [[ "$UI_COLOR" -eq 1 ]] || {
        printf ''
        return
    }

    if [[ "$UI_TRUECOLOR" -eq 1 ]]; then
        hex="$(ui_hex "$1" "$2")"
        printf '\033[38;2;%d;%d;%dm' \
            "$((16#${hex:1:2}))" \
            "$((16#${hex:3:2}))" \
            "$((16#${hex:5:2}))"
    else
        printf '\033[%sm' "$3"
    fi
}

if [[ "$UI_COLOR" -eq 1 ]]; then
    RESET='\033[0m'
    BOLD='\033[1m'
else
    RESET=''
    BOLD=''
fi

RED="$(ui_fg error '#F38BA8' 31)"
GREEN="$(ui_fg success '#A6E3A1' 32)"
YELLOW="$(ui_fg warning '#F9E2AF' 33)"
BLUE="$(ui_fg info '#89B4FA' 34)"
MAGENTA="$(ui_fg terminalMagenta '#F5C2E7' 35)"
CYAN="$(ui_fg accent '#CBA6F7' 36)"
DIM="$(ui_fg textMuted '#989CAC' 2)"

ICON_OK="✓"
ICON_FAIL="✗"
ICON_WARN="!"
ICON_INFO="ℹ"
ICON_ARROW="→"
ICON_SECTION="◆"
ICON_STEP="▸"
ICON_DOT="·"
ICON_GEAR="⚙"
ICON_TOOLS="▸"
ICON_SHIELD="✓"

UI_TL="╭"
UI_TR="╮"
UI_BL="╰"
UI_BR="╯"
UI_H="─"
UI_V="│"
UI_RULE="─"
UI_SPIN=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")

if [[ "$UI_UNICODE" -eq 0 ]]; then
    ICON_OK="ok"
    ICON_FAIL="x"
    ICON_WARN="!"
    ICON_INFO="i"
    ICON_ARROW=">"
    ICON_SECTION="*"
    ICON_STEP=">"
    ICON_DOT="-"
    ICON_GEAR="*"
    ICON_TOOLS=">"
    ICON_SHIELD="+"
    UI_TL="+"
    UI_TR="+"
    UI_BL="+"
    UI_BR="+"
    UI_H="-"
    UI_V="|"
    UI_RULE="-"
    UI_SPIN=("|" "/" "-" "\\")
fi

hide_cursor() {
    [[ "$IS_TTY" -eq 1 ]] && tput civis 2>/dev/null || true
}

show_cursor() {
    [[ "$IS_TTY" -eq 1 ]] && tput cnorm 2>/dev/null || true
}

trap show_cursor EXIT INT TERM

ui_repeat() {
    local char="$1" count="$2" out="" i
    for ((i = 0; i < count; i++)); do out+="$char"; done
    printf '%s' "$out"
}

ui_visible_len() {
    local stripped
    stripped="$(printf '%b' "$1" | sed -E 's/\x1b\[[0-9;]*m//g')"
    printf '%s' "${#stripped}"
}

clear_screen() {
    [[ "$IS_TTY" -eq 1 ]] && clear 2>/dev/null || true
}

hr() {
    printf '  %b%s%b\n' "$DIM" "$(ui_repeat "$UI_RULE" "$((UI_WIDTH - 2))")" "$RESET"
}

hr_accent() {
    printf '  %b%s%b\n' "$CYAN" "$(ui_repeat "$UI_RULE" "$((UI_WIDTH - 2))")" "$RESET"
}

die() {
    printf '  %b%s%b %s\n' "$RED" "$ICON_FAIL" "$RESET" "$*" >&2
    exit 1
}

info() { printf '  %b%s%b %s\n' "$BLUE" "$ICON_INFO" "$RESET" "$*"; }
success() { printf '  %b%s%b %s\n' "$GREEN" "$ICON_OK" "$RESET" "$*"; }
warning() { printf '  %b%s%b %s\n' "$YELLOW" "$ICON_WARN" "$RESET" "$*"; }
error() { printf '  %b%s%b %s\n' "$RED" "$ICON_FAIL" "$RESET" "$*" >&2; }
run_cmd() { printf '  %b%s%b %b%s%b\n' "$MAGENTA" "$ICON_ARROW" "$RESET" "$DIM" "$*" "$RESET"; }

section() {
    printf '\n  %b%b%s %s%b\n' "$CYAN" "$ICON_SECTION" "$BOLD" "$1" "$RESET"
    hr
}

subsection() {
    printf '\n  %b%s %s%b\n' "$CYAN" "$ICON_STEP" "$1" "$RESET"
}

kv() {
    local key="$1"
    shift || true
    printf '  %b%-12s%b %b%s%b %s\n' \
        "$DIM" "$key" "$RESET" "$DIM" "$ICON_DOT" "$RESET" "$*"
}

pause() {
    [[ "$IS_TTY" -eq 1 ]] || return 0
    echo
    printf '  %bPress Enter to continue...%b ' "$DIM" "$RESET"
    read -r _ || true
}

confirm() {
    local prompt="${1:-Continue?}" answer
    [[ "$IS_TTY" -eq 1 ]] || return 1
    echo
    printf '  %b?%b %s %b[y/N]:%b ' "$YELLOW" "$RESET" "$prompt" "$DIM" "$RESET"
    read -r answer || return 1
    [[ "$answer" =~ ^[Yy]([Ee][Ss])?$ ]]
}

confirm_exact() {
    local prompt="$1" expected="$2" answer
    echo
    printf '  %b!%b %s\n' "$RED" "$RESET" "$prompt"
    printf '  %bType %s to continue:%b ' "$YELLOW" "$expected" "$RESET"
    read -r answer || return 1
    [[ "$answer" == "$expected" ]]
}

panel() {
    local title="$1" tag="${2:-}"
    shift 2 || true

    local inner=$((UI_WIDTH - 2))
    local head=" $title " tail="" pad
    [[ -n "$tag" ]] && tail=" $tag "

    pad=$((inner - ${#head} - ${#tail} - 1))
    if ((pad < 1)); then
        pad=1
    fi
    printf '%b%s%s%b%s%b%s%s%s%b\n' \
        "$CYAN" "$UI_TL" "$UI_H" "$BOLD" "$head" "$RESET$CYAN" \
        "$(ui_repeat "$UI_H" "$pad")" "$tail" "$UI_TR" "$RESET"

    local line len
    for line in "$@"; do
        len="$(ui_visible_len "$line")"
        pad=$((inner - len - 2))
        if ((pad < 0)); then
            pad=0
        fi

        printf '%b%s%b %s%s%b%s %b%s%b\n' \
            "$CYAN" "$UI_V" "$RESET" \
            "$line" "$(ui_repeat ' ' "$pad")" "$RESET" \
            "" "$CYAN" "$UI_V" "$RESET"
    done

    printf '%b%s%s%s%b\n' \
        "$CYAN" "$UI_BL" "$(ui_repeat "$UI_H" "$inner")" "$UI_BR" "$RESET"
}

spinner() {
    local label="$1"
    shift
    local log rc=0
    log="$(mktemp)"

    if [[ "$IS_TTY" -eq 0 ]]; then
        run_cmd "$label"
        if "$@" >"$log" 2>&1; then
            success "$label"
        else
            rc=$?
            error "$label"
            cat "$log" >&2
        fi
        rm -f "$log"
        return "$rc"
    fi

    "$@" >"$log" 2>&1 &
    local pid=$!
    local frame=0 start=$SECONDS

    hide_cursor
    while kill -0 "$pid" 2>/dev/null; do
        printf '\r  %b%s%b %s %b%ds%b' \
            "$CYAN" "${UI_SPIN[$frame]}" "$RESET" \
            "$label" "$DIM" "$((SECONDS - start))" "$RESET"
        frame=$(((frame + 1) % ${#UI_SPIN[@]}))
        sleep 0.08
    done

    wait "$pid" || rc=$?
    show_cursor
    printf '\r\033[2K'

    if [[ "$rc" -eq 0 ]]; then
        success "$label ($((SECONDS - start))s)"
    else
        error "$label failed after $((SECONDS - start))s"
        cat "$log" >&2
    fi

    rm -f "$log"
    return "$rc"
}

need_cmd() {
    command -v "$1" >/dev/null 2>&1 ||
        die "Required command not found: $1"
}

check_dependencies() {
    local cmd
    for cmd in "$@"; do
        need_cmd "$cmd"
    done
}

# ============================================================================
# GENERAL HELPERS
# ============================================================================

is_root() {
    [[ "$(id -u)" -eq 0 ]]
}

run_root() {
    if is_root; then
        "$@"
    else
        sudo "$@"
    fi
}

root_cmd() {
    if is_root; then
        "$*"
    else
        sudo bash -c "$*"
    fi
}

is_live_installer() {
    grep -qsE '^VARIANT_ID="?installer"?' /etc/os-release 2>/dev/null && return 0
    [[ -d /iso ]] && return 0
    findmnt -no TARGET /nix/.ro-store >/dev/null 2>&1 && return 0
    return 1
}

preflight_repo() {
    [[ -d "$ROOT" ]] || die "Repository root not found: $ROOT"
    [[ -f "$ROOT/$VARS_REL" ]] ||
        die "Missing $ROOT/$VARS_REL"
}

uptime_human() {
    local secs d h m
    [[ -r /proc/uptime ]] || {
        printf 'unknown'
        return
    }
    read -r secs _ </proc/uptime
    secs="${secs%%.*}"
    d=$((secs / 86400))
    h=$((secs % 86400 / 3600))
    m=$((secs % 3600 / 60))

    if ((d > 0)); then
        printf '%dd %dh' "$d" "$h"
    elif ((h > 0)); then
        printf '%dh %dm' "$h" "$m"
    else
        printf '%dm' "$m"
    fi
}

overview_facts() {
    local nixv
    nixv="$(nix --version 2>/dev/null | grep -o '[0-9.]\+' | head -1 || true)"
    printf '%s · %s · nix %s · up %s' \
        "${USER:-$(whoami 2>/dev/null || echo user)}" \
        "$(uname -r)" \
        "${nixv:-?}" \
        "$(uptime_human)"
}

# ============================================================================
# NIX CONFIGURATION
# ============================================================================

get_var() {
    local key="$1"
    [[ -f "$ROOT/$VARS_REL" ]] || return 1
    sed -nE \
        "s/^[[:space:]]*${key}[[:space:]]*=[[:space:]]*\"([^\"]*)\";.*/\1/p" \
        "$ROOT/$VARS_REL" | head -n1
}

set_var_in() {
    local file="$1" key="$2" value="$3"
    [[ -f "$file" ]] || die "Missing $file"

    grep -qE \
        "^[[:space:]]*${key}[[:space:]]*=[[:space:]]*\"" "$file" ||
        die "Could not find variable '$key' in $file"

    local esc
    esc="$(printf '%s' "$value" | sed -e 's/[\\&|]/\\&/g')"

    sed -i -E \
        "s|^([[:space:]]*${key}[[:space:]]*=[[:space:]]*)\"[^\"]*\"(;.*)\$|\1\"${esc}\"\2|" \
        "$file"
}

set_nvidia_in() {
    local file="$1" value="$2"

    python3 - "$file" "$value" <<'PY'
import re
import sys

path, value = sys.argv[1], sys.argv[2]
text = open(path, encoding="utf-8").read()

pattern = re.compile(
    r'(?ms)(nvidia\s*=\s*\{.*?^\s*enable\s*=\s*)(true|false)(\s*;)',
)

match = pattern.search(text)
if not match:
    raise SystemExit("Could not find nvidia.enable in variables.nix")

text = text[:match.start(2)] + value + text[match.end(2):]
open(path, "w", encoding="utf-8").write(text)
PY
}

backup_config() {
    preflight_repo

    local stamp backup
    stamp="$(date +%Y%m%d-%H%M%S)"
    backup="$ROOT/.setup-backups/$stamp"
    mkdir -p "$backup"

    [[ -f "$ROOT/$VARS_REL" ]] &&
        cp -a "$ROOT/$VARS_REL" "$backup/variables.nix"

    [[ -f "$ROOT/flake.lock" ]] &&
        cp -a "$ROOT/flake.lock" "$backup/"

    [[ -f "$ROOT/hosts/sunflower/hardware-configuration.nix" ]] &&
        cp -a "$ROOT/hosts/sunflower/hardware-configuration.nix" "$backup/"

    {
        printf 'timestamp=%s\n' "$stamp"
        printf 'root=%s\n' "$ROOT"
        if command -v git >/dev/null 2>&1 && git -C "$ROOT" rev-parse HEAD >/dev/null 2>&1; then
            printf 'git_commit=%s\n' "$(git -C "$ROOT" rev-parse HEAD)"
        fi
    } >"$backup/metadata"

    success "Backup created: $backup"
}

configure_variables() {
    local vars_file="$1"
    local username="$2"
    local full_name="$3"
    local hostname="$4"
    local git_user="$5"
    local git_email="$6"
    local timezone="$7"
    local locale="$8"
    local nvidia="$9"

    section "Configuring Sunflower"

    set_var_in "$vars_file" username "$username"
    set_var_in "$vars_file" name "$full_name"
    set_var_in "$vars_file" hostname "$hostname"
    set_var_in "$vars_file" gitUser "$git_user"
    set_var_in "$vars_file" email "$git_email"
    set_var_in "$vars_file" timezone "$timezone"
    set_var_in "$vars_file" locale "$locale"
    set_nvidia_in "$vars_file" "$nvidia"

    success "Sunflower identity and hardware settings configured."
}

# ============================================================================
# EXISTING SYSTEM
# ============================================================================

flake_check() {
    preflight_repo
    check_dependencies nix

    section "Flake validation"
    run_cmd "nix flake check"
    nix flake check --show-trace
    success "Flake check passed."
}

dry_build() {
    preflight_repo
    check_dependencies nix nixos-rebuild

    section "Sunflower dry build"
    run_cmd "nixos-rebuild dry-build --flake $FLAKE_TARGET"
    run_root nixos-rebuild dry-build --flake "$FLAKE_TARGET"
    success "Dry-build passed."
}

rebuild() {
    preflight_repo
    check_dependencies nix nixos-rebuild sudo

    flake_check
    dry_build

    section "Sunflower rebuild"
    run_cmd "nixos-rebuild switch --flake $FLAKE_TARGET"
    run_root nixos-rebuild switch --flake "$FLAKE_TARGET"
    success "System rebuilt and switched successfully."
}

update_config() {
    preflight_repo
    check_dependencies git nix

    section "Update configuration"
    cd "$ROOT"

    if [[ -n "$(git status --porcelain)" ]]; then
        warning "Working tree contains uncommitted changes."
        git status --short
        confirm "Continue with update?" || return 0
    fi

    run_cmd "git pull --ff-only"
    git pull --ff-only

    run_cmd "nix flake update"
    nix flake update

    flake_check

    if confirm "Rebuild and switch now?"; then
        rebuild
    else
        success "Configuration updated. Rebuild when ready."
    fi
}

rollback() {
    check_dependencies nixos-rebuild sudo

    section "Rollback"
    warning "This switches to the previous system generation."
    confirm "Continue with rollback?" || return 0

    run_root nixos-rebuild switch --rollback
    success "Rollback completed."
}

list_generations() {
    check_dependencies nix-env sudo

    section "Sunflower generations"
    run_root nix-env \
        --list-generations \
        --profile /nix/var/nix/profiles/system
}

refresh_hardware() {
    preflight_repo
    check_dependencies nixos-generate-config sudo

    section "Hardware configuration"

    if is_live_installer; then
        warning "You are running from the Sunflower installer."
        warning "Generating hardware configuration here describes the live ISO."
        info "For a fresh installation use: ./setup.sh clean-install"
        confirm "Generate for the current live environment anyway?" || return 0
    fi

    backup_config

    run_cmd "nixos-generate-config --show-hardware-config"
    if is_root; then
        nixos-generate-config \
            --show-hardware-config \
            >"$ROOT/hosts/sunflower/hardware-configuration.nix"
    else
        sudo nixos-generate-config \
            --show-hardware-config \
            >"$ROOT/hosts/sunflower/hardware-configuration.nix"
    fi

    success "Hardware configuration regenerated."
    warning "Review the generated file before rebuilding."
}

detect_nvidia() {
    command -v lspci >/dev/null 2>&1 &&
        lspci -nn 2>/dev/null | grep -qi NVIDIA
}

configure_existing_system() {
    preflight_repo
    check_dependencies nix python3 git sudo

    if is_live_installer; then
        die "Use 'clean-install' from the live installer. Existing-system setup is disabled there."
    fi

    section "Sunflower Configuration"

    local username="${SUDO_USER:-${USER:-}}"
    local full_name hostname git_user git_email timezone locale
    local nvidia="false"

    read -r -p "  Linux username [$username]: " username
    username="${username:-${SUDO_USER:-${USER:-}}}"
    [[ "$username" =~ ^[a-z_][a-z0-9_-]*[$]?$ ]] ||
        die "Invalid Linux username."

    read -r -p "  Full name: " full_name
    [[ -n "$full_name" ]] || die "Full name cannot be empty."

    hostname_default="$(hostname -s 2>/dev/null || echo nixos)"
    read -r -p "  Hostname [$hostname_default]: " hostname
    hostname="${hostname:-$hostname_default}"
    [[ "$hostname" =~ ^[a-zA-Z0-9][a-zA-Z0-9.-]*$ ]] ||
        die "Invalid hostname."

    read -r -p "  Git username: " git_user
    read -r -p "  Git email: " git_email
    read -r -p "  Timezone [Asia/Kolkata]: " timezone
    timezone="${timezone:-Asia/Kolkata}"
    read -r -p "  Locale [en_US.UTF-8]: " locale
    locale="${locale:-en_US.UTF-8}"

    if detect_nvidia; then
        nvidia=true
        info "NVIDIA GPU detected."
    else
        read -r -p "  Enable NVIDIA support anyway? [y/N]: " ans
        [[ "$ans" =~ ^[Yy]$ ]] && nvidia=true
    fi

    section "Review"
    kv "Username" "$username"
    kv "Full name" "$full_name"
    kv "Hostname" "$hostname"
    kv "Git user" "$git_user"
    kv "Git email" "$git_email"
    kv "Timezone" "$timezone"
    kv "Locale" "$locale"
    kv "NVIDIA" "$nvidia"

    confirm "Apply these settings?" || {
        warning "Configuration cancelled."
        return 0
    }

    backup_config
    configure_variables \
        "$ROOT/$VARS_REL" \
        "$username" "$full_name" "$hostname" \
        "$git_user" "$git_email" "$timezone" "$locale" "$nvidia"

    rebuild

    if id "$username" >/dev/null 2>&1; then
        info "Set the Linux password for $username."
        run_root passwd "$username"
    fi

    success "Sunflower configuration completed."
}

# ============================================================================
# MAINTENANCE
# ============================================================================

m_cleanup_generations() {
    check_dependencies nix-env sudo

    section "Generations cleanup"

    run_root nix-env \
        --profile /nix/var/nix/profiles/system \
        --delete-generations "+$M_KEEP_GENERATIONS"

    success "Old generations cleaned. Keeping the newest $M_KEEP_GENERATIONS."
}

m_garbage_collect() {
    check_dependencies nix-collect-garbage sudo

    section "Garbage collection"
    run_root nix-collect-garbage -d
    success "Garbage collection completed."
}

m_optimize_store() {
    check_dependencies nix-store sudo

    section "Optimizing Nix store"
    run_root nix-store --optimise
    success "Nix store optimized."
}

m_verify_store() {
    check_dependencies nix-store sudo

    section "Verifying Nix store"
    run_root nix-store --verify --check-contents
    success "Nix store verified."
}

m_maintenance_dashboard() {
    clear_screen

    panel "Sunflower Maintenance" "v$VERSION" \
        "Repository: $ROOT" \
        "Generations kept: $M_KEEP_GENERATIONS"

    echo
    section "Health"

    if flake_check; then
        success "Flake: healthy"
    else
        error "Flake: failed"
    fi

    if [[ -e /run/current-system ]]; then
        info "Current system: $(readlink -f /run/current-system)"
    fi

    if command -v nix-store >/dev/null 2>&1; then
        info "Nix store: $(du -sh /nix/store 2>/dev/null | awk '{print $1}' || echo '?')"
    fi

    if command -v nix-env >/dev/null 2>&1; then
        list_generations
    fi

    pause
}

validator_run() {
    preflight_repo
    clear_screen

    panel "Sunflower Configuration Check" "v$VERSION" \
        "Repository: $ROOT"

    flake_check
}

free_space() {
    section "Disk Space Management"

    m_cleanup_generations
    m_garbage_collect

    if confirm "Optimize the Nix store too?"; then
        m_optimize_store
    fi
}

# ============================================================================
# LIVE INSTALLER
# ============================================================================

ci_require_live() {
    is_live_installer ||
        die "This command must be run from the Sunflower/NixOS live installer."

    check_dependencies \
        nixos-install \
        nixos-generate-config \
        sgdisk \
        mkfs.fat \
        mkfs.ext4 \
        mount \
        umount \
        lsblk \
        findmnt \
        blkid \
        chroot \
        cp \
        rsync
}

ci_require_uefi() {
    if [[ -d /sys/firmware/efi ]]; then
        success "UEFI boot detected."
    else
        warning "The installer is running in BIOS/legacy mode."
        warning "Sunflower's current installer creates an EFI/GPT layout."
        warning "Boot the VM/ISO using UEFI firmware."
        die "UEFI is required for this installer."
    fi
}

ci_part_path() {
    local disk="$1"
    local part="$2"

    if [[ "$disk" =~ [0-9]$ ]]; then
        printf '%sp%s\n' "$disk" "$part"
    else
        printf '%s%s\n' "$disk" "$part"
    fi
}

ci_disk_desc() {
    local disk="$1"
    lsblk -dnpo NAME,SIZE,MODEL,TRAN "$disk" 2>/dev/null |
        sed -E 's/[[:space:]]+/ /g' || true
}

ci_disk_is_system_root() {
    local disk="$1"
    local root_source parent

    root_source="$(findmnt -no SOURCE / 2>/dev/null || true)"
    [[ -n "$root_source" ]] || return 1

    parent="$(lsblk -no PKNAME "$root_source" 2>/dev/null || true)"
    [[ "/dev/$parent" == "$disk" ]]
}

ci_select_disk() {
    section "Target Disk"

    info "Available disks:"
    echo
    lsblk -d -e 7 -o NAME,SIZE,MODEL,TYPE,TRAN 2>/dev/null || true
    echo

    local disk
    read -r -p "  Target disk (example: /dev/vda, /dev/sda, /dev/nvme0n1): " disk
    [[ -b "$disk" ]] || die "Device does not exist: $disk"

    [[ "$(lsblk -dn -o TYPE "$disk")" == "disk" ]] ||
        die "$disk is not a whole disk."

    if ci_disk_is_system_root "$disk"; then
        die "$disk appears to contain the currently running system. Refusing to erase it."
    fi

    CI_DISK="$disk"
    CI_ESP="$(ci_part_path "$CI_DISK" 1)"
    CI_ROOT_PART="$(ci_part_path "$CI_DISK" 2)"

    echo
    panel "Selected Disk" "" \
        "Device: $CI_DISK" \
        "Info:   $(ci_disk_desc "$CI_DISK")" \
        "EFI:    $CI_ESP" \
        "Root:   $CI_ROOT_PART"

    warning "EVERYTHING on $CI_DISK will be erased."
    confirm_exact \
        "This operation destroys all partitions and data on $CI_DISK." \
        "ERASE $CI_DISK" ||
        die "Installation cancelled."

    export CI_DISK CI_ESP CI_ROOT_PART
}

ci_prepare_partitions() {
    section "Partitioning"

    if ((CI_DRY_RUN)); then
        info "DRY RUN: would erase the partition table on $CI_DISK."
        info "DRY RUN: would create a 1 GiB EFI System Partition."
        info "DRY RUN: would create an ext4 root partition using the remaining space."
        return 0
    fi

    run_cmd "sgdisk --zap-all $CI_DISK"
    sgdisk --zap-all "$CI_DISK"

    run_cmd "sgdisk --clear $CI_DISK"
    sgdisk --clear "$CI_DISK"

    run_cmd "sgdisk --new=1:0:$CI_ESP_SIZE --typecode=1:ef00 --change-name=1:$CI_ESP_LABEL $CI_DISK"
    sgdisk \
        --new=1:0:"$CI_ESP_SIZE" \
        --typecode=1:ef00 \
        --change-name=1:"$CI_ESP_LABEL" \
        "$CI_DISK"

    run_cmd "sgdisk --new=2:0:0 --typecode=2:8300 --change-name=2:$CI_ROOT_LABEL $CI_DISK"
    sgdisk \
        --new=2:0:0 \
        --typecode=2:8300 \
        --change-name=2:"$CI_ROOT_LABEL" \
        "$CI_DISK"

    partprobe "$CI_DISK" 2>/dev/null || true
    udevadm settle 2>/dev/null || true

    [[ -b "$CI_ESP" ]] || die "EFI partition was not created: $CI_ESP"
    [[ -b "$CI_ROOT_PART" ]] || die "Root partition was not created: $CI_ROOT_PART"

    success "GPT partition table created."
}

ci_format_partitions() {
    section "Formatting"

    if ((CI_DRY_RUN)); then
        info "DRY RUN: would format $CI_ESP as FAT32."
        info "DRY RUN: would format $CI_ROOT_PART as ext4."
        return 0
    fi

    run_cmd "mkfs.fat -F32 -n $CI_ESP_LABEL $CI_ESP"
    mkfs.fat -F32 -n "$CI_ESP_LABEL" "$CI_ESP"

    run_cmd "mkfs.ext4 -F -L $CI_ROOT_LABEL $CI_ROOT_PART"
    mkfs.ext4 -F -L "$CI_ROOT_LABEL" "$CI_ROOT_PART"

    success "Partitions formatted."
}

ci_mount() {
    section "Mounting target filesystems"

    if ((CI_DRY_RUN)); then
        info "DRY RUN: would mount $CI_ROOT_PART at $CI_TARGET."
        info "DRY RUN: would mount $CI_ESP at $CI_TARGET/boot."
        return 0
    fi

    mkdir -p "$CI_TARGET"

    if mountpoint -q "$CI_TARGET"; then
        die "$CI_TARGET is already mounted. Refusing to overwrite it."
    fi

    run_cmd "mount $CI_ROOT_PART $CI_TARGET"
    mount "$CI_ROOT_PART" "$CI_TARGET"

    mkdir -p "$CI_TARGET/boot"

    run_cmd "mount $CI_ESP $CI_TARGET/boot"
    mount "$CI_ESP" "$CI_TARGET/boot"

    CI_MOUNTED=1

    findmnt "$CI_TARGET" >/dev/null ||
        die "Root filesystem is not mounted correctly."

    findmnt "$CI_TARGET/boot" >/dev/null ||
        die "EFI filesystem is not mounted correctly."

    success "Target filesystems mounted."
}

ci_unmount() {
    ((CI_MOUNTED)) || return 0

    sync || true

    umount -R "$CI_TARGET" 2>/dev/null || {
        warning "Some target filesystems could not be unmounted automatically."
    }

    CI_MOUNTED=0
}

ci_cleanup() {
    if ((CI_MOUNTED)); then
        ci_unmount
    fi
}

ci_copy_repository() {
    local target_user="$1"
    local dest="$CI_TARGET/home/$target_user/Sunflower"

    section "Deploying Sunflower"

    if ((CI_DRY_RUN)); then
        info "DRY RUN: would copy:"
        info "  $ROOT"
        info "to:"
        info "  $dest"
        return 0
    fi

    mkdir -p "$CI_TARGET/home/$target_user"

    [[ ! -e "$dest" ]] ||
        die "Target Sunflower directory already exists: $dest"

    # Copy CONTENTS, not the directory itself.
    # This avoids /Sunflower/Sunflower nesting and makes the destination exact.
    run_cmd "rsync -a --exclude .git $ROOT/ $dest/"
    rsync -a --exclude .git "$ROOT"/ "$dest"/

    chown -R "$target_user:users" "$CI_TARGET/home/$target_user" 2>/dev/null || true

    success "Sunflower deployed to $dest"
}

ci_generate_hardware() {
    local target_repo="$CI_TARGET/home/$1/Sunflower"
    local hardware="$target_repo/hosts/sunflower/hardware-configuration.nix"

    section "Generating hardware configuration"

    if ((CI_DRY_RUN)); then
        info "DRY RUN: would generate hardware configuration for the installed system."
        info "DRY RUN: target: $hardware"
        return 0
    fi

    mkdir -p "$(dirname "$hardware")"

    nixos-generate-config \
        --root "$CI_TARGET" \
        --show-hardware-config \
        >"$hardware"

    [[ -s "$hardware" ]] ||
        die "Generated hardware configuration is empty."

    success "Hardware configuration generated."
}

ci_install() {
    local target_user="$1"
    local target_repo="$CI_TARGET/home/$target_user/Sunflower"

    section "Installing NixOS"

    if ((CI_DRY_RUN)); then
        info "DRY RUN: would run:"
        info "nixos-install --flake $target_repo#$FLAKE_NAME"
        return 0
    fi

    [[ -f "$target_repo/flake.nix" ]] ||
        die "Flake not found at $target_repo/flake.nix"

    run_cmd "nixos-install --flake $target_repo#$FLAKE_NAME"

    nixos-install \
        --flake "$target_repo#$FLAKE_NAME" \
        --no-root-password

    success "NixOS installation completed."
}

ci_set_password() {
    local target_user="$1"

    section "User Password"

    if ((CI_DRY_RUN)); then
        info "DRY RUN: would create/set the password for $target_user."
        return 0
    fi

    # nixos-install has already built the system and therefore the configured
    # user should exist in the target system.
    if nixos-enter --root "$CI_TARGET" -- id "$target_user" >/dev/null 2>&1; then
        info "Set the password for $target_user."
        nixos-enter --root "$CI_TARGET" -- passwd "$target_user"
    else
        warning "User '$target_user' was not found in the installed system."
        warning "Check variables.nix and the generated NixOS configuration."
    fi
}

ci_summary() {
    local username="$1"

    section "Installation Complete"

    panel "Sunflower" "ready" \
        "User:     $username" \
        "Hostname: $(get_var hostname 2>/dev/null || echo configured)" \
        "Disk:     $CI_DISK" \
        "Root:     $CI_ROOT_LABEL" \
        "EFI:      $CI_ESP_LABEL"

    echo
    success "Your Sunflower dotfiles and configuration were installed."
    info "The machine is ready to reboot."
    warning "Remove the installer ISO before rebooting."
}

collect_install_identity() {
    local __prefix="$1"

    local username full_name hostname git_user git_email timezone locale
    local nvidia="false"

    username="subha"
    read -r -p "  Username [$username]: " value
    username="${value:-$username}"

    [[ "$username" =~ ^[a-z_][a-z0-9_-]*[$]?$ ]] ||
        die "Invalid Linux username."

    full_name=""
    read -r -p "  Full name: " full_name
    [[ -n "$full_name" ]] ||
        die "Full name cannot be empty."

    hostname="sunflower"
    read -r -p "  Hostname [$hostname]: " value
    hostname="${value:-$hostname}"
    [[ "$hostname" =~ ^[a-zA-Z0-9][a-zA-Z0-9.-]*$ ]] ||
        die "Invalid hostname."

    git_user=""
    read -r -p "  Git username: " git_user

    git_email=""
    read -r -p "  Git email: " git_email

    timezone="Asia/Kolkata"
    read -r -p "  Timezone [$timezone]: " value
    timezone="${value:-$timezone}"

    locale="en_US.UTF-8"
    read -r -p "  Locale [$locale]: " value
    locale="${value:-$locale}"

    if detect_nvidia; then
        nvidia=true
        info "NVIDIA GPU detected."
    else
        read -r -p "  Enable NVIDIA support anyway? [y/N]: " ans
        [[ "$ans" =~ ^[Yy]$ ]] && nvidia=true
    fi

    eval "${__prefix}_USERNAME=\$username"
    eval "${__prefix}_FULL_NAME=\$full_name"
    eval "${__prefix}_HOSTNAME=\$hostname"
    eval "${__prefix}_GIT_USER=\$git_user"
    eval "${__prefix}_GIT_EMAIL=\$git_email"
    eval "${__prefix}_TIMEZONE=\$timezone"
    eval "${__prefix}_LOCALE=\$locale"
    eval "${__prefix}_NVIDIA=\$nvidia"
}

clean_install() {
    local arg="${1:-}"

    CI_DRY_RUN=0
    [[ "$arg" == "--dry-run" ]] && CI_DRY_RUN=1

    ci_require_live
    ci_require_uefi
    preflight_repo

    section "Sunflower Clean Installer"

    if ((CI_DRY_RUN)); then
        panel "DRY RUN" "SAFE" \
            "No partitions will be erased." \
            "No filesystems will be formatted." \
            "No filesystems will be mounted." \
            "No NixOS installation will be performed."
        echo
    fi

    ci_select_disk

    section "Installation Identity"
    collect_install_identity CI

    section "Review"

    kv "Disk" "$CI_DISK"
    kv "Username" "$CI_USERNAME"
    kv "Full name" "$CI_FULL_NAME"
    kv "Hostname" "$CI_HOSTNAME"
    kv "Git user" "$CI_GIT_USER"
    kv "Git email" "$CI_GIT_EMAIL"
    kv "Timezone" "$CI_TIMEZONE"
    kv "Locale" "$CI_LOCALE"
    kv "NVIDIA" "$CI_NVIDIA"

    if ((CI_DRY_RUN)); then
        echo
        warning "This is a DRY RUN. No changes will be made."
        confirm "Show the complete planned installation?" || return 0
    else
        echo
        warning "The selected disk will be completely erased."
        confirm_exact \
            "Final confirmation: erase and install Sunflower on $CI_DISK." \
            "INSTALL SUNFLOWER" ||
            die "Installation cancelled."
    fi

    ci_prepare_partitions
    ci_format_partitions
    ci_mount

    if ((CI_DRY_RUN)); then
        ci_copy_repository "$CI_USERNAME"
        ci_generate_hardware "$CI_USERNAME"
        ci_install "$CI_USERNAME"
        ci_set_password "$CI_USERNAME"

        section "Dry Run Complete"
        success "No changes were made."
        return 0
    fi

    # The repository may be on a read-only ISO. Therefore:
    # 1. copy it to /mnt
    # 2. modify the COPY
    # 3. generate hardware config into the COPY
    ci_copy_repository "$CI_USERNAME"

    local target_repo="$CI_TARGET/home/$CI_USERNAME/Sunflower"
    local target_vars="$target_repo/$VARS_REL"

    [[ -f "$target_vars" ]] ||
        die "Target variables file missing: $target_vars"

    configure_variables \
        "$target_vars" \
        "$CI_USERNAME" \
        "$CI_FULL_NAME" \
        "$CI_HOSTNAME" \
        "$CI_GIT_USER" \
        "$CI_GIT_EMAIL" \
        "$CI_TIMEZONE" \
        "$CI_LOCALE" \
        "$CI_NVIDIA"

    ci_generate_hardware "$CI_USERNAME"
    ci_install "$CI_USERNAME"
    ci_set_password "$CI_USERNAME"

    # Make sure everything is flushed before unmounting.
    sync
    ci_unmount

    ci_summary "$CI_USERNAME"
}

# ============================================================================
# INSTALLER PREVIEW
# ============================================================================

test_install() {
    section "Identity Preview"

    local username="${SUDO_USER:-${USER:-testuser}}"
    local full_name="Test User"
    local hostname="sunflower-test"
    local git_user="testuser"
    local git_email="test@example.com"
    local timezone="Asia/Kolkata"
    local locale="en_US.UTF-8"

    read -r -p "  Username [$username]: " value
    username="${value:-$username}"

    read -r -p "  Full name [$full_name]: " value
    full_name="${value:-$full_name}"

    read -r -p "  Hostname [$hostname]: " value
    hostname="${value:-$hostname}"

    read -r -p "  Git username [$git_user]: " value
    git_user="${value:-$git_user}"

    read -r -p "  Git email [$git_email]: " value
    git_email="${value:-$git_email}"

    read -r -p "  Timezone [$timezone]: " value
    timezone="${value:-$timezone}"

    read -r -p "  Locale [$locale]: " value
    locale="${value:-$locale}"

    echo
    info "No files will be changed."

    kv "Username" "$username"
    kv "Full name" "$full_name"
    kv "Hostname" "$hostname"
    kv "Git user" "$git_user"
    kv "Git email" "$git_email"
    kv "Timezone" "$timezone"
    kv "Locale" "$locale"

    success "Identity preview complete."
}

# ============================================================================
# MENU
# ============================================================================

menu_item() {
    local num="$1" label="$2" desc="${3:-}"

    if [[ -z "$desc" ]]; then
        printf '   %b%2s%b  %s\n' "$CYAN" "$num" "$RESET" "$label"
    else
        printf '   %b%2s%b  %-24s%b%s%b\n' \
            "$CYAN" "$num" "$RESET" "$label" "$DIM" "$desc" "$RESET"
    fi
}

menu_group() {
    local icon="$1" title="$2"
    echo
    printf '  %b%s%b  %b%b%s%b\n' \
        "$CYAN" "$icon" "$RESET" "$CYAN" "$BOLD" "$title" "$RESET"
    hr_accent
}

menu_footer() {
    echo
    printf '  %b%s%b  Type a number and press Enter %b(0 to exit)%b\n' \
        "$DIM" "$ICON_DOT" "$RESET" "$DIM" "$RESET"
}

menu() {
    while true; do
        ui_refresh_width
        clear_screen

        echo
        panel "Sunflower Configuration Manager" "v$VERSION" "$(overview_facts)"
        echo

        if is_live_installer; then
            printf '  %b%s%b %b%bLive installer detected — use Fresh Install.%b\n' \
                "$YELLOW" "$ICON_WARN" "$RESET" "$YELLOW" "$BOLD" "$RESET"
            hr
        fi

        menu_group "$ICON_SECTION" "INSTALLATION"
        menu_item 1 "Fresh Install" "partition + install Sunflower"
        menu_item 2 "Install Dry-Run" "preview installation, change nothing"
        menu_item 3 "Identity Preview" "preview identity prompts"

        menu_group "$ICON_GEAR" "SYSTEM"
        menu_item 4 "Rebuild / Switch" "validate + dry-build + switch"
        menu_item 5 "Dry Rebuild" "build without switching"
        menu_item 6 "Check Flake" "evaluate the flake"
        menu_item 7 "Rollback" "previous system generation"
        menu_item 8 "List Generations" "system profile history"
        menu_item 9 "Refresh Hardware" "regenerate hardware config"
        menu_item 10 "Configure Identity" "configure installed system"

        menu_group "$ICON_SHIELD" "MAINTENANCE"
        menu_item 11 "Configuration Check" "flake validation"
        menu_item 12 "Maintenance Dashboard" "read-only system health"
        menu_item 13 "Free Disk Space" "generations + GC"
        menu_item 14 "Optimize Store" "deduplicate the store"
        menu_item 15 "Verify Store" "check store integrity"

        echo
        hr
        menu_item 0 "Exit"
        menu_footer
        echo

        local choice
        printf '  %b%s%b Select: ' "$CYAN" "$ICON_ARROW" "$RESET"
        read -r choice || choice=""

        case "$choice" in
        1)
            clean_install
            pause
            ;;
        2)
            clean_install --dry-run
            pause
            ;;
        3)
            test_install
            pause
            ;;
        4)
            rebuild
            pause
            ;;
        5)
            dry_build
            pause
            ;;
        6)
            flake_check
            pause
            ;;
        7)
            rollback
            pause
            ;;
        8)
            list_generations
            pause
            ;;
        9)
            refresh_hardware
            pause
            ;;
        10)
            configure_existing_system
            pause
            ;;
        11)
            validator_run
            pause
            ;;
        12) m_maintenance_dashboard ;;
        13)
            free_space
            pause
            ;;
        14)
            m_optimize_store
            pause
            ;;
        15)
            m_verify_store
            pause
            ;;
        0)
            clear_screen
            exit 0
            ;;
        *)
            warning "Invalid option."
            sleep 1
            ;;
        esac
    done
}

# ============================================================================
# CLI
# ============================================================================

usage() {
    cat <<EOF
Sunflower v$VERSION

Usage:
  ./setup.sh
  ./setup.sh clean-install
  ./setup.sh clean-install --dry-run

Existing system:
  ./setup.sh install
  ./setup.sh update
  ./setup.sh rebuild
  ./setup.sh dry-build
  ./setup.sh validate
  ./setup.sh rollback
  ./setup.sh generations
  ./setup.sh hardware
  ./setup.sh maintain
  ./setup.sh free-space

Installer:
  clean-install             Fresh UEFI installation
  clean-install --dry-run   SAFE preview; never modifies the disk

EOF
}

main() {
    if [[ $# -eq 0 ]]; then
        menu
        return
    fi

    case "$1" in
    install)
        configure_existing_system
        ;;
    clean-install)
        clean_install "${2:-}"
        ;;
    rebuild)
        rebuild
        ;;
    dry-build)
        dry_build
        ;;
    update)
        update_config
        ;;
    rollback)
        rollback
        ;;
    validate)
        validator_run
        ;;
    generations | list-generations)
        list_generations
        ;;
    hardware | refresh-hardware)
        refresh_hardware
        ;;
    maintain)
        m_maintenance_dashboard
        ;;
    free-space)
        free_space
        ;;
    preview | identity-preview)
        test_install
        ;;
    help | -h | --help)
        usage
        ;;
    *)
        die "Unknown command: $1. Use --help."
        ;;
    esac
}

main "$@"
