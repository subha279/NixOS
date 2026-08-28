#!/usr/bin/env bash
set -Eeuo pipefail

# ============================================================
# Single entry point: install, update, rebuild, validate,
# maintenance, rollback and system recovery.
# ============================================================

VERSION="1.0"
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
VARS="$ROOT/lib/variables.nix"
FLAKE_TARGET="$ROOT#laptop"


# ============================================================
# PRESENTATION LAYER
#
# One vocabulary for everything this script prints. The names
# below -- info / success / warning / error / run_cmd / section /
# pause / confirm, plus v_ok / v_fail / v_info for the validator's
# aligned results -- are the whole set. There used to be three
# parallel copies of this: these, an m_* family for the maintenance
# dashboard, and a v_* family nested inside the validator. They are
# now one implementation.
#
# The colour variables keep their old names (RED, CYAN, ...) on
# purpose. Around a hundred printf call sites in the maintenance
# and validator sections reference them directly, so re-pointing
# the values at the live theme upgrades all of them without
# touching any of them.
# ============================================================


# Terminal capabilities
#
# None of this was detected before: the script emitted escape codes
# unconditionally, so `./setup.sh validate | tee log` wrote escape
# sequences into the file and NO_COLOR was ignored.

if [[ -t 1 ]]; then IS_TTY=1; else IS_TTY=0; fi

# Colour is off when asked for (NO_COLOR), when the terminal says it
# cannot render it (TERM=dumb), or when stdout is not a terminal at all.
#
# Only an *explicit* TERM=dumb disables it. An unset TERM alongside a real
# tty means a stripped environment rather than a teletype, and every
# terminal emulator that can give us a tty can also handle basic ANSI --
# the -t 1 test above is what actually protects pipes and log files.
UI_COLOR=1
if [[ -n "${NO_COLOR:-}" ]]; then UI_COLOR=0; fi
if [[ "${TERM:-}" == "dumb" ]]; then UI_COLOR=0; fi
if [[ "$IS_TTY" -eq 0 ]]; then UI_COLOR=0; fi

# 24-bit colour is what lets the palette be the actual theme rather
# than an approximation of it. Without it we fall back to the 3-bit
# codes this script used to hardcode.
#
# COLORTERM is the reliable signal and kitty sets it, but it is lost
# across sudo and some multiplexers, so a TERM that advertises direct
# or 256 colour counts too.
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

# Box drawing and the nicer glyphs need a UTF-8 locale.
#
# Also dropped without a tty. Strictly, UTF-8 keeps working through a
# pipe -- but validator output gets redirected into logs, pasted into
# issues and mailed around, and ASCII survives all of those intact.
UI_UNICODE=1
case "${LC_ALL:-${LC_CTYPE:-${LANG:-}}}" in
  *UTF-8* | *utf-8* | *UTF8* | *utf8*) ;;
  *) UI_UNICODE=0 ;;
esac
if [[ "${TERM:-}" == "dumb" ]]; then UI_UNICODE=0; fi
if [[ "$IS_TTY" -eq 0 ]]; then UI_UNICODE=0; fi

# Width for the panel frame and the section rules. Clamped: a rule
# stretched across a 210-column terminal reads as a divider in a
# spreadsheet, not a heading.
UI_WIDTH=64
if [[ "$IS_TTY" -eq 1 ]]; then
  UI_WIDTH="$(tput cols 2>/dev/null || printf '64')"
  if [[ "$UI_WIDTH" -gt 74 ]]; then UI_WIDTH=74; fi
  if [[ "$UI_WIDTH" -lt 40 ]]; then UI_WIDTH=40; fi
fi


# Palette, read from the live Aurora theme
#
# ~/.config/aurora/active-theme and themes/<id>.json are the same
# files core/Theme.qml watches, so the installer wears whatever
# colourscheme the desktop is currently wearing. Strictly read-only:
# this participates in no part of the theme pipeline, it only looks
# at the output. Every lookup carries the built-in aurora value as a
# fallback, so a missing or half-written file costs nothing.

AURORA_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/aurora"
UI_THEME_FILE=""

if [[ -r "$AURORA_DIR/active-theme" ]]; then
  UI_THEME_ID="$(tr -d '[:space:]' <"$AURORA_DIR/active-theme" 2>/dev/null || printf '')"

  if [[ -n "$UI_THEME_ID" && -r "$AURORA_DIR/themes/$UI_THEME_ID.json" ]]; then
    UI_THEME_FILE="$AURORA_DIR/themes/$UI_THEME_ID.json"
  fi
fi

