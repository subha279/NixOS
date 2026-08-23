# !/usr/bin/env bash

set -euo pipefail

# NixOS Maintenance Dashboard

NIXOS_DIR="$HOME/NixOS"
FLAKE_TARGET="$NIXOS_DIR#laptop"

KEEP_GENERATIONS=5

# Colors

RESET='\033[0m'
BOLD='\033[1m'

RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
MAGENTA='\033[35m'
CYAN='\033[36m'
WHITE='\033[37m'
DIM='\033[2m'

# Icons

ICON_OK="✓"
ICON_FAIL="✗"
ICON_WARN="!"
ICON_INFO="󰋼"
ICON_ARROW="󰁔"
ICON_CLEAN="󰃢"
ICON_NIX="󱄅"
ICON_GIT="󰊢"
ICON_SYSTEM="󰒓"
ICON_DISK="󰋊"
ICON_TRASH="󰩺"
ICON_CHECK="󰄬"

# Terminal helpers

clear_screen() {
  printf '\033c'
}

hide_cursor() {
  tput civis 2>/dev/null || true
}

show_cursor() {
  tput cnorm 2>/dev/null || true
}

trap show_cursor EXIT INT TERM

hr() {
  printf '%b\n' "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
}

header() {
  clear_screen

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
  hr
  echo
}

section() {
  echo
  printf '%b\n' "${CYAN}${BOLD}  $1${RESET}"
  printf '%b\n' "${DIM}  ──────────────────────────────────────────────────────────${RESET}"
}

info() {
  printf '  %b %s\n' "${BLUE}${ICON_INFO}${RESET}" "$1"
}

success() {
  printf '  %b %s\n' "${GREEN}${ICON_OK}${RESET}" "$1"
}

warning() {
  printf '  %b %s\n' "${YELLOW}${ICON_WARN}${RESET}" "$1"
}

error() {
  printf '  %b %s\n' "${RED}${ICON_FAIL}${RESET}" "$1"
}

run() {
  printf '  %b %s\n' "${MAGENTA}${ICON_ARROW}${RESET}" "$1"
}

separator() {
  echo
  printf '%b\n' "${DIM}  ──────────────────────────────────────────────────────────${RESET}"
}

pause() {
  echo
  read -rp "  Press Enter to continue..."
}

confirm() {
  local prompt="$1"

  echo
  read -rp "  $prompt [y/N]: " answer

  [[ "$answer" =~ ^[Yy]$ ]]
}

# Safety

check_environment() {

  section "Environment"

  if [[ $EUID -eq 0 ]]; then
    error "Do not run this script with sudo."
    echo
    echo "  Run it as your normal user:"
    echo
    echo "    ./scripts/cleanup.sh"
    echo
    exit 1
  fi

  if [[ ! -d "$NIXOS_DIR" ]]; then
    error "NixOS directory not found:"
    echo "    $NIXOS_DIR"
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
  info "Configuration: $NIXOS_DIR"
  info "Flake target:  $FLAKE_TARGET"
}

# Git

