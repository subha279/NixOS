<div align="center">

# NixOS

### A declarative, modular and keyboard-driven NixOS desktop

**Hyprland** · **Quickshell** · **Stylix** · **Home Manager**

<p>
  <a href="https://github.com/subha279/NixOS">
    <img src="https://img.shields.io/badge/NixOS-26.05-7E7DFF?style=for-the-badge&logo=nixos&logoColor=white" alt="NixOS 26.05">
  </a>
  <a href="https://github.com/subha279/NixOS">
    <img src="https://img.shields.io/badge/Hyprland-Lua-58E1FF?style=for-the-badge" alt="Hyprland Lua">
  </a>
  <a href="https://github.com/subha279/NixOS">
    <img src="https://img.shields.io/badge/Quickshell-QML-BB86FC?style=for-the-badge" alt="Quickshell">
  </a>
  <a href="https://github.com/subha279/NixOS">
    <img src="https://img.shields.io/badge/Stylix-themes-C792EA?style=for-the-badge" alt="Stylix">
  </a>
</p>

<p>
  <a href="#-showcase">Showcase</a> ·
  <a href="#-quick-start">Quick Start</a> ·
  <a href="#-setup-manager">Setup Manager</a> ·
  <a href="#-architecture">Architecture</a> ·
  <a href="#-customisation">Customisation</a>
</p>

</div>

---

## 🎬 Showcase

<p align="center">
  <a href="https://www.youtube.com/watch?v=J9286xiVBNk">
    <img src="https://img.youtube.com/vi/J9286xiVBNk/maxresdefault.jpg"
         alt="NixOS + Hyprland desktop showcase"
         width="900">
  </a>
</p>

<p align="center">
  <sub>▶ Watch the full desktop showcase on YouTube</sub>
</p>

---

## ✦ What this is

A production-oriented, flake-based **NixOS laptop configuration** built around a clean Wayland workflow.

| Layer | Stack |
|---|---|
| 🐧 OS | NixOS 26.05 · `x86_64-linux` |
| 🖥️ Desktop | Hyprland · Lua |
| 🐚 Shell | Quickshell · QML |
| 🎨 Theme | Stylix · 7 themes |
| 💻 Terminal | Kitty · Zsh |
| ✏️ Editor | Neovim · 17 LSPs |
| 📦 Management | Home Manager · Flakes |

### Design goals

`Declarative` → `Modular` → `Centralised` → `Reproducible` → `Keyboard-driven` → `Consistently themed`

---

## 🚀 Quick Start

### Boot into NixOS live ISO

```bash
git clone https://github.com/subha279/NixOS.git ~/NixOS
cd ~/NixOS
./setup.sh
```

The single setup manager handles installation, updates, rebuilds, validation, rollback and maintenance. The repository no longer depends on a separate installer entry point.

> **Identity stays centralised:** user name, hostname, Git identity, locale and timezone live in `lib/variables.nix`. The installer can replace these values for a new machine.

> **Passwords are never stored in Nix.** Setup invokes `passwd` interactively.

---

## 🧰 Setup Manager

One entry point for the whole configuration:

```bash
./setup.sh
```

```text
╭────────────────────────────────────────────╮
│        NixOS Configuration Manager         │
│                 v1.1.0                     │
╰────────────────────────────────────────────╯

  SYSTEM
  1  Install / Setup
  2  Update configuration
  3  Rebuild / Switch
  4  Dry rebuild
  5  Check flake

  RECOVERY & TOOLS
  6  Rollback
  7  Refresh hardware config
  8  Garbage collection
  9  List generations
 10  Test installer (preview)
  0  Exit
```

### CLI mode

```bash
./setup.sh install
./setup.sh update
./setup.sh rebuild
./setup.sh dry
./setup.sh check
./setup.sh rollback
./setup.sh hardware
./setup.sh gc
./setup.sh generations
./setup.sh help
```

### Safe workflow

