# NixOS

> A production-oriented, flake-based **NixOS** configuration for a Wayland desktop built around **Hyprland + Quickshell + Stylix**.

<p align="center">
  <strong>Declarative • Modular • Themed • Keyboard-driven</strong>
</p>

---

## 01 · Overview

| Component | Configuration |
| --- | --- |
| **Host** | `laptop` — `x86_64-linux` |
| **Channel** | `nixos-26.05` |
| **Compositor** | Hyprland, configured in **Lua** |
| **Desktop Shell** | Quickshell |
| **Theming** | Stylix — 21 themes · active: `aurora` |
| **Terminal** | Kitty · Zsh |
| **Editor** | Neovim · 17 LSPs |

### Architecture at a glance

```text
NixOS
├── System
│   ├── NixOS modules
│   ├── Hardware / graphics
│   ├── Audio / Bluetooth
│   ├── Gaming
│   └── Virtualisation
│
├── Home Manager
│   ├── Hyprland
│   ├── Quickshell
│   ├── Neovim
│   ├── Zsh
│   └── Application configuration
│
└── Shared
    ├── Identity / variables
    └── Stylix themes
```

---

## 02 · Quick Start

### Rebuild

```sh
cd ~/NixOS
sudo nixos-rebuild switch --flake .#laptop
```

### Common operations

```sh
nix flake check
nix flake update

sudo nixos-rebuild test --flake .#laptop
sudo nixos-rebuild boot --flake .#laptop
```

