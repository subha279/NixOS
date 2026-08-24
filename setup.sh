#!/usr/bin/env bash
set -Eeuo pipefail

VERSION="1.1.0"
REPO="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
VARS="$REPO/lib/variables.nix"

if [[ -t 1 ]]; then
    RESET='\033[0m'
    BOLD='\033[1m'
    C='\033[36m'
    G='\033[32m'
    Y='\033[33m'
    R='\033[31m'
    M='\033[35m'
else
    RESET=''
    BOLD=''
    C=''
    G=''
    Y=''
    R=''
    M=''
fi

info() { printf "%bℹ%b %s\n" "$C" "$RESET" "$*"; }
ok() { printf "%b✓%b %s\n" "$G" "$RESET" "$*"; }
warn() { printf "%b!%b %s\n" "$Y" "$RESET" "$*"; }
die() {
    printf "%b✗%b %s\n" "$R" "$RESET" "$*" >&2
    exit 1
}
need() { command -v "$1" >/dev/null 2>&1 || die "Missing command: $1"; }
confirm() {
    local a
    read -r -p "${1:-Continue?} [y/N] " a
    [[ "$a" =~ ^[Yy]([Ee][Ss])?$ ]]
}

var() { sed -nE "s/^[[:space:]]*$1[[:space:]]*=[[:space:]]*\"([^\"]*)\";.*/\1/p" "$VARS" | head -1; }

setvar() {
    python3 - "$VARS" "$1" "$2" <<'PY'
import re,sys
p,k,v=sys.argv[1:]
s=open(p).read()
pat=rf'(^[ \t]*{re.escape(k)}[ \t]*=[ \t]*)"[^"]*"(;.*)$'
n=re.subn(pat,lambda m:m.group(1)+'"'+v.replace('\\','\\\\').replace('"','\\"')+'"'+m.group(2),s,flags=re.M)
if not n[1]: raise SystemExit(f'Variable not found: {k}')
open(p,'w').write(n[0])
PY
}

# The flake host and the machine hostname are deliberately separate.
# Current repository exposes .#laptop; hostname may be anything.
target() { echo ".#laptop"; }

backup() {
    local d="$REPO/.setup-backups/$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$d"
    [[ -f "$VARS" ]] && cp -a "$VARS" "$d/"
    [[ -f "$REPO/hosts/laptop/hardware-configuration.nix" ]] && cp -a "$REPO/hosts/laptop/hardware-configuration.nix" "$d/"
    ok "Backup: $d"
}

hardware() {
    need nix
    mkdir -p "$REPO/hosts/laptop"
    local t
    t=$(mktemp)
    trap 'rm -f "$t"' RETURN
    info "Generating hardware configuration..."
    sudo nixos-generate-config --show-hardware-config >"$t"
    cp "$t" "$REPO/hosts/laptop/hardware-configuration.nix"
    rm -f "$t"
    ok "Hardware configuration regenerated."
}

check() {
    need nix
    info "Checking flake..."
    nix flake check
    ok "Flake check passed."
}

dry() {
    need nix
    info "Running dry rebuild (no system changes)..."
    sudo nixos-rebuild dry-build --flake "$(target)"
    ok "Dry rebuild passed. No system changes were made."
}

rebuild() {
    check
    printf "\n%bThis will switch your running system to the new configuration.%b\n\n" "$BOLD$Y" "$RESET"
    printf "  Flake target : %s\n" "$(target)"
    printf "  Hostname     : %s\n" "$(var hostname)"
    printf "  User         : %s\n\n" "$(var username)"
    confirm "Continue with NixOS rebuild?" || {
        warn "Rebuild cancelled."
        return 0
    }
    sudo nixos-rebuild switch --flake "$(target)"
    ok "Rebuild complete."
}

install_flow() {
    need nix
    need git
    need python3
    printf "\n%bNixOS Setup Wizard v%s%b\n\n" "$BOLD$M" "$VERSION" "$RESET"

    local u f h gu ge tz lo x
    u="${SUDO_USER:-${USER:-}}"

    read -r -p "Linux username [$u]: " x
    u="${x:-$u}"
    [[ "$u" =~ ^[a-z_][a-z0-9_-]*$ ]] || die "Invalid username"

    read -r -p "Full name: " f
    [[ -n "$f" ]] || die "Full name required"

    read -r -p "Hostname [nixos]: " h
    h="${h:-nixos}"
    [[ "$h" =~ ^[a-zA-Z0-9][a-zA-Z0-9.-]*$ ]] || die "Invalid hostname"

    read -r -p "Git username: " gu
    read -r -p "Git email: " ge
    read -r -p "Timezone [Asia/Kolkata]: " tz
    tz="${tz:-Asia/Kolkata}"
    read -r -p "Locale [en_US.UTF-8]: " lo
    lo="${lo:-en_US.UTF-8}"

    printf "\n%bReview%b\n" "$BOLD" "$RESET"
    printf "Username   : %s\nFull name  : %s\nHostname   : %s\nGit        : %s <%s>\nTimezone   : %s\nLocale     : %s\n\n" "$u" "$f" "$h" "$gu" "$ge" "$tz" "$lo"

    confirm "Apply and rebuild?" || {
        warn "Installation cancelled."
        return 0
    }

    backup
    setvar username "$u"
    setvar fullName "$f"
    setvar hostname "$h"
    setvar gitUser "$gu"
    setvar email "$ge"
    setvar timezone "$tz"
    setvar locale "$lo"
    ok "User configuration updated."

    hardware
    check
    dry

    printf "\n%bReady to install%b\n\n" "$BOLD$M" "$RESET"
    confirm "Switch to this configuration now?" || {
        warn "Configuration prepared but not switched."
        return 0
    }

    sudo nixos-rebuild switch --flake "$(target)"
    info "Set the Linux password interactively. It is never stored in Nix."
    sudo passwd "$u"
    ok "Installation complete."
}

