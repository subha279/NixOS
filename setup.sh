#!/usr/bin/env bash
set -Eeuo pipefail

# ============================================================
# Single entry point: install, update, rebuild, validate,
# maintenance, rollback and system recovery.
# ============================================================

VERSION="1.2.1"
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
VARS="$ROOT/lib/variables.nix"
FLAKE_TARGET="$ROOT#laptop"

RESET='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
MAGENTA='\033[35m'
CYAN='\033[36m'
WHITE='\033[37m'

ICON_OK="✓"
ICON_FAIL="✗"
ICON_WARN="!"
ICON_INFO="ℹ"
ICON_ARROW="→"
ICON_CHECK="✓"
ICON_GEAR="⚙"
ICON_GIT=""
ICON_NIX=""
ICON_DISK="▣"
ICON_TRASH="✕"

die() { printf '  %b%s%b\n' "${RED}${ICON_FAIL}${RESET}" "$*" "$RESET" >&2; exit 1; }
info() { printf '  %b%s%b\n' "${BLUE}${ICON_INFO}${RESET}" "$*" "$RESET"; }
success() { printf '  %b%s%b\n' "${GREEN}${ICON_OK}${RESET}" "$*" "$RESET"; }
warning() { printf '  %b%s%b\n' "${YELLOW}${ICON_WARN}${RESET}" "$*" "$RESET"; }
error() { printf '  %b%s%b\n' "${RED}${ICON_FAIL}${RESET}" "$*" "$RESET" >&2; }
run_cmd() { printf '  %b%s%b\n' "${MAGENTA}${ICON_ARROW}${RESET}" "$*" "$RESET"; }
section() {
  printf '\n%b  %s%b\n' "${CYAN}${BOLD}" "$1" "$RESET"
  printf '%b  ──────────────────────────────────────────────────────────%b\n' "$DIM" "$RESET"
}
pause() { echo; read -r -p "  Press Enter to continue..." _ || true; }
confirm() {
  local prompt="${1:-Continue?}" answer
  echo
  read -r -p "  $prompt [y/N]: " answer
  [[ "$answer" =~ ^[Yy]([Ee][Ss])?$ ]]
}

need_cmd() { command -v "$1" >/dev/null 2>&1 || die "Required command not found: $1"; }
as_root() { sudo "$@"; }

get_var() {
  local key="$1"
  [[ -f "$VARS" ]] || return 1
  sed -nE "s/^[[:space:]]*${key}[[:space:]]*=[[:space:]]*\"([^\"]*)\";.*/\1/p" "$VARS" | head -n1
}
set_var() {
  local key="$1" value="$2"
  [[ -f "$VARS" ]] || die "Missing $VARS"
  python3 - "$VARS" "$key" "$value" <<'PY'
import sys, re
path, key, value = sys.argv[1:]
text = open(path).read()
pattern = rf'(^[ \t]*{re.escape(key)}[ \t]*=[ \t]*)"[^"]*"(;.*)$'
new, n = re.subn(
    pattern,
    lambda m: m.group(1) + '"' + value.replace('\\','\\\\').replace('"','\\"') + '"' + m.group(2),
    text,
    flags=re.M,
)
if n == 0:
    raise SystemExit(f"Could not find variable: {key}")
open(path, "w").write(new)
PY
}

backup_config() {
  local stamp backup
  stamp="$(date +%Y%m%d-%H%M%S)"
  backup="$ROOT/.setup-backups/$stamp"
  mkdir -p "$backup"
  [[ -f "$VARS" ]] && cp -a "$VARS" "$backup/"
  [[ -f "$ROOT/hosts/laptop/hardware-configuration.nix" ]] &&
    cp -a "$ROOT/hosts/laptop/hardware-configuration.nix" "$backup/"
  success "Backup created: $backup"
}

flake_check() {
  need_cmd nix
  section "Flake validation"
  run_cmd "nix flake check"
  nix flake check
  success "Flake check passed."
}

dry_build() {
  need_cmd nix
  section "NixOS dry build"
  run_cmd "nixos-rebuild dry-build --flake .#laptop"
  sudo nixos-rebuild dry-build --flake "$FLAKE_TARGET"
  success "Dry-build passed."
}

rebuild() {
  need_cmd nix
  flake_check
  section "NixOS rebuild"
  run_cmd "sudo nixos-rebuild switch --flake .#laptop"
  sudo nixos-rebuild switch --flake "$FLAKE_TARGET"
  success "System rebuilt and switched successfully."
}

update_config() {
  need_cmd git
  need_cmd nix
  section "Update configuration"
  cd "$ROOT"
  if [[ -n "$(git status --porcelain)" ]]; then
    warning "Working tree contains uncommitted changes."
    git status --short
    confirm "Continue with update?" || return
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
  section "Rollback"
  warning "This switches to the previous NixOS generation."
  confirm "Continue with rollback?" || return
  sudo nixos-rebuild switch --rollback
  success "Rollback completed."
}

list_generations() {
  section "NixOS generations"
  sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
}

refresh_hardware() {
  need_cmd nixos-generate-config
  section "Hardware configuration"
  backup_config
  mkdir -p "$ROOT/hosts/laptop"
  sudo nixos-generate-config --show-hardware-config > "$ROOT/hosts/laptop/hardware-configuration.nix"
  success "Hardware configuration regenerated."
  warning "Review the generated file before rebuilding."
}

detect_nvidia() {
  command -v lspci >/dev/null 2>&1 && lspci -nn | grep -qi NVIDIA
}