```text
check
  ↓
dry-build
  ↓
rebuild / switch
  ↓
verify generation
```

The installer backs up changed configuration before personalising it, generates hardware configuration, validates the flake and then rebuilds NixOS.

---

## 📁 Architecture

```text
NixOS/
├── flake.nix
├── hosts/
│   └── laptop/
│       ├── default.nix
│       └── hardware-configuration.nix
│
├── modules/
│   ├── core
│   ├── boot
│   ├── networking
│   ├── graphics
│   ├── nvidia
│   ├── audio
│   ├── bluetooth
│   ├── desktop
│   ├── fonts
│   ├── notifications
│   ├── power
│   ├── virtualisation
│   ├── development
│   ├── hardware/kreo-rgb
│   └── stylix
│
├── home/
│   ├── hyprland
│   ├── quickshell
│   ├── neovim
│   ├── zsh
│   ├── kitty
│   ├── tmux
│   ├── git
│   ├── ssh
│   └── theme
│
├── lib/
│   ├── variables.nix
│   └── themes.nix
│
└── setup.sh
```

### System

Core Nix settings, GRUB, NetworkManager, users, fonts, PipeWire, Bluetooth, graphics, NVIDIA PRIME, XDG, power, Stylix, development, creator tools, gaming and virtualisation.

### Home Manager

Hyprland, Quickshell, Neovim, Zsh, Kitty, Git/SSH, Fastfetch, Obsidian, XDG and theme configuration.

---

## 🖥️ Desktop Workflow

### Hyprland

Hyprland is configured in Lua:

```text
home/hyprland/
├── hyprland.lua
└── config/
    ├── variables.lua
    ├── keybinds.lua
    ├── monitor.lua
    ├── windowrules.lua
    ├── layerules.lua
    ├── animation.lua
    ├── decoration.lua
    ├── general.lua
    ├── layout.lua
    ├── input.lua
    ├── env.lua
    └── startup.lua
```

#### Motion

Animation lives in `home/hyprland/config/animation.lua`, and it is the compositor
that animates Quickshell — the bar, popups, launchers and notifications are all
Wayland layer surfaces, so `layersIn` / `layersOut` are what run when a popup
opens. QML does not animate those surfaces as well; two animations on one window
is what makes motion look unstable.

Every bezier there is monotonic: no control point has `y > 1`, so nothing travels
past its target and springs back. If you add a curve, keep that property —
`easeOutBack`-style curves are what produce the bounce.

Common bindings:

| Key | Action |
|---|---|
| `SUPER + T` | Terminal |
| `SUPER + E` | File manager |
| `SUPER + B` | Browser |
| `SUPER + A` | App launcher |
| `SUPER + C` | Theme picker |
| `SUPER + P` | Wallpaper picker |
| `SUPER + V` | Clipboard history |
| `SUPER + I` | Emoji picker |
| `SUPER + N` | Notes |
| `SUPER + Z` | GUI editor |
| `SUPER + F` | Toggle floating |
| `SUPER + Q` | Close window |
| `ALT + H/J/K/L` | Move focus |
| `SUPER + 1…9/0` | Workspaces |
| `SUPER + SHIFT + S` | Screenshot + annotation |

### Quickshell

Quickshell replaces the traditional Waybar/Wofi/Dunst stack with a single QML shell.

```text
config/
├── shell.qml
├── core/
├── services/
├── components/
└── modules/
```

Useful IPC:

```bash
qs ipc call launcher toggle
qs ipc call theme toggle
qs ipc call wallpaper toggle
qs ipc call clipboard toggle
qs ipc call emoji toggle
```

---

## 🎨 Theming

Theming has two halves.

**Stylix** owns the toolkit layer — GTK, Qt and fontconfig — driven from
`lib/themes.nix`. Those are the only three targets enabled; `autoEnable` is off
so nothing else is themed behind your back.

