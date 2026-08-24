<div align="center">

#  NixOS · Aurora

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
    <img src="https://img.shields.io/badge/Stylix-21%20themes-C792EA?style=for-the-badge" alt="Stylix">
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

##  Showcase

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
|  OS | NixOS 26.05 · `x86_64-linux` |
|  Desktop | Hyprland · Lua |
|  Shell | Quickshell · QML |
|  Theme | Stylix · 21 themes · active: `aurora` |
|  Terminal | Kitty · Zsh |
|  Editor | Neovim · 17 LSPs |
|  Management | Home Manager · Flakes |

### Design goals

`Declarative` → `Modular` → `Centralised` → `Reproducible` → `Keyboard-driven` → `Consistently themed`

---

## 🚀 Quick Start

### Fresh NixOS

```bash
git clone https://github.com/subha279/NixOS.git ~/NixOS
cd ~/NixOS
./setup.sh
```

The single setup manager handles installation, updates, rebuilds, validation, rollback and maintenance.

> **Identity stays centralised:** user name, hostname, Git identity, locale and timezone live in `lib/variables.nix`. The installer can replace these values for a new machine.

> **Passwords are never stored in Nix.** Setup invokes `passwd` interactively.

---

##  Setup Manager

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

##  Architecture

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
│   ├── gaming
│   ├── virtualisation
│   ├── development
│   └── stylix
│
├── home/
│   ├── hyprland
│   ├── quickshell
│   ├── neovim
│   ├── zsh
│   ├── kitty
│   ├── git
│   ├── ssh
│   └── theme
│
├── lib/
│   ├── variables.nix
│   └── themes.nix
│
├── scripts/
└── setup.sh
```

### System

Core Nix settings, GRUB, NetworkManager, users, fonts, PipeWire, Bluetooth, graphics, NVIDIA PRIME, XDG, power, Stylix, development, creator tools, gaming and virtualisation.

### Home Manager

Hyprland, Quickshell, Neovim, Zsh, Kitty, Git/SSH, Fastfetch, Obsidian, XDG and theme configuration.

---

##  Desktop Workflow

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

Common bindings:

| Key | Action |
|---|---|
| `SUPER + T` | Terminal |
| `SUPER + E` | File manager |
| `SUPER + B` | Browser |
| `SUPER + A` | App launcher |
| `SUPER + C` | Theme picker |
| `SUPER + P` | Wallpaper picker |
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
```

---

##  Theming

**Stylix is the single theming layer** for the desktop.

It covers GTK, Qt, Kitty, Neovim and Quickshell, with explicit NixOS and Home Manager targets.

Available themes include:

```text
aurora · gruvbox · tokyo-night · monochrome
catppuccin · nord · dracula · one-dark
everforest · rose-pine · solarized
kanagawa · github-dark · monokai-pro (and more)
```

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

##  Everyday Commands

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

### Reload without rebuilding

| Changed | Command |
|---|---|
| Hyprland Lua | `hyprctl reload` |
| Quickshell QML | `systemctl --user restart quickshell` |
| Debug Quickshell | `qs` |
| NixOS/Home Manager modules | `./setup.sh rebuild` |

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

##  Philosophy

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

###  NixOS · Hyprland · Quickshell · Stylix

<sub>Built for a fast, minimal and reproducible Wayland workflow.</sub>

</div>