install_flow() {
  need_cmd nix
  need_cmd python3
  need_cmd git

  section "NixOS installation / setup"
  local username="${SUDO_USER:-${USER:-}}" full_name hostname git_user git_email timezone locale
  local nvidia="false"

  read -r -p "  Linux username [$username]: " username
  username="${username:-${SUDO_USER:-${USER:-}}}"
  [[ "$username" =~ ^[a-z_][a-z0-9_-]*[$]?$ ]] || die "Invalid Linux username."

  read -r -p "  Full name: " full_name
  [[ -n "$full_name" ]] || die "Full name cannot be empty."

  read -r -p "  Hostname [$(hostname -s 2>/dev/null || echo nixos)]: " hostname
  hostname="${hostname:-$(hostname -s 2>/dev/null || echo nixos)}"
  [[ "$hostname" =~ ^[a-zA-Z0-9][a-zA-Z0-9.-]*$ ]] || die "Invalid hostname."

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

  echo
  section "Review"
  printf '  Username : %s\n' "$username"
  printf '  Full name: %s\n' "$full_name"
  printf '  Hostname : %s\n' "$hostname"
  printf '  Git user : %s\n' "$git_user"
  printf '  Git email: %s\n' "$git_email"
  printf '  Timezone : %s\n' "$timezone"
  printf '  Locale   : %s\n' "$locale"
  printf '  NVIDIA   : %s\n' "$nvidia"
  confirm "Apply these settings?" || { warning "Installation cancelled."; return; }

  backup_config
  set_var username "$username"
  set_var fullName "$full_name"
  set_var hostname "$hostname"
  set_var gitUser "$git_user"
  set_var email "$git_email"
  set_var timezone "$timezone"
  set_var locale "$locale"

  if grep -qE '^[[:space:]]*enable[[:space:]]*=[[:space:]]*(true|false);' "$VARS"; then
    python3 - "$VARS" "$nvidia" <<'PY'
import sys, re
path, val = sys.argv[1:]
text = open(path).read()
m = re.search(r'(?ms)(nvidia\s*=\s*\{.*?)(^\s*enable\s*=\s*)(true|false)(;)', text)
if m:
    text = text[:m.start(3)] + val + text[m.end(3):]
    open(path, "w").write(text)
PY
  fi

  refresh_hardware
  flake_check
  dry_build

  if confirm "Switch to this configuration now?"; then
    rebuild
    if id "$username" >/dev/null 2>&1; then
      info "Set the Linux password for $username. It is never stored in Nix."
      sudo passwd "$username"
    else
      warning "User '$username' is not currently present. Set its password after activation:"
      printf '  sudo passwd %q\n' "$username"
    fi
    success "Installation completed."
  else
    success "Setup prepared but not switched."
  fi
}

test_install() {
  need_cmd python3
  section "Installer preview"
  local username="${SUDO_USER:-${USER:-testuser}}" full_name hostname git_user git_email timezone locale
  read -r -p "  Test username [$username]: " username; username="${username:-$SUDO_USER}"
  read -r -p "  Test full name [Test User]: " full_name; full_name="${full_name:-Test User}"
  read -r -p "  Test hostname [nixos-test]: " hostname; hostname="${hostname:-nixos-test}"
  read -r -p "  Test Git username [testuser]: " git_user; git_user="${git_user:-testuser}"
  read -r -p "  Test Git email [test@example.com]: " git_email; git_email="${git_email:-test@example.com}"
  read -r -p "  Test timezone [Asia/Kolkata]: " timezone; timezone="${timezone:-Asia/Kolkata}"
  read -r -p "  Test locale [en_US.UTF-8]: " locale; locale="${locale:-en_US.UTF-8}"
  echo
  info "No files will be changed."
  printf '  username = "%s";\n' "$username"
  printf '  fullName = "%s";\n' "$full_name"
  printf '  hostname = "%s";\n' "$hostname"
  printf '  gitUser = "%s";\n' "$git_user"
  printf '  email = "%s";\n' "$git_email"
  printf '  timezone = "%s";\n' "$timezone"
  printf '  locale = "%s";\n' "$locale"
  echo
  success "Installer preview complete. Nothing was modified."
}

system_overview() {
  section "System overview"
  printf '  Host:    %s\n' "$(hostname)"
  printf '  Kernel:  %s\n' "$(uname -r)"
  printf '  Nix:     %s\n' "$(nix --version 2>/dev/null || echo unavailable)"
  printf '  Uptime:  %s\n' "$(uptime -p 2>/dev/null || echo unknown)"
}