**The Aurora generator** in `home/theme` owns everything else. It reads the same
`lib/themes.nix` and writes a Lua, JSON, Kitty, Tmux and Starship file per theme,
which Hyprland, Quickshell, Kitty, Neovim, tmux and the prompt then read at
runtime. This is why switching theme does not need a rebuild.

Each target is generated as appearance only, so switching theme re-sources
colours into a running program without disturbing its keybindings — `aurora-theme`
reloads Hyprland, repaints every live Kitty socket, re-sources tmux and nudges
open Zsh sessions.

Available themes:

```text
catppuccin-mocha · tokyo-night · gruvbox
one-dark · everforest · rose-pine · kanagawa
```

Each is defined once in `lib/themes.nix` and generated out to Lua, JSON, a Kitty
conf, a Tmux conf and a Starship TOML, so Hyprland, Quickshell, Kitty, Neovim,
tmux and the prompt all read the same palette.

Runtime theme switching:

```text
SUPER + C
```

Shared theme definitions:

```text
lib/themes.nix
```

Shared identity/configuration:

```text
lib/variables.nix
```

---

## 💻 Everyday Commands

```bash
cd ~/NixOS

# Validate
./setup.sh check

# Test without switching
./setup.sh dry

# Rebuild and switch
./setup.sh rebuild

# Update repository + flake inputs
./setup.sh update

# Roll back
./setup.sh rollback

# List generations
./setup.sh generations
```

### Reloading vs applying configuration changes

> **Important:** `hyprctl reload` and restarting Quickshell only reload the **currently installed** configuration.
> If the Lua/QML file is managed by Home Manager, editing the repository does **not** update the live config until Home Manager/NixOS activation runs.

| Change | After editing the repository |
|---|---|
| Hyprland Lua | `./setup.sh rebuild` → `hyprctl reload` |
| Quickshell QML | `./setup.sh rebuild` → `systemctl --user restart quickshell` |
| Debug current Quickshell config | `qs` |
| NixOS/Home Manager `.nix` | `./setup.sh rebuild` |
| Runtime-only Hyprland change | `hyprctl reload` |
| Runtime-only Quickshell restart | `systemctl --user restart quickshell` |

For a fast development loop:

```bash
# Apply the Nix/Home Manager changes
./setup.sh rebuild

# Then reload the running desktop component if needed
hyprctl reload
systemctl --user restart quickshell
```

> **Why?** Home Manager usually links managed files from the active Nix store generation. The running system therefore sees the generation that was activated, not arbitrary edits sitting in `~/NixOS`.

---

## 🛠️ Customisation

### Change a keybinding

```text
home/hyprland/config/keybinds.lua
```

Then:

```bash
hyprctl reload
```

### Change an application

```text
home/hyprland/config/variables.lua
```

Bindings reference the shared variables, so one change propagates cleanly.

### Change identity

```text
lib/variables.nix
```

Keep shared values there instead of duplicating them across modules.

---

## 🧯 Recovery

Rollback to the previous generation:

```bash
./setup.sh rollback
```

Or directly:

```bash
sudo nixos-rebuild switch --rollback
```

List generations:

```bash
./setup.sh generations
```

---

## 🧭 Philosophy

```text
             ┌──────────────┐
             │  Declarative │
             └──────┬───────┘
                    ↓
             ┌──────────────┐
             │    Modular   │
             └──────┬───────┘
                    ↓
             ┌──────────────┐
             │  Centralised │
             └──────┬───────┘
                    ↓
             ┌──────────────┐
             │ Reproducible │
             └──────┬───────┘
                    ↓
             ┌──────────────┐
             │ Keyboard-led │
             └──────┬───────┘
                    ↓
             ┌──────────────┐
             │  Consistent  │
             │    Theme     │
             └──────────────┘
```

The goal is simple: **one declarative source of truth for the OS, desktop, shell, applications, identity and theme.**

---

<div align="center">

<sub>Built for a fast, minimal and reproducible Wayland workflow.</sub>

</div>