# Safe preview: exercises the installer prompts but never edits files or rebuilds.
test_install() {
    need python3
    printf "\n%bInstaller Preview / Test%b\n\n" "$BOLD$M" "$RESET"
    local u f h gu ge tz lo x
    u="${SUDO_USER:-${USER:-}}"
    read -r -p "Linux username [$u]: " x
    u="${x:-$u}"
    read -r -p "Full name [Test User]: " f
    f="${f:-Test User}"
    read -r -p "Hostname [test-nixos]: " h
    h="${h:-test-nixos}"
    read -r -p "Git username [test-user]: " gu
    gu="${gu:-test-user}"
    read -r -p "Git email [test@example.com]: " ge
    ge="${ge:-test@example.com}"
    read -r -p "Timezone [Asia/Kolkata]: " tz
    tz="${tz:-Asia/Kolkata}"
    read -r -p "Locale [en_US.UTF-8]: " lo
    lo="${lo:-en_US.UTF-8}"

    printf "\n%bNothing will be changed.%b\n\n" "$BOLD$G" "$RESET"
    printf "username = \"%s\";\nhostname = \"%s\";\ngitUser = \"%s\";\nfullName = \"%s\";\nemail = \"%s\";\ntimezone = \"%s\";\nlocale = \"%s\";\n\n" "$u" "$h" "$gu" "$f" "$ge" "$tz" "$lo"
    ok "Installer preview completed."
    ok "No files modified."
    ok "No hardware configuration regenerated."
    ok "No NixOS rebuild performed."
    ok "No password changed."
}

update_flow() {
    need git
    need nix
    info "Updating repository..."
    git -C "$REPO" pull --ff-only
    info "Updating flake inputs..."
    nix flake update --flake "$REPO"
    check
    if confirm "Rebuild now?"; then rebuild; else ok "Update complete; rebuild skipped."; fi
}

rollback() {
    printf "\n%bRollback%b\n\n" "$BOLD$Y" "$RESET"
    warn "This will switch to the previous NixOS generation."
    confirm "Continue?" && sudo nixos-rebuild switch --rollback
}

gc() {
    printf "\n%bGarbage Collection%b\n\n" "$BOLD$M" "$RESET"
    printf "1) Delete generations older than 30 days\n"
    printf "2) Delete all unused store paths\n"
    printf "0) Cancel\n\n"
    read -r -p "Select: " c
    case "$c" in
    1) confirm "Delete generations older than 30 days?" && sudo nix-collect-garbage --delete-older-than 30d ;;
    2) confirm "Delete all unused paths?" && sudo nix-collect-garbage -d ;;
    *) return 0 ;;
    esac
}

generations() { sudo nixos-rebuild list-generations; }

menu() {
    while :; do
        printfclear 2>/dev/null || true
        printf "%b╭────────────────────────────────────────────╮%b\n" "$M" "$RESET"
        printf "%b│        NixOS Configuration Manager         │%b\n" "$M" "$RESET"
        printf "%b│                   v%-3s                   │%b\n" "$M" "$VERSION" "$RESET"
        printf "%b╰────────────────────────────────────────────╯%b\n\n" "$M" "$RESET"
        printf "%b  SYSTEM%b\n" "$BOLD" "$RESET" "  1  Install / Setup\n  2  Update configuration\n  3  Rebuild / Switch\n  4  Dry rebuild\n  5  Check flake\n\n"
        printf "%b  RECOVERY & TOOLS%b\n" "$BOLD" "$RESET"
        printf "  6  Rollback\n  7  Refresh hardware config\n  8  Garbage collection\n  9  List generations\n 10  Test installer (preview)\n  0  Exit\n\n"
        read -r -p "Select: " c
        printf "\n"
        case "$c" in
        1) install_flow ;; 2) update_flow ;; 3) rebuild ;; 4) dry ;; 5) check ;;
        6) rollback ;; 7) hardware ;; 8) gc ;; 9) generations ;; 10) test_install ;;
        0)
            ok "Goodbye."
            exit 0
            ;;
        *) warn "Invalid option." ;;
        esac
        printf "\n"
        read -r -p "Press Enter to continue..." _
    done
}

help() {
    cat <<TXT
NixOS Configuration Manager v$VERSION

Usage:
  ./setup.sh                         Interactive menu
  ./setup.sh install                 First-time setup
  ./setup.sh test-install            Safe installer preview
  ./setup.sh update                  Pull repo + update flake inputs
  ./setup.sh rebuild                 Check + switch configuration
  ./setup.sh dry                     Dry rebuild
  ./setup.sh check                   Flake check
  ./setup.sh rollback                Roll back one generation
  ./setup.sh hardware                Regenerate hardware config
  ./setup.sh gc                      Garbage collection
  ./setup.sh generations             List system generations
  ./setup.sh help                   Show this help
  ./setup.sh version                Show version

Passwords are never stored in the Nix configuration.
TXT
}

cd "$REPO"
case "${1:-menu}" in
menu) menu ;; install) install_flow ;; test-install | test) test_install ;; update) update_flow ;;
rebuild | switch) rebuild ;; dry | dry-build) dry ;; check | validate) check ;; rollback) rollback ;;
hardware | hw) hardware ;; gc | garbage-collect) gc ;; generations | list-generations) generations ;;
help | -h | --help) help ;; version | -v | --version) echo "$VERSION" ;;
*) die "Unknown command: $1. Use './setup.sh help'." ;;
esac