menu() {
  while true; do
    clear 2>/dev/null || true
    printf "%b╭────────────────────────────────────────────╮%b\n" "$MAGENTA" "$RESET"
    printf "%b│        NixOS Configuration Manager         │%b\n" "$MAGENTA" "$RESET"
    printf "%b│                   v%s                   │%b\n" "$MAGENTA" "$VERSION" "$RESET"
    printf "%b╰────────────────────────────────────────────╯%b\n" "$MAGENTA" "$RESET"

    system_overview
    section "Configuration"
    printf '  %b1%b  Install / Setup\n' "$CYAN" "$RESET"
    printf '  %b2%b  Update configuration\n' "$CYAN" "$RESET"
    printf '  %b3%b  Rebuild / Switch\n' "$CYAN" "$RESET"
    printf '  %b4%b  Dry rebuild\n' "$CYAN" "$RESET"
    printf '  %b5%b  Check flake\n' "$CYAN" "$RESET"
    printf '  %b6%b  Rollback\n' "$CYAN" "$RESET"
    printf '  %b7%b  Refresh hardware config\n' "$CYAN" "$RESET"
    printf '  %b8%b  List generations\n' "$CYAN" "$RESET"
    section "Validation & Maintenance"
    printf '  %b9%b  Full configuration check\n' "$CYAN" "$RESET"
    printf ' %b10%b  Maintenance dashboard\n' "$CYAN" "$RESET"
    printf ' %b11%b  Test installer preview\n' "$CYAN" "$RESET"
    printf ' %b12%b  Garbage collection\n' "$CYAN" "$RESET"
    printf ' %b13%b  Optimize Nix store\n' "$CYAN" "$RESET"
    printf ' %b14%b  Verify Nix store\n' "$CYAN" "$RESET"
    printf ' %b15%b  Systemd health\n' "$CYAN" "$RESET"
    printf ' %b16%b  Nix store usage\n' "$CYAN" "$RESET"
    printf '  %b0%b  Exit\n\n' "$CYAN" "$RESET"

    local choice
    read -r -p "  Select: " choice
    case "$choice" in
      1) install_flow; pause ;;
      2) update_config; pause ;;
      3) rebuild; pause ;;
      4) dry_build; pause ;;
      5) flake_check; pause ;;
      6) rollback; pause ;;
      7) refresh_hardware; pause ;;
      8) list_generations; pause ;;
      9) validator_run; pause ;;
      10) m_maintenance_dashboard ;;
      11) test_install; pause ;;
      12) m_garbage_collect; pause ;;
      13) m_optimize_store; pause ;;
      14) m_verify_store; pause ;;
      15) m_systemd_health; pause ;;
      16) m_store_usage; pause ;;
      0) clear 2>/dev/null || true; exit 0 ;;
      *) warning "Invalid option."; sleep 1 ;;
    esac
  done
}


# Integrated maintenance dashboard (from cleanup.sh)
M_NIXOS_DIR="$ROOT"
M_FLAKE_TARGET="$ROOT#laptop"
M_KEEP_GENERATIONS=5
M_ICON_OK="✓"
M_ICON_FAIL="✗"
M_ICON_WARN="!"
M_ICON_INFO="ℹ"
M_ICON_ARROW="→"
M_ICON_CLEAN="✦"
M_ICON_NIX=""
M_ICON_GIT=""
M_ICON_SYSTEM="⚙"
M_ICON_DISK="▣"
M_ICON_TRASH="✕"
M_ICON_CHECK="✓"

# Terminal helpers

m_clear_screen() {
  printf '\033c'
}

m_hide_cursor() {
  tput civis 2>/dev/null || true
}

m_show_cursor() {
  tput cnorm 2>/dev/null || true
}

trap m_show_cursor EXIT INT TERM

m_hr() {
  printf '%b\n' "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
}

m_header() {
  m_clear_screen

  echo
  printf '%b\n' "${CYAN}${BOLD}"
  echo "   ███╗   ██╗██╗██╗  ██╗ ██████╗ ███████╗"
  echo "   ████╗  ██║██║╚██╗██╔╝██╔═══██╗██╔════╝"
  echo "   ██╔██╗ ██║██║ ╚███╔╝ ██║   ██║███████╗"
  echo "   ██║╚██╗██║██║ ██╔██╗ ██║   ██║╚════██║"
  echo "   ██║ ╚████║██║██╔╝ ██╗╚██████╔╝███████║"
  echo "   ╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝"
  printf '%b\n' "${RESET}"

  printf '%b\n' "${DIM}   NixOS system maintenance dashboard${RESET}"
  echo
  m_hr
  echo
}

m_section() {
  echo
  printf '%b\n' "${CYAN}${BOLD}  $1${RESET}"
  printf '%b\n' "${DIM}  ──────────────────────────────────────────────────────────${RESET}"
}

m_info() {
  printf '  %b %s\n' "${BLUE}${M_ICON_INFO}${RESET}" "$1"
}

m_success() {
  printf '  %b %s\n' "${GREEN}${M_ICON_OK}${RESET}" "$1"
}

m_warning() {
  printf '  %b %s\n' "${YELLOW}${M_ICON_WARN}${RESET}" "$1"
}

m_error() {
  printf '  %b %s\n' "${RED}${M_ICON_FAIL}${RESET}" "$1"
}

m_run() {
  printf '  %b %s\n' "${MAGENTA}${M_ICON_ARROW}${RESET}" "$1"
}

m_separator() {
  echo
  printf '%b\n' "${DIM}  ──────────────────────────────────────────────────────────${RESET}"
}

m_pause() {
  echo
  read -rp "  Press Enter to continue..."
}

m_confirm() {
  local prompt="$1"

  echo
  read -rp "  $prompt [y/N]: " answer

  [[ "$answer" =~ ^[Yy]$ ]]
}

# Safety

m_check_environment() {

  section "Environment"

  if [[ $EUID -eq 0 ]]; then
    error "Do not run this script with sudo."
    echo
    echo "  Run it as your normal user:"
    echo
    echo "    ./setup.sh maintain"
    echo
    exit 1
  fi

  if [[ ! -d "$M_NIXOS_DIR" ]]; then
    error "NixOS directory not found:"
    echo "    $M_NIXOS_DIR"
    exit 1
  fi

  if ! command -v nix >/dev/null 2>&1; then
    error "Nix command not found."
    exit 1
  fi

  if ! command -v nixos-rebuild >/dev/null 2>&1; then
    error "nixos-rebuild not found."
    exit 1
  fi

  if ! command -v git >/dev/null 2>&1; then
    error "git command not found."
    exit 1
  fi

  success "NixOS environment detected."
  info "Configuration: $M_NIXOS_DIR"
  info "Flake target:  $M_FLAKE_TARGET"
}

