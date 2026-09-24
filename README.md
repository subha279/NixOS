<div align="center">

<img src="https://readme-typing-svg.herokuapp.com?font=JetBrains+Mono&weight=600&size=42&pause=1200&color=CBA6F7&center=true&vCenter=true&width=600&lines=%F0%9F%8C%BB+Sunflower" alt="Sunflower" />

<a href="https://github.com/subha279/NixOS">
  <img src="https://readme-typing-svg.herokuapp.com?font=JetBrains+Mono&size=16&pause=2000&color=989CAC&center=true&vCenter=true&width=700&lines=Declarative+NixOS+desktop;Hyprland+%2B+Quickshell%2C+keyboard-first;7+Sunflower+themes.+Zero+rebuilds.;One+setup.sh+for+install+%E2%80%A2+update+%E2%80%A2+repair" alt="Sunflower tagline" />
</a>

**Hyprland** · **Quickshell** · **Sunflower themes** · **Home Manager**

<p>
  <a href="https://github.com/subha279/NixOS">
    <img src="https://img.shields.io/badge/Sunflower-desktop-C792EA?style=for-the-badge&logo=sunrise&logoColor=white" alt="Sunflower desktop">
  </a>
  <a href="https://github.com/subha279/NixOS">
    <img src="https://img.shields.io/badge/NixOS-26.05-7E7DFF?style=for-the-badge&logo=nixos&logoColor=white" alt="NixOS 26.05 base">
  </a>
  <a href="https://github.com/subha279/NixOS">
    <img src="https://img.shields.io/badge/Hyprland-Lua-58E1FF?style=for-the-badge" alt="Hyprland Lua">
  </a>
  <a href="https://github.com/subha279/NixOS">
    <img src="https://img.shields.io/badge/Quickshell-QML-BB86FC?style=for-the-badge" alt="Quickshell">
  </a>
</p>

<p>
  <a href="#-showcase">Showcase</a> ·
  <a href="#-features">Features</a> ·
  <a href="#-quick-start">Quick Start</a> ·
  <a href="#-setup-manager">Setup Manager</a> ·
  <a href="#-architecture">Architecture</a> ·
  <a href="#-theming">Theming</a> ·
  <a href="#-customisation">Customisation</a>
</p>

</div>

---

## 🎬 Showcase

<p align="center">
  <a href="https://www.youtube.com/watch?v=J9286xiVBNk">
    <img src="https://img.youtube.com/vi/J9286xiVBNk/maxresdefault.jpg"
         alt="Sunflower desktop showcase"
         width="900">
  </a>
</p>

<p align="center">
  <sub>▶ Watch the full Sunflower desktop showcase on YouTube</sub>
</p>

<p align="center">
  <img src="https://readme-typing-svg.herokuapp.com?font=JetBrains+Mono&size=14&pause=1500&color=89B4FA&center=true&vCenter=true&width=620&lines=%24+qs+ipc+call+launcher+toggle;%24+qs+ipc+call+theme+toggle+%F0%9F%8C%BB;%24+sunflower-theme+tokyo-night+%E2%9C%A8;%24+hyprctl+reload+%E2%9A%A1" alt="Sunflower live commands demo" />
</p>

---

## ✦ What is Sunflower?

**Sunflower** is a production-oriented, flake-based **NixOS desktop** built around a clean Wayland workflow — Hyprland composed in Lua, a Quickshell shell in QML, and a runtime theme engine that repaints the whole desktop without rebuilding.

| Layer          | Stack                          |
| :------------- | :----------------------------- |
| 🌻 Identity    | Sunflower desktop on NixOS 26.05 · `x86_64-linux` |
| 🖥️ Desktop     | Hyprland · Lua                 |
| 🐚 Shell       | Quickshell · QML               |
| 🎨 Theme       | Sunflower engine + Stylix · 7 themes, zero-rebuild switching |
| 💻 Terminal    | Kitty · Zsh · tmux · Starship  |
| ✏️ Editor      | Neovim · LSPs + formatters     |
| 📦 Management  | Home Manager · Flakes · `setup.sh` |

> [!TIP]
> **Design goals:** `Declarative` → `Modular` → `Centralised` → `Reproducible` → `Keyboard-driven` → `Consistently themed`

---

## ✨ Features