# Pull one "key":"#rrggbb" pair out of the theme JSON. Deliberately
# grep rather than jq: jq is not guaranteed present on a machine that
# is still being installed, and this needs exactly one field.
ui_hex() {
  local key="$1" fallback="$2" hex=""

  if [[ -n "$UI_THEME_FILE" ]]; then
    hex="$(grep -o "\"$key\"[[:space:]]*:[[:space:]]*\"#[0-9a-fA-F]\{6\}\"" "$UI_THEME_FILE" 2>/dev/null |
      head -1 | grep -o '#[0-9a-fA-F]\{6\}' || printf '')"
  fi

  printf '%s' "${hex:-$fallback}"
}

# $1 theme key, $2 fallback hex, $3 basic ANSI code for 16-colour terminals
ui_fg() {
  local hex

  if [[ "$UI_COLOR" -eq 0 ]]; then
    printf ''
    return 0
  fi

  if [[ "$UI_TRUECOLOR" -eq 1 ]]; then
    hex="$(ui_hex "$1" "$2")"

    printf '\033[38;2;%d;%d;%dm' \
      "$((16#${hex:1:2}))" "$((16#${hex:3:2}))" "$((16#${hex:5:2}))"

    return 0
  fi

  printf '\033[%sm' "$3"
}

if [[ "$UI_COLOR" -eq 1 ]]; then
  RESET='\033[0m'
  BOLD='\033[1m'
else
  RESET=''
  BOLD=''
fi

# Semantic, not literal. The names are historical; the theme role in
# the trailing comment is what each one actually means.
RED="$(ui_fg error '#F38BA8' 31)"                # failure
GREEN="$(ui_fg success '#A6E3A1' 32)"            # success
YELLOW="$(ui_fg warning '#F9E2AF' 33)"           # warning
BLUE="$(ui_fg info '#89B4FA' 34)"                # information
MAGENTA="$(ui_fg terminalMagenta '#F5C2E7' 35)"  # a command about to run
CYAN="$(ui_fg accent '#CBA6F7' 36)"              # chrome: headings, numbers, frames
DIM="$(ui_fg textMuted '#989CAC' 2)"             # de-emphasised

# Glyphs
#
# These literals are the Unicode / Nerd Font set. The block just below
# them swaps in ASCII when the locale cannot render it, so nothing here
# needs a conditional of its own.

ICON_OK="✓"
ICON_FAIL="✗"
ICON_WARN="!"
ICON_INFO="ℹ"
ICON_ARROW="→"

UI_TL="╭"
UI_TR="╮"
UI_BL="╰"
UI_BR="╯"
UI_H="─"
UI_V="│"
UI_RULE="─"

UI_SPIN=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")

# ASCII fallback, for a terminal without a UTF-8 locale. Everything
# above is replaced wholesale rather than conditionally, so the rest of
# the script only ever refers to the names.
if [[ "$UI_UNICODE" -eq 0 ]]; then
  ICON_OK="ok"
  ICON_FAIL="x"
  ICON_WARN="!"
  ICON_INFO="i"
  ICON_ARROW=">"

  UI_TL="+"
  UI_TR="+"
  UI_BL="+"
  UI_BR="+"
  UI_H="-"
  UI_V="|"
  UI_RULE="-"

  UI_SPIN=("|" "/" "-" "\\")
fi


# Cursor
#
# The trap lives here rather than three hundred lines further down next
# to the maintenance dashboard, because a Ctrl-C anywhere in the script
# has to put the cursor back.

hide_cursor() {
  if [[ "$IS_TTY" -eq 1 ]]; then tput civis 2>/dev/null || true; fi
}

show_cursor() {
  if [[ "$IS_TTY" -eq 1 ]]; then tput cnorm 2>/dev/null || true; fi
}

trap show_cursor EXIT INT TERM


# Primitives

# Repeat $1 exactly $2 times.
ui_repeat() {
  local char="$1" count="$2" out="" i

  for ((i = 0; i < count; i++)); do out+="$char"; done

  printf '%s' "$out"
}

# Length of a string with escape sequences discounted, so the panel
# border lines up whether or not colour is on.
ui_visible_len() {
  local stripped

  stripped="$(printf '%b' "$1" | sed -e 's/\x1b\[[0-9;]*m//g')"

  printf '%s' "${#stripped}"
}

clear_screen() {
  if [[ "$IS_TTY" -eq 1 ]]; then clear 2>/dev/null || printf '\033[H\033[2J'; fi
}

hr() {
  printf '  %b%s%b\n' "$DIM" "$(ui_repeat "$UI_RULE" "$((UI_WIDTH - 2))")" "$RESET"
}