# Git

m_check_git() {

  section "${M_ICON_GIT} Git status"

  cd "$M_NIXOS_DIR"

  if [[ -n "$(git status --porcelain)" ]]; then

    warning "Working tree contains uncommitted changes."

    echo
    git status --short

    echo
    printf '%b\n' "${YELLOW}  This is allowed, but review your changes before continuing.${RESET}"

  else

    success "Working tree is clean."

  fi
}

# Flake check

m_check_flake() {

  section "${M_ICON_NIX} Flake validation"

  m_run "nix flake check"

  if nix flake check; then
    success "Flake check passed."
  else
    error "Flake check failed."
    return 1
  fi
}

# Dry build

m_dry_build() {

  section "${M_ICON_CHECK} NixOS configuration"

  m_run "nixos-rebuild dry-build"

  if sudo nixos-rebuild dry-build --flake "$M_FLAKE_TARGET"; then
    success "Dry-build passed."
    return 0
  fi

  error "Dry-build failed."
  return 1
}

# Generation information

m_get_generations() {

  sudo nix-env \
    --list-generations \
    --profile /nix/var/nix/profiles/system
}

m_get_current_generation() {

  m_get_generations |
    awk '/\(current\)/ {print $1}'
}

# Generation dashboard

m_generation_status() {

  section "${M_ICON_SYSTEM} System generations"

  local output
  local current
  local total

  output="$(m_get_generations)"
  current="$(echo "$output" | awk '/\(current\)/ {print $1}')"
  total="$(echo "$output" | awk 'NF {count++} END {print count+0}')"

  echo
  printf '  %b Current generation: %b%s%b\n' \
    "${GREEN}${M_ICON_OK}${RESET}" \
    "${BOLD}" \
    "$current" \
    "${RESET}"

  printf '  %b Total generations:  %b%s%b\n' \
    "${BLUE}${M_ICON_INFO}${RESET}" \
    "${BOLD}" \
    "$total" \
    "${RESET}"

  printf '  %b Keeping:            %b%s%b\n' \
    "${CYAN}${M_ICON_CLEAN}${RESET}" \
    "${BOLD}" \
    "$M_KEEP_GENERATIONS" \
    "${RESET}"

  echo
}

# Generation cleanup

m_cleanup_generations() {

  section "${M_ICON_CLEAN} Generation cleanup"

  local output
  local current
  local generations
  local total
  local delete_count
  local old_generations

  output="$(m_get_generations)"

  current="$(echo "$output" | awk '/\(current\)/ {print $1}')"

  mapfile -t generations < <(
    echo "$output" |
      awk '{print $1}'
  )

  total="${#generations[@]}"

  if ((total <= M_KEEP_GENERATIONS)); then
    success "Nothing to remove."
    info "Only $total generation(s) exist."
    return
  fi

  delete_count=$((total - M_KEEP_GENERATIONS))

  old_generations=(
    "${generations[@]:0:$delete_count}"
  )

  echo
  warning "Old generations selected for removal:"
  echo

  for generation in "${old_generations[@]}"; do
    printf '    %b generation %s%b\n' \
      "${RED}${M_ICON_TRASH}${RESET}" \
      "$generation" \
      "${RESET}"
  done

  echo
  info "Current generation $current is protected."
  info "Newest $M_KEEP_GENERATIONS generations will remain."

  if confirm "Remove these generations?"; then

    m_run "Removing old generations..."

    sudo nix-env \
      --profile /nix/var/nix/profiles/system \
      --delete-generations \
      "${old_generations[@]}"

    success "Old generations removed."

  else

    warning "Generation cleanup cancelled."

  fi
}

# Garbage collection

m_garbage_collect() {

  section "${M_ICON_TRASH} Garbage collection"

  info "Scanning for unreachable store paths..."

  local dead_paths
  dead_paths="$(
    nix-store --gc --print-dead 2>/dev/null || true
  )"

  if [[ -z "$dead_paths" ]]; then

    success "No unreachable store paths found."
    return

  fi

  local count
  count="$(echo "$dead_paths" | wc -l)"

  info "Approximately $count unreachable paths found."

  if confirm "Run garbage collection?"; then

    m_run "Running Nix garbage collection..."

    sudo nix-collect-garbage

    success "Garbage collection completed."

  else

    warning "Garbage collection cancelled."

  fi
}

# Store optimization

m_optimize_store() {

  section "${M_ICON_NIX} Store optimization"

  if confirm "Optimize the Nix store?"; then

    m_run "Optimizing Nix store..."

    sudo nix-store --optimise

    success "Nix store optimization completed."

  else

    warning "Store optimization skipped."

  fi
}

# Store verification

m_verify_store() {

  section "${M_ICON_CHECK} Store verification"

  warning "This can take a while."

  if ! confirm "Verify Nix store contents?"; then
    warning "Store verification skipped."
    return
  fi

  m_run "Verifying Nix store..."

  if sudo nix-store --verify --check-contents; then
    success "Nix store verification passed."
  else
    error "Nix store verification reported problems."
  fi
}

# Systemd