check_git() {

  section "${ICON_GIT} Git status"

  cd "$NIXOS_DIR"

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

check_flake() {

  section "${ICON_NIX} Flake validation"

  run "nix flake check"

  if nix flake check; then
    success "Flake check passed."
  else
    error "Flake check failed."
    return 1
  fi
}

# Dry build

dry_build() {

  section "${ICON_CHECK} NixOS configuration"

  run "nixos-rebuild dry-build"

  if sudo nixos-rebuild dry-build --flake "$FLAKE_TARGET"; then
    success "Dry-build passed."
    return 0
  fi

  error "Dry-build failed."
  return 1
}

# Generation information

get_generations() {

  sudo nix-env \
    --list-generations \
    --profile /nix/var/nix/profiles/system
}

get_current_generation() {

  get_generations |
    awk '/\(current\)/ {print $1}'
}

# Generation dashboard

generation_status() {

  section "${ICON_SYSTEM} System generations"

  local output
  local current
  local total

  output="$(get_generations)"
  current="$(echo "$output" | awk '/\(current\)/ {print $1}')"
  total="$(echo "$output" | awk 'NF {count++} END {print count+0}')"

  echo
  printf '  %b Current generation: %b%s%b\n' \
    "${GREEN}${ICON_OK}${RESET}" \
    "${BOLD}" \
    "$current" \
    "${RESET}"

  printf '  %b Total generations:  %b%s%b\n' \
    "${BLUE}${ICON_INFO}${RESET}" \
    "${BOLD}" \
    "$total" \
    "${RESET}"

  printf '  %b Keeping:            %b%s%b\n' \
    "${CYAN}${ICON_CLEAN}${RESET}" \
    "${BOLD}" \
    "$KEEP_GENERATIONS" \
    "${RESET}"

  echo
}

# Generation cleanup

cleanup_generations() {

  section "${ICON_CLEAN} Generation cleanup"

  local output
  local current
  local generations
  local total
  local delete_count
  local old_generations

  output="$(get_generations)"

  current="$(echo "$output" | awk '/\(current\)/ {print $1}')"

  mapfile -t generations < <(
    echo "$output" |
      awk '{print $1}'
  )

  total="${#generations[@]}"

  if ((total <= KEEP_GENERATIONS)); then
    success "Nothing to remove."
    info "Only $total generation(s) exist."
    return
  fi

  delete_count=$((total - KEEP_GENERATIONS))

  old_generations=(
    "${generations[@]:0:$delete_count}"
  )

  echo
  warning "Old generations selected for removal:"
  echo

  for generation in "${old_generations[@]}"; do
    printf '    %b generation %s%b\n' \
      "${RED}${ICON_TRASH}${RESET}" \
      "$generation" \
      "${RESET}"
  done

  echo
  info "Current generation $current is protected."
  info "Newest $KEEP_GENERATIONS generations will remain."

  if confirm "Remove these generations?"; then

    run "Removing old generations..."

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

garbage_collect() {

  section "${ICON_TRASH} Garbage collection"

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

    run "Running Nix garbage collection..."

    sudo nix-collect-garbage

    success "Garbage collection completed."

  else

    warning "Garbage collection cancelled."

  fi
}

# Store optimization

optimize_store() {

  section "${ICON_NIX} Store optimization"

  if confirm "Optimize the Nix store?"; then

    run "Optimizing Nix store..."

    sudo nix-store --optimise

    success "Nix store optimization completed."

  else

    warning "Store optimization skipped."

  fi
}

# Store verification

verify_store() {

  section "${ICON_CHECK} Store verification"

  warning "This can take a while."

  if ! confirm "Verify Nix store contents?"; then
    warning "Store verification skipped."
    return
  fi

  run "Verifying Nix store..."

  if sudo nix-store --verify --check-contents; then
    success "Nix store verification passed."
  else
    error "Nix store verification reported problems."
  fi
}

# Systemd

systemd_health() {

  section "${ICON_SYSTEM} Systemd health"

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

store_usage() {

  section "${ICON_DISK} Nix store"

  local usage

  usage="$(du -sh /nix/store 2>/dev/null | awk '{print $1}')"

  echo
  printf '  %b Nix store size: %b%s%b\n' \
    "${CYAN}${ICON_DISK}${RESET}" \
    "${BOLD}" \
    "$usage" \
    "${RESET}"

  echo

  df -h /nix
}

# System overview

system_overview() {

  section "${ICON_SYSTEM} System overview"

  local hostname
  local kernel
  local nix_version
  local uptime

  hostname="$(hostname)"
  kernel="$(uname -r)"
  nix_version="$(nix --version)"
  uptime="$(uptime -p 2>/dev/null || true)"

  printf '  %b Host:       %s\n' "${CYAN}${ICON_SYSTEM}${RESET}" "$hostname"
  printf '  %b Kernel:     %s\n' "${BLUE}${ICON_INFO}${RESET}" "$kernel"
  printf '  %b Nix:        %s\n' "${MAGENTA}${ICON_NIX}${RESET}" "$nix_version"
  printf '  %b Uptime:     %s\n' "${GREEN}${ICON_OK}${RESET}" "$uptime"
}

# Full maintenance

full_cleanup() {

  header

  check_environment
  check_git

  echo

  if ! check_flake; then
    error "Maintenance stopped."
    pause
    return
  fi

  if ! dry_build; then
    error "Maintenance stopped."
    echo
    echo "Fix the NixOS configuration before cleanup."
    pause
    return
  fi

  generation_status

  cleanup_generations

  garbage_collect

  optimize_store

  verify_store

  systemd_health

  store_usage

  echo
  section "Final configuration check"

  run "Running final dry-build..."

  if sudo nixos-rebuild dry-build --flake "$FLAKE_TARGET"; then
    success "Final dry-build passed."
  else
    error "Final dry-build failed."
  fi

  echo
  hr

  echo
  printf '%b\n' "${GREEN}${BOLD}  ${ICON_OK} Maintenance complete${RESET}"
  echo

  printf '  %b Current generation: %s\n' \
    "${GREEN}${ICON_SYSTEM}${RESET}" \
    "$(get_current_generation)"

  printf '  %b Generations kept:  %s\n' \
    "${CYAN}${ICON_CLEAN}${RESET}" \
    "$KEEP_GENERATIONS"

  echo
  printf '%b\n' "${DIM}  Your NixOS configuration was not modified.${RESET}"
  echo

  pause
}

# Interactive menu

menu() {

  while true; do

    header

    system_overview

    generation_status

    section "Maintenance"

    local choice

    choice="$(
      printf '%s\n' \
        "󰒓  Full maintenance" \
        "󰁯  Check flake" \
        "󰑮  Dry-build" \
        "󰆼  Generation cleanup" \
        "󰩺  Garbage collection" \
        "󰒔  Optimize Nix store" \
        "󰄬  Verify Nix store" \
        "󰒓  Systemd health" \
        "󰋊  Nix store usage" \
        "󰑐  Refresh" \
        "󰗼  Exit" |
        fzf \
          --height=45% \
          --layout=reverse \
          --border=rounded \
          --padding=1 \
          --margin=1 \
          --prompt="    " \
          --pointer="󰁔" \
          --marker="✓" \
          --header="  Select maintenance action" \
          --no-info
    )"

    case "$choice" in

    "󰒓  Full maintenance")
      full_cleanup
      ;;

    "󰁯  Check flake")
      header
      check_flake || true
      pause
      ;;

    "󰑮  Dry-build")
      header
      dry_build || true
      pause
      ;;

    "󰆼  Generation cleanup")
      header
      cleanup_generations
      pause
      ;;

    "󰩺  Garbage collection")
      header
      garbage_collect
      pause
      ;;

    "󰒔  Optimize Nix store")
      header
      optimize_store
      pause
      ;;

    "󰄬  Verify Nix store")
      header
      verify_store
      pause
      ;;

    "󰒓  Systemd health")
      header
      systemd_health
      pause
      ;;

    "󰋊  Nix store usage")
      header
      store_usage
      pause
      ;;

    "󰑐  Refresh")
      ;;

    "󰗼  Exit" | "")
      clear_screen
      echo
      printf '%b\n' "${DIM}  Goodbye.${RESET}"
      echo
      exit 0
      ;;

    esac

  done
}

# Entry point

menu