| | Feature | Details |
| :- | :------ | :------ |
| 🌻 | **Runtime theming** | `SUPER + C` swaps theme across Hyprland, Quickshell, Kitty, Neovim, tmux and Starship — no rebuild |
| 🎨 | **7 palettes** | `catppuccin-mocha · tokyo-night · gruvbox · one-dark · everforest · rose-pine · kanagawa` |
| 🖥️ | **Lua compositor** | Hyprland config as composable Lua modules with monotonic, bounce-free animation |
| 🐚 | **QML shell** | One Quickshell shell replaces Waybar/Wofi/Dunst: bar, popups, launchers, notifications, clipboard, emoji |
| ⌨️ | **Keyboard-first** | Launcher, theme/wallpaper pickers, clipboard, emoji, notes, screenshot — all on `SUPER` chords |
| 🧰 | **One manager** | `./setup.sh` installs, upgrades, rebuilds, validates, cleans, rolls back, verifies boot |
| 🛡️ | **Safe workflow** | `check → dry-build → rebuild → verify`, timestamped backups, hardware re-detection |
| 🧩 | **Centralised identity** | User, hostname, Git identity, locale, timezone live once in `lib/variables.nix` |
| 🔒 | **No secrets in Nix** | Passwords only via interactive `passwd`, never written to the store |

---

## 🚀 Quick Start

### Boot the NixOS live ISO, then:

```bash
git clone https://github.com/subha279/NixOS.git ~/NixOS
cd ~/NixOS
./setup.sh
```

The single setup manager handles installation, updates, rebuilds, validation, rollback and maintenance. There is no separate installer entry point.

> [!NOTE]
> **Identity stays centralised:** user name, hostname, Git identity, locale and timezone live in `lib/variables.nix`. The installer replaces these values for a new machine.

> [!IMPORTANT]
> **Passwords are never stored in Nix.** Setup invokes `passwd` interactively.

---

## 🧰 Setup Manager

One entry point for the whole configuration:

```bash
./setup.sh
```

```text
╭─ Sunflower Configuration Manager ── v1.0 ─╮
│  subha · kernel · nix 2.34 · up 11m        │
╰────────────────────────────────────────────╯

  ◆  MAIN
  ──────────────────────────────────────
    1  Install Sunflower       fresh install, partitions the disk
    2  Upgrade                 git pull, flake update, rebuild
    3  Free disk space         old generations, GC, optimise

  ⚙  SYSTEM
  ──────────────────────────────────────
    4  Rebuild / Switch        validate then switch
    5  Dry rebuild             build without switching
    6  Check flake             evaluate the flake
    7  Rollback                previous generation
    8  List generations        system profile history
    9  Refresh hardware        regenerate hardware config
   10  Configure identity      on an already-installed system

  ✓  CHECKS & MAINTENANCE
  ──────────────────────────────────────
   11  Configuration check     full validator
   12  Maintenance dashboard   guarded full cleanup
   13  Garbage collection      reclaim store space
   14  Optimize store          deduplicate the store
   15  Verify store            check store integrity
   16  Systemd health          failed units
   17  Store usage             disk footprint

  ▸  INSTALLER TOOLS
  ──────────────────────────────────────
   18  Install dry-run         plan the install, change nothing
   19  Verify boot             re-check an install mounted at /mnt
   20  Identity preview        preview the prompts only

    0  Exit
```

<p align="center">
  <img src="https://readme-typing-svg.herokuapp.com?font=JetBrains+Mono&size=14&pause=1500&color=A6E3A1&center=true&vCenter=true&width=560&lines=%24+..%2Fsetup.sh+check+%E2%9C%93;%24+..%2Fsetup.sh+dry+%E2%9C%93;%24+..%2Fsetup.sh+rebuild+%F0%9F%8C%BB;%24+..%2Fsetup.sh+rollback+%E2%86%A9" alt="Sunflower safe workflow demo" />
</p>

<details>
<summary><b>CLI mode</b></summary>