m_systemd_health() {

  section "${M_ICON_SYSTEM} Systemd health"

  local failed

  failed="$(
    systemctl \
      --failed \
      --no-legend \
      --no-pager ||
      true
  )"

  if [[ -z "$failed" ]]; then

    success "No failed systemd units."

  else

    warning "Failed systemd units detected:"
    echo
    systemctl --failed --no-pager

  fi
}

# Disk usage

m_store_usage() {

  section "${M_ICON_DISK} Nix store"

  local usage

  usage="$(du -sh /nix/store 2>/dev/null | awk '{print $1}')"

  echo
  printf '  %b Nix store size: %b%s%b\n' \
    "${CYAN}${M_ICON_DISK}${RESET}" \
    "${BOLD}" \
    "$usage" \
    "${RESET}"

  echo

  df -h /nix
}

# System overview

m_system_overview() {

  section "${M_ICON_SYSTEM} System overview"

  local hostname
  local kernel
  local nix_version
  local uptime

  hostname="$(hostname)"
  kernel="$(uname -r)"
  nix_version="$(nix --version)"
  uptime="$(uptime -p 2>/dev/null || true)"

  printf '  %b Host:       %s\n' "${CYAN}${M_ICON_SYSTEM}${RESET}" "$hostname"
  printf '  %b Kernel:     %s\n' "${BLUE}${M_ICON_INFO}${RESET}" "$kernel"
  printf '  %b Nix:        %s\n' "${MAGENTA}${M_ICON_NIX}${RESET}" "$nix_version"
  printf '  %b Uptime:     %s\n' "${GREEN}${M_ICON_OK}${RESET}" "$uptime"
}

# Full maintenance is implemented by m_maintenance_dashboard above.
m_maintenance_dashboard() {
  m_header
  m_check_environment
  m_check_git
  echo
  if ! m_check_flake; then
    m_error "Maintenance stopped."
    m_pause
    return
  fi
  if ! m_dry_build; then
    m_error "Maintenance stopped."
    echo
    echo "Fix the NixOS configuration before cleanup."
    m_pause
    return
  fi
  m_generation_status
  m_cleanup_generations
  m_garbage_collect
  m_optimize_store
  m_verify_store
  m_systemd_health
  m_store_usage
  echo
  m_section "Final configuration check"
  m_run "Running final dry-build..."
  if sudo nixos-rebuild dry-build --flake "$M_FLAKE_TARGET"; then
    m_success "Final dry-build passed."
  else
    m_error "Final dry-build failed."
  fi
  echo
  m_hr
  echo
  printf '%b\n' "${GREEN}${BOLD}  ${M_ICON_OK} Maintenance complete${RESET}"
  echo
  printf '  %b Current generation: %s\n' "${GREEN}${M_ICON_SYSTEM}${RESET}" "$(m_get_current_generation)"
  printf '  %b Generations kept:  %s\n' "${CYAN}${M_ICON_CLEAN}${RESET}" "$M_KEEP_GENERATIONS"
  echo
  printf '%b\n' "${DIM}  Your NixOS configuration was not modified.${RESET}"
  echo
  m_pause
}


validator_run() {

# Integrated configuration validator (from check.sh)
V_FAILED=0
V_FLAKE_LOG=""
V_NVIM_LOG=""
V_LUA_LOG=""

v_ok() {
    printf "  ${GREEN}✓${RESET} %s\n" "$1"
}

v_fail() {
    printf "  ${RED}✗${RESET} %s\n" "$1"
    V_FAILED=1
}

v_info() {
    printf "  ${YELLOW}!${RESET} %s\n" "$1"
}

v_section() {
    printf "\n${MAGENTA}${BOLD}==>${RESET} ${BOLD}%s${RESET}\n" "$1"
}

v_subsection() {
    printf "  ${BLUE}•${RESET} ${BOLD}%s${RESET}\n" "$1"
}

v_separator() {
    printf "${DIM}────────────────────────────────────────────────────────────${RESET}\n"
}


# Header

clear 2>/dev/null || true

printf "${CYAN}${BOLD}"
printf '╭────────────────────────────────────────────────────────────╮\n'
printf '│                                                            │\n'
printf '│                 NixOS Configuration Check                  │\n'
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
    v_ok "Git repository detected"
else
    v_fail "Not inside a Git repository"
fi

# 2. Flake

section "Flake"

V_FLAKE_LOG="$(mktemp)"

if nix flake check --no-build >"$V_FLAKE_LOG" 2>&1; then

    v_ok "Flake evaluation passed"

    if grep -qi "dirty" "$V_FLAKE_LOG"; then
        v_info "Git tree is dirty"
    fi

else

    v_fail "Flake check failed"

    printf "\n"
    cat "$V_FLAKE_LOG"

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

    v_ok "All $NIX_COUNT Nix files parse correctly"

else

    v_fail "Nix syntax errors detected"

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

    # Theme architecture
    "lib/themes.nix"
    "home/theme/default.nix"

    # Wallpaper
    "home/hyprland/scripts/restore-wallpaper.sh"

)

for file in "${required_files[@]}"; do

    if [[ -f "$file" ]]; then

        v_ok "$file"

    else

        v_fail "Missing: $file"

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

        v_ok "$file"

    else

        v_fail "Missing Neovim file: $file"

    fi

done

# 6. Real Neovim configuration

section "Neovim configuration"

V_NVIM_LOG="$(mktemp)"

if command -v nvim >/dev/null 2>&1; then

    if nvim \
        --headless \
        -u "$ROOT/home/neovim/config/init.lua" \
        '+qa!' \
        >"$V_NVIM_LOG" 2>&1; then

        v_ok "Neovim configuration loads"

    else

        v_fail "Neovim configuration failed to load"

        if [[ -s "$V_NVIM_LOG" ]]; then
            cat "$V_NVIM_LOG"
        fi

    fi