> **Tip:** Changes limited to Hyprland Lua or Quickshell QML normally do not require a full NixOS rebuild. See [09 · Reloading Without a Rebuild](#09--reloading-without-a-rebuild).

---

## 03 · Repository Layout

```text
NixOS/
├── flake.nix
├── hosts/
│   └── laptop/
│       ├── default.nix
│       └── hardware-configuration.nix
├── modules/
│   └── system-level NixOS modules
├── home/
│   └── Home Manager modules + dotfiles
├── lib/
│   └── shared values, identity + themes
└── scripts/
    ├── check.sh
    └── cleanup.sh
```

---

## 04 · System Modules

All system modules are imported from `hosts/laptop/default.nix`.

| Module | Purpose |
| --- | --- |
| `core` | Nix settings, garbage collection, locale, timezone |
| `boot` | GRUB, systemd initrd, quiet boot, 1s menu timeout |
| `networking` | NetworkManager |
| `users` | Account, Zsh, sudo |
| `packages` | Base system package set |
| `fonts` | Font packages including Apple fonts overlay |
| `audio` | PipeWire, WirePlumber, rtkit |
| `bluetooth` | BlueZ + Blueman, powered on at boot |
| `polkit` | Polkit authentication agent |
| `graphics` | Mesa / OpenGL |
| `nvidia` | Hybrid Intel + NVIDIA PRIME offload, open kernel module |
| `xdg` | XDG base directories and portals |
| `notifications` | Portal config, dconf, notification plumbing |
| `hyprland` | Compositor package and session |
| `desktop` | `applications.nix` + `services.nix` — Thunar, gvfs, udisks2, tumbler |
| `session` | Session variables and targets |
| `monitoring` | System monitoring tools |
| `power` | UPower, power management |
| `stylix` | Global theming engine and per-target settings |
| `development` | Language toolchains and dev tooling |
| `creator` | Media creation applications |
| `gaming` | Steam, GameMode |
| `virtualisation` | libvirt / QEMU |

---

## 05 · Home Manager Modules

| Module | Contents |
| --- | --- |
| `hyprland` | `hyprland.lua` entry point + `config/*.lua` + wallpaper script |
| `quickshell` | Full QML desktop shell, systemd user service, D-Bus activation |
| `neovim` | `init.lua`, 17 LSP configs, 12 plugin configs, custom theme |
| `zsh` | Aliases, completion, environment, history, keybindings, plugins, shell |
| `kitty` | Terminal configuration |
| `git` · `ssh` | Identity and client config, sourced from `lib/variables.nix` |
| `theme` | Home-level Stylix targets |
| `fastfetch` · `obsidian` · `xdg` | Miscellaneous user configuration |

---

## 06 · Hyprland

Hyprland is configured in **Lua** rather than `hyprland.conf`.

`hyprland.lua` is the entry point and loads each module with:

```lua
require("config.<name>")
```

The `hl` global provides the Hyprland Lua DSL.

### Configuration map

| File | Responsibility |
| --- | --- |
| `variables.lua` | Modifiers, default applications, command strings — **edit this first** |
| `keybinds.lua` | All key bindings |
| `monitor.lua` | Display layout |
| `windowrules.lua` | 38 window rules |
| `layerules.lua` | 6 layer-surface rules |
| `animation.lua` | Bezier curves and animation timings |
| `decoration.lua` | Rounding, blur, shadows, opacity |
| `general.lua` · `layout.lua` | Gaps, borders, dwindle / master / scrolling |
| `input.lua` | Keyboard, touchpad, sensitivity |
| `env.lua` | Environment variables |
| `startup.lua` | Autostart and D-Bus handoff |
| `misc.lua` · `theme.lua` | Everything else |

### ⚠️ Lua regex escaping

Window and layer rules are Lua strings, so regex backslashes must be doubled:

```lua
"^\\.blueman-manager-wrapped$"
```

**Not:**

```lua
"^\.blueman-manager-wrapped$"
```

A single regex backslash in a Lua string is an invalid Lua escape and Hyprland will refuse to load the file.

---

# 07 · Keybindings

`home/hyprland/config/keybinds.lua` contains the complete keybinding set.

> **Modifiers:** `SUPER` is the main modifier. `ALT` is used only for focus movement.

### 07.1 · Applications

| Keys | Action | Command |
| --- | --- | --- |
| `SUPER` + `T` | Terminal | `kitty` |
| `SUPER` + `E` | File manager | `thunar` |
| `SUPER` + `B` | Browser | `firefox` |
| `SUPER` + `Z` | GUI editor | `zeditor` |
| `SUPER` + `N` | Notes | `obsidian` |
| `SUPER` + `A` | App launcher | `qs ipc call launcher toggle` |

### 07.2 · Quickshell Surfaces

| Keys | Action | Command |
| --- | --- | --- |
| `SUPER` + `A` | App launcher | `qs ipc call launcher toggle` |
| `SUPER` + `C` | Colourscheme picker | `qs ipc call theme toggle` |
| `SUPER` + `P` | Wallpaper picker | `qs ipc call wallpaper toggle` |

### 07.3 · Windows

| Keys | Action |
| --- | --- |
| `SUPER` + `Q` | Close focused window |
| `SUPER` + `F` | Toggle floating |
| `SUPER` + `Left Mouse` | Drag window |
| `SUPER` + `Right Mouse` | Resize window |

### 07.4 · Focus

Vim-style directions use `ALT`.

| Keys | Direction |
| --- | --- |
| `ALT` + `H` | Left |
| `ALT` + `J` | Down |
| `ALT` + `K` | Up |
| `ALT` + `L` | Right |

### 07.5 · Workspaces

| Keys | Action |
| --- | --- |
| `SUPER` + `1`…`9` | Switch to workspace 1–9 |
| `SUPER` + `0` | Switch to workspace **10** |
| `SUPER` + `SHIFT` + `1`…`9` | Move window to workspace 1–9 |
| `SUPER` + `SHIFT` + `0` | Move window to workspace **10** |

Workspace 10 uses `0` because the loop is `for i = 1, 10` with `key = i % 10`.

### 07.6 · Screenshot

| Keys | Action |
| --- | --- |
| `SUPER` + `SHIFT` + `S` | Select a region, then annotate |

```sh
grim -g "$(slurp)" - | swappy -f -
```

Drag to select an area; Swappy opens for annotation and saving.

### 07.7 · Media Keys

All media bindings are **locked**, so they continue to work on the lock screen. Volume and brightness also **repeat** while held.

#### Audio

| Key | Action | Command |
| --- | --- | --- |
| `XF86AudioRaiseVolume` | Volume +5% | `wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+` |
| `XF86AudioLowerVolume` | Volume −5% | `wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-` |
| `XF86AudioMute` | Mute output | `wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle` |
| `XF86AudioMicMute` | Mute microphone | `wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle` |

`-l 1` caps volume at 100%.

#### Brightness

| Key | Action | Command |
| --- | --- | --- |
| `XF86MonBrightnessUp` | Brightness +5% | `brightnessctl -e4 -n2 set 5%+` |
| `XF86MonBrightnessDown` | Brightness −5% | `brightnessctl -e4 -n2 set 5%-` |

`-e4` applies a perceptual curve and `-n2` keeps a minimum level so the screen cannot go fully black.

#### Playback

| Key | Action | Command |
| --- | --- | --- |
| `XF86AudioPlay` | Play / pause | `playerctl play-pause` |
| `XF86AudioPause` | Play / pause | `playerctl play-pause` |
| `XF86AudioNext` | Next track | `playerctl next` |
| `XF86AudioPrev` | Previous track | `playerctl previous` |

---

## 08 · Shell Aliases

Defined in `home/zsh/aliases.nix`.

### 08.1 · Listing — `eza`

| Alias | Expands to |
| --- | --- |
| `ls` | `eza --icons --group-directories-first` |
| `ll` | `eza -lah --icons --group-directories-first` |
| `la` | `eza -a --icons --group-directories-first` |
| `lt` / `tree` | `eza --tree --icons --group-directories-first` |

### 08.2 · Navigation

| Alias | Expands to |
| --- | --- |
| `..` | `cd ..` |
| `...` | `cd ../..` |
| `....` | `cd ../../..` |

### 08.3 · Editors

| Alias | Expands to |
| --- | --- |
| `v` / `vi` / `vim` | `nvim` |
| `sv` | `sudo -E nvim` |

### 08.4 · Git

| Alias | Expands to |
| --- | --- |
| `gs` | `git status` |
| `gd` | `git diff` |
| `gl` | `git log --oneline --graph --decorate` |
| `ga` | `git add` |
| `gc` | `git commit` |
| `gp` | `git push` |
| `gpl` | `git pull --ff-only` |

### 08.5 · Utilities

| Alias | Expands to |
| --- | --- |
| `c` | `clear` |
| `df` | `df -h` |
| `du` | `du -h` |
| `diff` | `diff --color=auto` |

---

## 09 · Making Changes

### Change a keybinding

Edit:

```text
home/hyprland/config/keybinds.lua
```

Then reload:

```sh
hyprctl reload
```

### Change the application opened by a key

Edit:

```text
home/hyprland/config/variables.lua
```

Bindings reference the variables there, so one change updates every use.

### Binding syntax

```lua
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(vars.terminal))

hl.bind(
    "XF86AudioMute",
    hl.dsp.exec_cmd(vars.volumeMute),
    { locked = true, repeating = true }
)
```

| Flag | Meaning |
| --- | --- |
| `locked = true` | Works while the session is locked |
| `repeating = true` | Fires continuously while held |
| `mouse = true` | Binds a mouse button (`mouse:272` left, `mouse:273` right) |

### Displays

| Output | Configuration |
| --- | --- |
| `eDP-1` | Disabled — laptop panel off |
| `HDMI-A-1` | `1920x1080@180.00301` at `0x0`, scale 1 |

To use the laptop screen again, set `disabled = false` in `monitor.lua` and uncomment the mode, position and scale lines.

---

## 10 · Quickshell

Quickshell replaces the traditional **Waybar + Wofi + Dunst** stack with a single QML process.

`shell.qml` is the entry point.

### Structure

```text
config/
├── shell.qml
├── core/
│   └── Theme, Icons, PopupManager, OsdController
├── services/
│   └── System-state singletons
├── components/
│   └── Reusable UI components
└── modules/
    └── Bar widgets and popups
```

### Services

Quickshell services are singletons responsible for system state:

```text
AppsService
AudioService
BatteryService
BluetoothService
BrightnessService
NetworkService
NotificationServer
ThemeService
WallpaperService
```

### IPC

```sh
qs ipc call launcher toggle     # SUPER + A
qs ipc call theme toggle        # SUPER + C
qs ipc call wallpaper toggle    # SUPER + P
```

### Notifications

Quickshell owns `org.freedesktop.Notifications` through a D-Bus activation file in `home/quickshell/default.nix`.

It starts on demand when an application sends its first notification, so there is no separate notification daemon.

`nm-applet` and `blueman-applet` still run as the NetworkManager secret agent and Bluetooth pairing agent. Their tray icons are hidden and their own popups are disabled via dconf to avoid duplicating shell notifications.

Test notification delivery:

```sh
notify-send "aurora" "test"
```

---

## 11 · Theming

**Stylix is the single theming layer** for colours, fonts and wallpaper across:

```text
GTK
Qt
Kitty
Neovim
Quickshell
```

### Theme configuration

| Setting | Location |
| --- | --- |
| Theme definitions | `lib/themes.nix` |
| Number of themes | 21 |
| Active theme | `global.activeTheme` |
| Runtime switcher | `SUPER` + `C` |

### Available themes

```text
aurora
gruvbox
gruvbox-light
tokyo-night
tokyo-night-storm
monochrome
catppuccin-mocha
catppuccin-macchiato
catppuccin-frappe
catppuccin-latte
nord
dracula
one-dark
everforest
rose-pine
rose-pine-moon
solarized-dark
solarized-light
kanagawa
github-dark
monokai-pro
```

> **Important:** `stylix.autoEnable` is off, so targets are enabled explicitly.

Stylix exposes two separate `targets` options:
- NixOS level: `modules/stylix/`
- Home Manager level: `home/theme/`

They are **not duplicates**. Removing the Home Manager targets will silently unstyle GTK and Qt applications.

---

## 12 · Identity & Shared Values

All personal/shared values are centralised in:

```text
lib/variables.nix
```

Change them there rather than duplicating values across individual modules.

---

## 13 · Scripts

### Configuration check

```sh
./scripts/check.sh
```

Validates the configuration before rebuilding.

The script runs structural assertions covering:
- flake evaluation
- module wiring
- keybind sanity
- notification delivery

### Cleanup

```sh
./scripts/cleanup.sh
```

Maintenance dashboard that keeps **5 generations**.

---

## 14 · Reloading Without a Rebuild

| Changed | Command |
| --- | --- |
| Hyprland Lua | `hyprctl reload` |
| Quickshell QML | `systemctl --user restart quickshell` |
| Quickshell + live logs | `qs` |
| Anything in `modules/` or Home Manager `.nix` | Full rebuild |

> **Debug tip:** Running `qs` directly is the fastest way to debug QML. Errors print with the file and line number instead of disappearing into the journal.

---

## 15 · Troubleshooting

### Hyprland refuses to load after editing a rule

Almost always a single backslash in a Lua regex.

**Fix:** double the regex backslash.

### `Type X unavailable` / `Property value set multiple times`

This is a QML error.

Run:

```sh
qs
```

to get the file and line.

### `Cannot assign to non-existent property`

The property does not exist on that QML type.

Positioners such as `Column`, `Row`, `Grid`, and `Flow` accept `add`, `move`, and `populate` only. `displaced` belongs to `ListView` and `GridView`.

### Applications lost their theme

Check that the Home Manager Stylix targets in:

```text
home/theme/default.nix
```

are still present.

### Rolling back

Pick the previous generation from the GRUB menu.

The boot menu timeout is **1 second**, so hold `Shift` during boot if you miss it.

---

## 16 · Recovery

### Roll back to the previous generation

```sh
sudo nixos-rebuild switch --rollback
```

### List system generations

```sh
nix-env --list-generations --profile /nix/var/nix/profiles/system
```

---

## 17 · Daily Command Reference

```sh
# Enter repository
cd ~/NixOS

# Validate
nix flake check
./scripts/check.sh

# Rebuild
sudo nixos-rebuild switch --flake .#laptop

# Test without creating a boot entry
sudo nixos-rebuild test --flake .#laptop

# Apply on next boot
sudo nixos-rebuild boot --flake .#laptop

# Update flake inputs
nix flake update

# Reload Hyprland
hyprctl reload

# Restart Quickshell
systemctl --user restart quickshell

# Debug Quickshell
qs

# Roll back
sudo nixos-rebuild switch --rollback
```

---

## 18 · Project Philosophy

```text
Declarative
    ↓
Modular
    ↓
Centralised
    ↓
Reproducible
    ↓
Keyboard-driven
    ↓
Consistently themed
```

The configuration keeps system modules, Home Manager modules, desktop behaviour, shell services, identity, and themes separated while maintaining a single declarative source of truth.

---

<p align="center">
  <strong>NixOS · Hyprland · Quickshell · Stylix</strong><br>
  <sub>Flake-based laptop configuration</sub>
</p>