# Log lines
#
# Two leading spaces, a coloured glyph, then the message -- the shape
# this script has always had, so nothing downstream needs re-reading.

die() { printf '  %b%s%b %s\n' "$RED" "$ICON_FAIL" "$RESET" "$*" >&2; exit 1; }
info() { printf '  %b%s%b %s\n' "$BLUE" "$ICON_INFO" "$RESET" "$*"; }
success() { printf '  %b%s%b %s\n' "$GREEN" "$ICON_OK" "$RESET" "$*"; }
warning() { printf '  %b%s%b %s\n' "$YELLOW" "$ICON_WARN" "$RESET" "$*"; }
error() { printf '  %b%s%b %s\n' "$RED" "$ICON_FAIL" "$RESET" "$*" >&2; }
run_cmd() { printf '  %b%s%b %b%s%b\n' "$MAGENTA" "$ICON_ARROW" "$RESET" "$DIM" "$*" "$RESET"; }

section() {
  printf '\n  %b%b%s%b\n' "$CYAN" "$BOLD" "$1" "$RESET"
  hr
}

pause() { echo; read -r -p "  Press Enter to continue..." _ || true; }

confirm() {
  local prompt="${1:-Continue?}" answer
  echo
  read -r -p "  $prompt [y/N]: " answer
  [[ "$answer" =~ ^[Yy]([Ee][Ss])?$ ]]
}


# Validator results
#
# A distinct shape from the log lines above: a check result, not an
# event. These used to be defined inside validator_run, which put a
# hundred-odd call sites behind a function-local definition; the names
# are kept exactly because those call sites are unchanged.

V_FAILED=0

v_ok() { printf '  %b%s%b %s\n' "$GREEN" "$ICON_OK" "$RESET" "$1"; }

v_fail() {
  printf '  %b%s%b %s\n' "$RED" "$ICON_FAIL" "$RESET" "$1"
  V_FAILED=1
}

v_info() { printf '  %b%s%b %s\n' "$YELLOW" "$ICON_WARN" "$RESET" "$1"; }

v_separator() { hr; }


# Panel
#
# The framed header. $1 is the title, $2 an optional right-aligned tag
# (the version), and any further arguments become dimmed fact lines
# inside the frame.