else

    v_fail "Neovim is not available"

fi

# 7. Lua

section "Lua"

V_LUA_LOG="$(mktemp)"

if command -v nvim >/dev/null 2>&1; then

    if nvim \
        --headless \
        -u NONE \
        "+lua local files = vim.fn.glob('$ROOT/home/**/*.lua', false, true); for _, f in ipairs(files) do local fn, err = loadfile(f); if not fn then error(f .. ': ' .. err) end end" \
        '+qa!' \
        >"$V_LUA_LOG" 2>&1; then

        v_ok "Lua files parse correctly"

    else

        v_fail "Lua syntax errors detected"

        cat "$V_LUA_LOG"

    fi

else

    v_info "Neovim unavailable — Lua check skipped"

fi

# 8. Quickshell

section "Quickshell"

if command -v qs >/dev/null 2>&1; then

    if systemctl --user is-active --quiet quickshell.service; then

        v_ok "Quickshell service is running"

    else

        v_info "Quickshell service is not currently running"

    fi

else

    v_fail "Quickshell (qs) is not available"

fi

# 9. Hyprland

section "Hyprland"

if command -v hyprctl >/dev/null 2>&1; then

    HYPR_ERRORS="$(hyprctl configerrors 2>/dev/null || true)"

    if [[ -z "$HYPR_ERRORS" ]] ||
        grep -qiE "no errors|no error" <<<"$HYPR_ERRORS"; then

        v_ok "No Hyprland configuration errors reported"

    else

        v_fail "Hyprland configuration errors detected"

        printf '%s\n' "$HYPR_ERRORS"

    fi

else

    v_info "hyprctl unavailable — Hyprland check skipped"

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

        v_ok "$cmd"

    else

        v_fail "Missing command: $cmd"

    fi

done

# 11. Neovim declarations

section "Neovim packages"

NVIM_CONFIG="$ROOT/home/neovim/default.nix"

if [[ -f "$NVIM_CONFIG" ]]; then

    if grep -q "programs.neovim" "$NVIM_CONFIG"; then

        v_ok "Neovim is managed by Home Manager"

    else

        v_fail "programs.neovim declaration not found"

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

            v_ok "Plugin declared: $plugin"

        else

            v_fail "Plugin not declared: $plugin"

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

            v_ok "Neovim tool declared: $tool"

        else

            v_info "Neovim tool not declared directly: $tool"

        fi

    done

else

    v_fail "Neovim Home Manager configuration missing"

fi

# 12. Configuration ownership

section "Configuration ownership"

# Neovim

if grep -q "programs.neovim" \
    "$ROOT/home/neovim/default.nix" 2>/dev/null; then

    v_ok "Neovim is owned by Home Manager"

else

    v_fail "Neovim is not owned by Home Manager"

fi

# Launcher

if grep -qE '^[[:space:]]*fuzzel[[:space:]]*$' \
    "$ROOT/modules/desktop/applications.nix" 2>/dev/null; then

    v_fail "Fuzzel package is still declared by the desktop module"

else

    v_ok "Fuzzel package is no longer declared"

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

        v_ok "Launcher surface present: $surface"

    else

        v_fail "Launcher surface missing: $surface"

    fi

done

# Kitty

if grep -q "programs.kitty" \
    "$ROOT/home/kitty/default.nix" 2>/dev/null; then

    v_ok "Kitty is owned by Home Manager"

else

    v_fail "Kitty Home Manager configuration not found"

fi

# Quickshell

if grep -q "quickshell" \
    "$ROOT/home/quickshell/default.nix" 2>/dev/null; then

    v_ok "Quickshell is managed by Home Manager"

else

    v_fail "Quickshell Home Manager configuration not found"

fi

# 13. Theme architecture

section "Theme"

THEME_CONFIG="$ROOT/lib/themes.nix"
THEME_GENERATOR="$ROOT/home/theme/default.nix"

# Central theme database

if [[ -f "$THEME_CONFIG" ]]; then

    v_ok "Central theme database exists"

else

    v_fail "Central theme database missing"

fi

# Declarative active theme

if grep -qE '^[[:space:]]*activeTheme[[:space:]]*=' \
    "$THEME_CONFIG" 2>/dev/null; then

    v_ok "Theme selection is declarative"

else

    v_fail "Declarative activeTheme is missing"

fi

# Theme generator

if [[ -f "$THEME_GENERATOR" ]]; then

    v_ok "theme generator exists"

else

    v_fail "theme generator missing"

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

    v_ok "Active theme evaluates correctly: aurora"

elif [[ -n "$THEME_EVAL" ]]; then

    v_ok "Active theme evaluates: $THEME_EVAL"

else

    v_fail "Could not evaluate global.activeTheme"

fi

# Required theme fields

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

    if grep -qE "^[[:space:]]*${field}[[:space:]]*=" \
        "$THEME_CONFIG" 2>/dev/null; then

        v_ok "Theme color defined: $field"

    else

        v_fail "Theme color missing: $field"

    fi

done

# 14. Central fonts / UI

section "Global typography"

# Interface font

if grep -qE '^[[:space:]]*interface[[:space:]]*=' \
    "$THEME_CONFIG" 2>/dev/null; then

    v_ok "Central interface font defined"

else

    v_fail "Central interface font missing"

fi