```bash
./setup.sh install                 # smart: clean-install on ISO, identity pass on NixOS
./setup.sh clean-install           # force the fresh installer
./setup.sh clean-install --dry-run # plan a fresh install, change nothing
./setup.sh update                  # pull repo + update flake inputs + rebuild
./setup.sh rebuild                 # validate + rebuild/switch
./setup.sh dry                     # dry rebuild
./setup.sh check                   # flake check
./setup.sh validate                # full configuration validator
./setup.sh maintain                # full maintenance dashboard
./setup.sh free-space              # old generations, GC, store optimisation
./setup.sh rollback                # roll back one generation
./setup.sh hardware                # regenerate hardware config
./setup.sh generations             # list system generations
./setup.sh gc                      # garbage collection
./setup.sh optimize                # optimize Nix store
./setup.sh verify-store            # verify Nix store contents
./setup.sh systemd                 # check failed systemd units
./setup.sh store                   # show Nix store usage
./setup.sh verify-boot             # re-verify an install mounted at /mnt
./setup.sh configure               # identity pass on an existing install
./setup.sh test-install            # safe installer preview
```

</details>

### Safe workflow

```text
check  →  dry-build  →  rebuild / switch  →  verify generation
```

The installer backs up changed configuration before personalising it, generates hardware configuration, validates the flake and then rebuilds NixOS.

---

## 📁 Architecture

```text
Sunflower/  (NixOS desktop)
├── flake.nix                  # nixpkgs 26.05, home-manager, stylix,
│                              # apple-fonts, zen-browser
├── hosts/
│   └── laptop/                # host entry + hardware-configuration.nix
│
├── modules/                   # NixOS system modules
│   ├── core · boot · networking · users · packages
│   ├── audio · bluetooth · graphics · nvidia
│   ├── desktop · hyprland · session · xdg
│   ├── fonts · stylix · notifications
│   ├── power · polkit · monitoring
│   ├── development · ai · creator · virtualisation
│   └── hardware/kreo-rgb
│
├── home/                      # Home Manager modules
│   ├── hyprland · quickshell · theme (Sunflower engine)
│   ├── neovim · zsh · kitty · tmux
│   ├── git · ssh · xdg
│   └── fastfetch · obsidian · mpv
│
├── lib/
│   ├── variables.nix          # identity: user, system, hardware
│   ├── themes.nix             # Sunflower engine + active theme
│   └── colorschemes/          # 7 theme definitions
│
└── setup.sh                   # bootstrap + lifecycle manager
```

### System

Core Nix settings, GRUB, NetworkManager, users, fonts, PipeWire, Bluetooth, graphics, NVIDIA PRIME, XDG, power, Stylix, development, creator tools, gaming and virtualisation.

### Home Manager

Hyprland, Quickshell, Neovim, Zsh, Kitty, tmux, Git/SSH, Fastfetch, Obsidian, XDG and Sunflower theme configuration.

---

## 🖥️ Desktop Workflow

### Hyprland

Hyprland is configured in Lua:

```text
home/hyprland/
├── hyprland.lua
└── config/
    ├── variables.lua · keybinds.lua · monitor.lua
    ├── windowrules.lua · layerules.lua
    ├── animation.lua · decoration.lua
    ├── general.lua · layout.lua
    ├── input.lua · env.lua · misc.lua
    ├── theme.lua · startup.lua
```

> [!NOTE]
> **Motion:** animation lives in `home/hyprland/config/animation.lua`, and it is the compositor
> that animates Quickshell — the bar, popups, launchers and notifications are all
> Wayland layer surfaces, so `layersIn` / `layersOut` are what run when a popup
> opens. QML does not animate those surfaces as well; two animations on one window
> is what makes motion look unstable.
>
> Every bezier there is monotonic: no control point has `y > 1`, so nothing travels
> past its target and springs back. If you add a curve, keep that property —
> `easeOutBack`-style curves are what produce the bounce.

<details>
<summary><b>⌨️ Common bindings</b></summary>

| Key                | Action               |
| :----------------- | :------------------- |
| `SUPER + T`        | Terminal             |
| `SUPER + E`        | File manager         |
| `SUPER + B`        | Browser              |
| `SUPER + A`        | App launcher         |
| `SUPER + C`        | Theme picker         |
| `SUPER + P`        | Wallpaper picker     |
| `SUPER + V`        | Clipboard history    |
| `SUPER + I`        | Emoji picker         |
| `SUPER + N`        | Notes                |
| `SUPER + Z`        | GUI editor           |
| `SUPER + F`        | Toggle floating      |
| `SUPER + Q`        | Close window         |
| `ALT + H/J/K/L`    | Move focus           |
| `SUPER + 1…9/0`    | Workspaces           |
| `SUPER + SHIFT + S`| Screenshot + annotate|