panel() {
  local title="$1" tag="${2:-}"
  shift || true
  shift || true

  local inner=$((UI_WIDTH - 2))
  local head=" $title " tail="" pad

  if [[ -n "$tag" ]]; then tail=" $tag "; fi

  pad=$((inner - ${#head} - ${#tail} - 1))
  if [[ "$pad" -lt 1 ]]; then pad=1; fi

  printf '%b%s%s%b%s%b%s%s%s%b\n' \
    "$CYAN" "$UI_TL" "$UI_H" \
    "$BOLD" "$head" "$RESET$CYAN" \
    "$(ui_repeat "$UI_H" "$pad")" "$tail" "$UI_TR" "$RESET"

  local line len
  for line in "$@"; do
    len="$(ui_visible_len "$line")"

    pad=$((inner - len - 2))
    if [[ "$pad" -lt 0 ]]; then pad=0; fi

    printf '%b%s%b %b%s%b%s %b%s%b\n' \
      "$CYAN" "$UI_V" "$RESET" \
      "$DIM" "$line" "$RESET" "$(ui_repeat ' ' "$pad")" \
      "$CYAN" "$UI_V" "$RESET"
  done

  printf '%b%s%s%s%b\n' \
    "$CYAN" "$UI_BL" "$(ui_repeat "$UI_H" "$inner")" "$UI_BR" "$RESET"
}


# Verdict
#
# The framed one-line result the validator ends on. Same framing as
# panel() but tinted by outcome and centred, and it respects UI_WIDTH and
# UI_UNICODE rather than the fixed 62-column unicode box it replaces --
# which used to survive `| cat` as raw box characters.

verdict() {
  local tint="$1" icon="$2" msg="$3"

  local inner=$((UI_WIDTH - 2))
  local body="$icon  $msg"
  local len=${#body}

  if [[ "$len" -gt "$inner" ]]; then
    body="${body:0:$inner}"
    len="$inner"
  fi

  local left=$(((inner - len) / 2))
  local right=$((inner - len - left))

  local rule
  rule="$(ui_repeat "$UI_H" "$inner")"

  printf '%b%s%s%s%b\n' "$tint" "$UI_TL" "$rule" "$UI_TR" "$RESET"

  printf '%b%s%b%s%b%s%b%s%b%s%b\n' \
    "$tint" "$UI_V" "$RESET" \
    "$(ui_repeat ' ' "$left")" \
    "$tint$BOLD" "$body" "$RESET" \
    "$(ui_repeat ' ' "$right")" \
    "$tint" "$UI_V" "$RESET"

  printf '%b%s%s%s%b\n' "$tint" "$UI_BL" "$rule" "$UI_BR" "$RESET"
}


# Spinner
#
# Wraps a long operation whose output we do not need to watch, showing
# an elapsed second count so that a slow `nix flake check` never looks
# hung. Operations whose output IS the point -- nixos-rebuild switch
# above all -- are deliberately left streaming to the terminal.
#
# Without a TTY it degrades to plain lines, so piped output stays
# readable and no escape sequences leak into a log file. On failure the
# captured output is replayed to stderr, so nothing is ever swallowed.

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

  # Erase the spinner line before the result replaces it.
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
  # shellcheck disable=SC2024  # sudo is for probing hardware; the target is user-owned
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
  printf '  Uptime:  %s\n' "$(uptime_human)"
}

# Uptime, without `uptime -p`
#
# -p is a procps extension and the uptime on this system rejects it, so
# all three call sites used to fall back to their placeholder string.
# /proc/uptime is always there and needs no external command.

uptime_human() {
  local secs d h m

  if [[ ! -r /proc/uptime ]]; then
    printf 'unknown'
    return
  fi

  read -r secs _ < /proc/uptime
  secs="${secs%%.*}"

  d=$((secs / 86400))
  h=$((secs % 86400 / 3600))
  m=$((secs % 3600 / 60))

  if [[ "$d" -gt 0 ]]; then
    printf '%dd %dh' "$d" "$h"
  elif [[ "$h" -gt 0 ]]; then
    printf '%dh %dm' "$h" "$m"
  else
    printf '%dm' "$m"
  fi
}

# One compact "user · kernel · nix · uptime" line for the menu panel.
overview_facts() {
  local nixv
  nixv="$(nix --version 2>/dev/null | grep -o '[0-9.]\+' | head -1)"

  printf '%s · %s · nix %s · up %s' \
    "${USER:-$(whoami 2>/dev/null || echo user)}" \
    "$(uname -r)" \
    "${nixv:-?}" \
    "$(uptime_human)"
}

# One menu row: number, label, dimmed description. The number keeps its
# colour so the eye can jump to it; the label is padded to a fixed
# column so the descriptions line up.
menu_item() {
  local num="$1" label="$2" desc="$3"

  printf '   %b%2s%b  %-22s%b%s%b\n' \
    "$CYAN" "$num" "$RESET" "$label" "$DIM" "$desc" "$RESET"
}

menu() {
  while true; do
    clear_screen

    echo
    panel "NixOS Configuration Manager" "v$VERSION" "$(overview_facts)"
    echo

    printf '  %b%bCONFIGURATION%b\n' "$CYAN" "$BOLD" "$RESET"
    menu_item 1 "Install / Setup" "first-time bootstrap"
    menu_item 2 "Update" "pull repo + flake update"
    menu_item 3 "Rebuild / Switch" "validate then switch"
    menu_item 4 "Dry rebuild" "build without switching"
    menu_item 5 "Check flake" "evaluate the flake"
    menu_item 6 "Rollback" "previous generation"
    menu_item 7 "Refresh hardware" "regenerate hardware config"
    menu_item 8 "List generations" "system profile history"

    echo
    printf '  %b%bVALIDATION & MAINTENANCE%b\n' "$CYAN" "$BOLD" "$RESET"
    menu_item 9 "Configuration check" "full validator"
    menu_item 10 "Maintenance" "cleanup dashboard"
    menu_item 11 "Installer preview" "dry-run the installer"
    menu_item 12 "Garbage collection" "reclaim store space"
    menu_item 13 "Optimize store" "deduplicate the store"
    menu_item 14 "Verify store" "check store integrity"
    menu_item 15 "Systemd health" "failed units"
    menu_item 16 "Store usage" "disk footprint"

    echo
    menu_item 0 "Exit" ""
    echo

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
      0) clear_screen; exit 0 ;;
      *) warning "Invalid option."; sleep 1 ;;
    esac
  done
}


# Integrated maintenance dashboard (from cleanup.sh)
M_NIXOS_DIR="$ROOT"
M_FLAKE_TARGET="$ROOT#laptop"
M_KEEP_GENERATIONS=5
M_ICON_OK="✓"
M_ICON_INFO="ℹ"
M_ICON_CLEAN="✦"
M_ICON_NIX=""
M_ICON_GIT=""
M_ICON_SYSTEM="⚙"
M_ICON_DISK="▣"
M_ICON_TRASH="✕"
M_ICON_CHECK="✓"

# The maintenance dashboard used to carry its own copy of the log and
# framing helpers (m_section, m_info, m_run, m_header, ...). They are
# gone; it now speaks the shared vocabulary defined at the top of the
# file. The M_ICON_* and M_* configuration values above stay, because
# the printf call sites in this section reference the icons directly.

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

  run_cmd "nix flake check"

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

  run_cmd "nixos-rebuild dry-build"

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

    run_cmd "Removing old generations..."

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

    run_cmd "Running Nix garbage collection..."

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

    run_cmd "Optimizing Nix store..."

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

  # The one operation in this script that a spinner genuinely improves:
  # it runs for minutes, prints nothing at all while it succeeds, and
  # prints the corrupt paths when it does not -- which spinner replays to
  # stderr. The other long operations here (nix-collect-garbage,
  # --optimise, flake check, dry-build) each end on a summary line worth
  # reading, so they stay streaming.
  if spinner "Verifying Nix store" sudo nix-store --verify --check-contents; then
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
  uptime="$(uptime_human)"

  printf '  %b Host:       %s\n' "${CYAN}${M_ICON_SYSTEM}${RESET}" "$hostname"
  printf '  %b Kernel:     %s\n' "${BLUE}${M_ICON_INFO}${RESET}" "$kernel"
  printf '  %b Nix:        %s\n' "${MAGENTA}${M_ICON_NIX}${RESET}" "$nix_version"
  printf '  %b Uptime:     %s\n' "${GREEN}${M_ICON_OK}${RESET}" "$uptime"
}