# Terminal font

if grep -qE '^[[:space:]]*terminal[[:space:]]*=' \
    "$THEME_CONFIG" 2>/dev/null; then

    v_ok "Central terminal font defined"

else

    v_fail "Central terminal font missing"

fi

# Emoji font

if grep -qE '^[[:space:]]*emoji[[:space:]]*=' \
    "$THEME_CONFIG" 2>/dev/null; then

    v_ok "Central emoji font defined"

else

    v_fail "Central emoji font missing"

fi

# UI font size

if grep -qE '^[[:space:]]*fontSize[[:space:]]*=' \
    "$THEME_CONFIG" 2>/dev/null; then

    v_ok "Central UI font size defined"

else

    v_fail "Central UI font size missing"

fi

# Detect hard-coded terminal font in Kitty

KITTY_CONFIG="$ROOT/home/kitty/config/kitty.conf"

if [[ -f "$KITTY_CONFIG" ]]; then

    if grep -qE \
        '^[[:space:]]*font_family[[:space:]]+' \
        "$KITTY_CONFIG"; then

        v_fail "Kitty contains a hard-coded font_family"

    else

        v_ok "Kitty font family is centrally managed"

    fi

    if grep -qE \
        '^[[:space:]]*font_size[[:space:]]+' \
        "$KITTY_CONFIG"; then

        v_fail "Kitty contains a hard-coded font_size"

    else

        v_ok "Kitty font size is centrally managed"

    fi

else

    v_fail "Kitty configuration missing"

fi

# 15. Wallpaper / theme separation

section "Wallpaper / theme separation"

WALLPAPER_SERVICE="$ROOT/home/quickshell/config/services/WallpaperService.qml"
RESTORE_SCRIPT="$ROOT/home/hyprland/scripts/restore-wallpaper.sh"

# Wallpaper picker

if grep -qiE \
    'wallust|wallust run|\.cache/wallust|stylix-colors' \
    "$WALLPAPER_SERVICE" 2>/dev/null; then

    v_fail "Wallpaper picker still contains legacy theme generation"

else

    v_ok "Wallpaper picker is independent from Wallust"

fi

# Wallpaper restore

if grep -qiE \
    'wallust|wallust run|\.cache/wallust|stylix-colors' \
    "$RESTORE_SCRIPT" 2>/dev/null; then

    v_fail "Wallpaper restore still contains legacy theme generation"

else

    v_ok "Wallpaper restore is independent from Wallust"

fi

# Wallpaper state location

if grep -q '\.cache/aurora/current-wallpaper' \
    "$WALLPAPER_SERVICE" 2>/dev/null; then

    v_ok "Wallpaper state uses cache"

else

    v_fail "Wallpaper picker does not use wallpaper state"

fi

if grep -q '\.cache/aurora/current-wallpaper' \
    "$RESTORE_SCRIPT" 2>/dev/null; then

    v_ok "Wallpaper restore uses cache"

else

    v_fail "Wallpaper restore does not use wallpaper state"

fi

# Legacy Wallust directory

if [[ ! -d "$ROOT/home/hyprland/wallust" ]]; then

    v_ok "Legacy Wallust configuration removed"

else

    v_fail "Legacy Wallust configuration still exists"

fi

# Legacy generated cache

if [[ -d "$HOME/.cache/wallust" ]]; then

    v_info "Legacy ~/.cache/wallust still exists"

else

    v_ok "Legacy Wallust cache removed"

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

    v_ok "No legacy Wallust/stylix-colors references in active configuration"

else

    v_fail "Legacy Wallust/stylix-colors references remain"

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

        v_ok "$file"

    else

        v_info "Not currently generated: $file"

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

        v_ok "Generated Lua theme contains colors"

    else

        v_fail "Generated Lua theme has no colors"

    fi

else

    v_info "Lua theme not generated yet"

fi

# Kitty theme

if [[ -f "$ACTIVE_KITTY" ]]; then

    if grep -q '^foreground ' "$ACTIVE_KITTY" &&
        grep -q '^background ' "$ACTIVE_KITTY"; then

        v_ok "Generated Kitty theme contains core colors"

    else

        v_fail "Generated Kitty theme is incomplete"

    fi

else

    v_info "Kitty theme not generated yet"

fi

# Starship theme

if [[ -f "$ACTIVE_STARSHIP" ]]; then

    v_ok "Generated Starship theme exists"

else

    v_info "Starship theme not generated yet"

fi

# 18. layer rules

section "layer rules"

LAYER_RULES="$ROOT/home/hyprland/config/layerules.lua"

if [[ -f "$LAYER_RULES" ]]; then

    v_ok "Layer rules file exists"

    # Every Wayland namespace declared by a Quickshell surface needs a matching layer rule.

    for ns in aurora-bar aurora-popup aurora-notifications aurora-launcher; do

        if grep -q "namespace = \"\\^${ns}\\\$\"" \
            "$LAYER_RULES" 2>/dev/null; then

            v_ok "Layer rule declared: $ns"

        else

            v_fail "Layer rule missing: $ns"

        fi

    done

else

    v_fail "Hyprland layer rules file not found"

fi

# 18b. Notification delivery

section "Notification delivery"

NOTIF_SERVER="$ROOT/home/quickshell/config/services/NotificationServer.qml"
QUICKSHELL_NIX="$ROOT/home/quickshell/default.nix"
NOTIF_MODULE="$ROOT/modules/notifications/default.nix"