</details>

### Quickshell

Quickshell replaces the traditional Waybar/Wofi/Dunst stack with a single QML shell.

```text
config/
├── shell.qml
├── core/         # Theme, icons, popup + OSD controllers
├── services/     # Apps, wallpaper, theme, audio, network, …
├── components/   # Bar, popups, launcher views, sliders
└── modules/      # Clock, battery, volume, notifications, …
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

| Owner | Scope |
| :---- | :---- |
| **Stylix** | Toolkit layer — GTK, Qt, fontconfig — driven from `lib/themes.nix` (`autoEnable` off, so nothing is themed behind your back) |
| **Sunflower generator** (`home/theme`) | Everything else — per-theme Lua, JSON, Kitty, tmux and Starship files that Hyprland, Quickshell, Kitty, Neovim, tmux and the prompt read at runtime. Switching theme needs no rebuild. |

Each target is generated as appearance only, so switching theme re-sources
colours into a running program without disturbing its keybindings — `sunflower-theme`
reloads Hyprland, repaints every live Kitty socket, re-sources tmux and nudges
open Zsh sessions.

<p align="center">
  <img src="https://readme-typing-svg.herokuapp.com?font=JetBrains+Mono&size=14&pause=1500&color=F5C2E7&center=true&vCenter=true&width=620&lines=catppuccin-mocha+%E2%80%A2+tokyo-night+%E2%80%A2+gruvbox;one-dark+%E2%80%A2+everforest+%E2%80%A2+rose-pine+%E2%80%A2+kanagawa;%F0%9F%8C%BB+SUPER+%2B+C+to+bloom+%E2%9C%A8" alt="Sunflower themes animation" />
</p>

Available themes:

```text
catppuccin-mocha · tokyo-night · gruvbox
one-dark · everforest · rose-pine · kanagawa
```

Each is defined once in `lib/colorschemes/` and generated out to Lua, JSON, a Kitty
conf, a tmux conf and a Starship TOML, so Hyprland, Quickshell, Kitty, Neovim,
tmux and the prompt all read the same palette.

Runtime theme switching:

```text
SUPER + C
```

| Shared file | Purpose |
| :---------- | :------ |
| `lib/themes.nix` | Sunflower theme definitions + active theme |
| `lib/variables.nix` | Identity + system configuration |

---

## 💻 Everyday Commands

```bash
cd ~/NixOS

./setup.sh check       # validate
./setup.sh dry         # test without switching
./setup.sh rebuild     # rebuild and switch
./setup.sh update      # update repository + flake inputs
./setup.sh rollback    # roll back
./setup.sh generations # list generations
```

### Reloading vs applying configuration changes

> [!IMPORTANT]
> `hyprctl reload` and restarting Quickshell only reload the **currently installed** configuration.
> If the Lua/QML file is managed by Home Manager, editing the repository does **not** update the live config until Home Manager/NixOS activation runs.

| Change | After editing the repository |
| :----- | :--------------------------- |
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

> [!NOTE]
> **Why?** Home Manager usually links managed files from the active Nix store generation. The running system therefore sees the generation that was activated, not arbitrary edits sitting in `~/NixOS`.

---

## 🛠️ Customisation

| Want to change | Edit |
| :------------- | :--- |
| Keybinding | `home/hyprland/config/keybinds.lua` → `hyprctl reload` |
| Application | `home/hyprland/config/variables.lua` (bindings reference shared variables, so one change propagates) |
| Identity | `lib/variables.nix` (keep shared values there, never duplicate across modules) |
| Sunflower theme | `lib/themes.nix` + `lib/colorschemes/` → `SUPER + C` at runtime |

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
Declarative → Modular → Centralised → Reproducible → Keyboard-led → Consistently themed
```

> The goal is simple: **one declarative source of truth for the OS, desktop, shell, applications, identity and theme — with Sunflower, it blooms at runtime.**

---

<div align="center">

<img src="https://readme-typing-svg.herokuapp.com?font=JetBrains+Mono&size=13&pause=2500&color=989CAC&center=true&vCenter=true&width=520&lines=Built+for+a+fast%2C+minimal%2C+reproducible+Wayland+workflow.;%F0%9F%8C%BB+Sunflower%3A+plant+once%2C+bloom+everywhere." alt="Sunflower footer" />

</div>