# Full maintenance is implemented by m_maintenance_dashboard above.
m_maintenance_dashboard() {
  clear_screen
  panel "NixOS Maintenance" "v$VERSION" "System maintenance dashboard"
  echo
  m_check_environment
  m_check_git
  echo
  if ! m_check_flake; then
    error "Maintenance stopped."
    pause
    return
  fi
  if ! m_dry_build; then
    error "Maintenance stopped."
    echo
    echo "Fix the NixOS configuration before cleanup."
    pause
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
  section "Final configuration check"
  run_cmd "Running final dry-build..."
  if sudo nixos-rebuild dry-build --flake "$M_FLAKE_TARGET"; then
    success "Final dry-build passed."
  else
    error "Final dry-build failed."
  fi
  echo
  hr
  echo
  printf '%b\n' "${GREEN}${BOLD}  ${M_ICON_OK} Maintenance complete${RESET}"
  echo
  printf '  %b Current generation: %s\n' "${GREEN}${M_ICON_SYSTEM}${RESET}" "$(m_get_current_generation)"
  printf '  %b Generations kept:  %s\n' "${CYAN}${M_ICON_CLEAN}${RESET}" "$M_KEEP_GENERATIONS"
  echo
  printf '%b\n' "${DIM}  Your NixOS configuration was not modified.${RESET}"
  echo
  pause
}


validator_run() {

# Integrated configuration validator (from check.sh)
#
# These four resets stay inside the function rather than moving up to the
# initialisers, because the menu can run the validator twice in one
# process and a stale V_FAILED from the first run would make the second
# report a failure it never found. v_ok / v_fail / v_info / v_separator
# now come from the shared definitions at the top of the file.
V_FAILED=0
V_FLAKE_LOG=""
V_NVIM_LOG=""
V_LUA_LOG=""


# Header

clear_screen

panel "NixOS Configuration Check" "" \
    "Repository: $ROOT" \
    "Branch:     $(git branch --show-current 2>/dev/null || printf 'unknown')"

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

    "home/quickshell/config/components/LauncherView.qml"

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
    "$HOME/.config/aurora/active-tmux.conf"
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
ACTIVE_TMUX="$HOME/.config/aurora/active-tmux.conf"
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

# Tmux theme

if [[ -f "$ACTIVE_TMUX" ]]; then

    if grep -q '^set -g status-style ' "$ACTIVE_TMUX" &&
        grep -q '^set -g window-status-current-format ' "$ACTIVE_TMUX"; then

        v_ok "Generated Tmux theme contains core styles"

    else

        v_fail "Generated Tmux theme is incomplete"

    fi

else

    v_info "Tmux theme not generated yet"

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

    verdict "$GREEN" "$ICON_OK" "Configuration is healthy"

    printf "\n"
    printf "${DIM}Safe to run:${RESET}\n"
    printf "  ${CYAN}sudo nixos-rebuild switch --flake .#laptop${RESET}\n"

    V_RESULT=0

else

    verdict "$RED" "$ICON_FAIL" "Problems require attention"

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