if [[ -f "$NOTIF_SERVER" ]]; then

    # services/qmldir registers NotificationServer.qml as a composite type called NotificationServer.

    if grep -q "import Quickshell.Services.Notifications as "         "$NOTIF_SERVER" 2>/dev/null; then

        v_ok "Notification server import is aliased"

    else

        v_fail "Notification server import is not aliased (daemon will not bind)"

    fi

    if grep -qE "^[[:space:]]+NotificationServer \{"         "$NOTIF_SERVER" 2>/dev/null; then

        v_fail "Unqualified NotificationServer instantiation (shadows itself)"

    else

        v_ok "Notification server instantiated through its namespace"

    fi

else

    v_fail "NotificationServer.qml not found"

fi

if grep -q "org.freedesktop.Notifications.service"     "$QUICKSHELL_NIX" 2>/dev/null; then

    v_ok "D-Bus activation declared for org.freedesktop.Notifications"

else

    v_fail "No D-Bus activation: apps that notify before the shell starts lose it"

fi

if grep -q "WantedBy" "$QUICKSHELL_NIX" 2>/dev/null; then

    v_ok "quickshell.service is bound to the graphical session"

else

    v_fail "quickshell.service has no Install section and will never autostart"

fi

if grep -q "libnotify" "$QUICKSHELL_NIX" 2>/dev/null; then

    v_ok "notify-send available in the user profile"

else

    v_fail "libnotify missing: notify-send unavailable to scripts and keybinds"

fi

if grep -q "impl.portal.Notification" "$NOTIF_MODULE" 2>/dev/null; then

    v_ok "Portal notification backend declared"

else

    v_fail "Portal notification backend missing: sandboxed apps cannot notify"

fi

# 19. theme ownership

section "Theme ownership"

# Hyprland

HYPR_THEME="$ROOT/home/hyprland/config/theme.lua"

if [[ -f "$HYPR_THEME" ]]; then

    if grep -q 'active-theme.lua' "$HYPR_THEME" 2>/dev/null; then

        v_ok "Hyprland consumes active theme"

    else

        v_fail "Hyprland theme does not consume active theme"

    fi

else

    v_fail "Hyprland theme module missing"

fi

# Neovim

if grep -Rql \
    'active-theme.lua' \
    "$ROOT/home/neovim/config/lua" \
    --include='*.lua' \
    2>/dev/null; then

    v_ok "Neovim theme modules consume active theme"

else

    v_fail "Neovim does not reference active theme"

fi

# Quickshell

QUICKSHELL_ROOT="$ROOT/home/quickshell"

if grep -Rql \
    'active-theme' \
    "$QUICKSHELL_ROOT" \
    --include='*.qml' \
    --include='*.nix' \
    2>/dev/null; then

    v_ok "Quickshell consumes theme data"

else

    v_info "Could not verify Quickshell theme consumption"

fi

# 20. Git status

section "Git status"

if git diff --quiet && git diff --cached --quiet; then

    v_ok "Working tree clean"

else

    v_info "Uncommitted changes detected"

    printf "\n"

    git status --short

fi

# Final result

printf "\n"

v_separator

printf "\n"

V_RESULT=0

if [[ "$V_FAILED" -eq 0 ]]; then

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

    V_RESULT=0

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

    V_RESULT=1

fi

  rm -f "${V_FLAKE_LOG:-}" "${V_NVIM_LOG:-}" "${V_LUA_LOG:-}" 2>/dev/null || true

  return "$V_RESULT"

}

usage() {
  cat <<EOF
NixOS Configuration Manager v$VERSION

Usage:
  ./setup.sh                         Interactive menu
  ./setup.sh install                 First-time setup
  ./setup.sh update                  Pull repo + update flake inputs
  ./setup.sh rebuild                 Validate + rebuild/switch
  ./setup.sh dry                     Dry rebuild
  ./setup.sh check                   Flake check
  ./setup.sh validate                Full configuration validator
  ./setup.sh maintain                Full maintenance dashboard
  ./setup.sh rollback                Roll back one generation
  ./setup.sh hardware                Regenerate hardware config
  ./setup.sh generations             List system generations
  ./setup.sh gc                      Garbage collection
  ./setup.sh optimize                Optimize Nix store
  ./setup.sh verify-store            Verify Nix store contents
  ./setup.sh systemd                 Check failed systemd units
  ./setup.sh store                   Show Nix store usage
  ./setup.sh test-install            Safe installer preview
  ./setup.sh help                   Show this help
  ./setup.sh version                Show version

Password handling:
  Linux passwords are never written to Nix. Setup uses 'passwd' interactively.
EOF
}

main() {
  cd "$ROOT"
  case "${1:-menu}" in
    menu) menu ;;
    install) install_flow ;;
    update) update_config ;;
    rebuild|switch) rebuild ;;
    dry|dry-build) dry_build ;;
    check) flake_check ;;
    validate|validator) validator_run ;;
    maintain|maintenance|cleanup) m_maintenance_dashboard ;;
    rollback) rollback ;;
    hardware|hw) refresh_hardware ;;
    generations|list-generations) list_generations ;;
    gc|garbage-collect) m_garbage_collect ;;
    optimize|optimise) m_optimize_store ;;
    verify-store|verify) m_verify_store ;;
    systemd) m_systemd_health ;;
    store|store-usage) m_store_usage ;;
    test-install) test_install ;;
    help|-h|--help) usage ;;
    version|-v|--version) printf '%s\n' "$VERSION" ;;
    *) error "Unknown command: $1"; usage; exit 2 ;;
  esac
}

main "$@"
