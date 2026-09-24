<div align="center">

<img src="https://readme-typing-svg.herokuapp.com?font=JetBrains+Mono&weight=600&size=44&pause=1200&color=CBA6F7&center=true&vCenter=true&width=620&lines=%F0%9F%8C%BB+Sunflower" alt="Sunflower" />

# Sunflower

### A declarative, keyboard-driven Sunflower desktop

**Hyprland** · **Quickshell** · **Sunflower themes** · **Home Manager**

<p>
  <a href="https://github.com/subha279/Sunflower">
    <img src="https://img.shields.io/badge/Sunflower-desktop-C792EA?style=for-the-badge&logo=sunrise&logoColor=white" alt="Sunflower desktop">
  </a>
  <a href="https://github.com/subha279/Sunflower">
    <img src="https://img.shields.io/badge/nixpkgs-26.05-7E7DFF?style=for-the-badge&logo=nixos&logoColor=white" alt="nixpkgs 26.05 base">
  </a>
  <a href="https://github.com/subha279/Sunflower">
    <img src="https://img.shields.io/badge/Hyprland-Lua-58E1FF?style=for-the-badge" alt="Hyprland Lua">
  </a>
  <a href="https://github.com/subha279/Sunflower">
    <img src="https://img.shields.io/badge/Quickshell-QML-BB86FC?style=for-the-badge" alt="Quickshell QML">
  </a>
</p>

<p>
  <a href="#showcase">Showcase</a> ·
  <a href="#features">Features</a> ·
  <a href="#installation">Installation</a> ·
  <a href="#architecture">Architecture</a> ·
  <a href="#theme-system">Theme system</a> ·
  <a href="#components">Components</a> ·
  <a href="#customization">Customization</a> ·
  <a href="#useful-commands">Commands</a>
</p>

</div>

---

## Showcase

Video tour of the desktop:

<p align="center">
  <a href="https://www.youtube.com/watch?v=J9286xiVBNk">
    <img src="https://img.youtube.com/vi/J9286xiVBNk/maxresdefault.jpg"
         alt="Sunflower desktop showcase"
         width="720">
  </a>
</p>

No screenshots are shipped in this repository; the video above is the visual reference.

---

## Features

**Desktop**

- Hyprland composed in Lua (`hyprland.lua` + one module per concern under `home/hyprland/config/`)
- Quickshell replaces the bar/launcher/notification daemons with a single QML shell (`home/quickshell/config/`)
- App launcher, theme picker, wallpaper picker, clipboard history and emoji picker as Quickshell IPC surfaces, all on `SUPER` chords
- Monotonic compositor animations; layer surfaces animate once, in the compositor
- Managed wallpaper state (`~/.cache/sunflower/current-wallpaper`) restored at login via `restore-wallpaper.sh` on top of `awww`

**Theme**

- Centralized Sunflower engine: one palette per theme in `lib/colorschemes/`, generated out to Lua, JSON, Kitty, tmux, Starship, GTK and Kvantum
- Runtime switching with `SUPER + C` — no rebuild; Kitty sockets repaint, tmux re-sources, Hyprland reloads
- 7 themes: `catppuccin-mocha` (active default), `tokyo-night`, `gruvbox`, `one-dark`, `everforest`, `rose-pine`, `kanagawa`
- Stylix provides the base16 scheme, system fonts, cursor and sizes; `autoEnable` is off and GTK/Qt targets are disabled

**Terminal and editor**

- Kitty (theme include reads the generated `active-kitty.conf`), Zsh with Starship prompt (config path exported to the generated `active-starship.toml`), tmux (sources `active-tmux.conf` first), fzf and zoxide integration
- Neovim with Treesitter, completion, Telescope, formatting/lint plugins and 18 language-server configs under `home/neovim/config/lsp/`, highlighted through the Sunflower palette

**System**

- Flake-based host (`nixosConfigurations.sunflower`), 24 system modules, 13 Home Manager modules
- One manager script (`setup.sh`, v1.0): install, upgrade, rebuild, validate, maintain, roll back, verify boot — with preflight checks, timestamped backups and confirmations on destructive steps
- Fonts: JetBrainsMono Nerd Font as terminal face plus Iosevka, Caskaydia Cove, Fira Code, SF Mono Nerd, Comic Shanns Mono, Maple Mono and Inter, with Noto family and color emoji coverage

---

## Installation

Prerequisites: the NixOS installer ISO (all partitioning and install tooling is expected from that environment) and a network connection for the binary cache.

```bash
git clone https://github.com/subha279/Sunflower.git ~/Sunflower
cd ~/Sunflower
./setup.sh
```

What happens next:

1. `./setup.sh` opens the interactive manager; option `1` starts the clean installer on the ISO, or the identity pass on an installed system.
2. Identity (Linux user, full name, hostname, Git user/email, timezone, locale) is collected up front and written to `lib/variables.nix` — never passwords; those are set interactively via `passwd`.
3. The installer partitions (1 GiB ESP + ext4 root), generates `hosts/sunflower/hardware-configuration.nix` against `/mnt`, validates the flake, builds the `.#sunflower` closure into the target store and installs it.
4. Reboot into GRUB, then the newest generation.

Non-interactive surface: every menu action also exists as `./setup.sh <command>` (see Commands).

---

## Architecture

```text
flake.nix (.#sunflower)
│
├─ hosts/sunflower ───────── host entry + generated hardware-configuration.nix
├─ modules/* (24) ────────── system: boot, networking, audio, graphics,
│                             nvidia, desktop, session, stylix, …
└─ home/* (13, Home Manager) ─ hyprland, quickshell, theme, neovim,
                               zsh, kitty, tmux, git, ssh, …

lib/variables.nix ── identity + hardware IDs (single source of truth)
lib/themes.nix ─┬── global.activeTheme ──► home/theme generators
                │                            ├─ active-theme / themes/*.json + *.lua
lib/colorschemes/                            ├─ active-kitty.conf / active-tmux.conf
(7 palettes)                                 ├─ active-starship.toml
                                             └─ GTK / Kvantum assets
                                                        │
              ┌─────────────────────────────────────────┘
              ▼
 Hyprland ◄── active-theme.lua      Quickshell ◄── themes/*.json
 Kitty ◄───── active-kitty.conf     tmux ◄────── active-tmux.conf
 Starship ◄── active-starship.toml  Neovim ◄──── sunflower.theme (lua)
```

`setup.sh` never configures applications directly. It bootstraps identity and hardware, then orchestrates `nix` / `nixos-rebuild` / `nixos-install`; everything else lives in Nix.

---

## Theme system

Centralized in two files plus one directory:

- `lib/themes.nix` — global settings (active theme, fonts, icons, cursor, UI metrics) and auto-loading of every palette in `lib/colorschemes/`
- `lib/colorschemes/*.nix` — one file per theme, same schema
- `home/theme/` — generators (`generators/`: data, kitty, tmux, starship, gtk, kvantum) plus `activation.nix` and the `sunflower-theme` switcher script

Switching writes `~/.config/sunflower/active-theme` (and the per-target `active-*` files); every consumer re-reads at runtime, which is why no rebuild is needed. Stylix stays responsible for the base16 scheme, fonts, cursor and fontconfig only.

| Change this | Effect |
|---|---|
| `global.activeTheme` in `lib/themes.nix` | Default theme after rebuild |
| Add/edit a file in `lib/colorschemes/` | New/changed palette everywhere once generated |
| `SUPER + C` at runtime | Immediate switch, no rebuild |

---

## Components

| Component | Location | Controls |
|---|---|---|
| Host | `hosts/sunflower/` | Imports, hardware config, hostname wiring |
| System modules | `modules/` | Boot, networking, users, packages, fonts, audio, bluetooth, graphics, nvidia, desktop, session, xdg, notifications, hyprland, power, polkit, monitoring, development, ai, creator, virtualisation, stylix, `hardware/kreo-rgb` |
| Hyprland | `home/hyprland/` | `hyprland.lua` entry; `config/` modules (variables, keybinds, monitors, rules, animation, decoration, layout, input, env, theme, startup); `scripts/restore-wallpaper.sh` |
| Quickshell | `home/quickshell/config/` | `shell.qml`; `core/` (theme, icons, popups); `services/` (apps, wallpaper, theme, audio, network…); `components/`; `modules/` (bar, launchers, pickers, notifications…) |
| Theme engine | `home/theme/` | Generators, activation, `scripts/sunflower-theme` |
| Neovim | `home/neovim/` | `default.nix` plugin/tool declarations; `config/` Lua + 18 LSP server configs |
| Shell/terminal | `home/zsh/`, `home/kitty/`, `home/tmux/` | Aliases, completion, history, keybindings, fzf/zoxide/starship wiring; Kitty + tmux configs that source generated theme files |
| Identity | `lib/variables.nix` | Username, display name, Git identity, hostname, timezone, locale, NVIDIA bus IDs |
| Manager | `setup.sh` | Install, upgrade, rebuild, validate, maintain, rollback, verify |

---

## Structure

```text
Sunflower/
├── flake.nix
├── hosts/sunflower/
├── modules/            # core boot networking users packages fonts audio
│                       # bluetooth polkit graphics xdg notifications hyprland
│                       # desktop session monitoring nvidia power stylix
│                       # development ai creator virtualisation hardware/kreo-rgb
├── home/               # hyprland quickshell theme neovim zsh kitty tmux
│                       # git ssh xdg fastfetch obsidian mpv
├── lib/                # variables.nix themes.nix colorschemes/
└── setup.sh
```

---

## Customization

| Target | Edit | Apply |
|---|---|---|
| Themes | `lib/themes.nix` (`global.activeTheme`), palettes in `lib/colorschemes/` | `SUPER + C` at runtime; rebuild for a new default |
| Fonts | Packages in `modules/fonts/default.nix`; faces in `lib/themes.nix` (`global.fonts`) | Rebuild |
| Hyprland | `home/hyprland/config/` (`keybinds.lua`, `variables.lua`, …) | Rebuild, then `hyprctl reload` for runtime-only tweaks |
| Quickshell | `home/quickshell/config/` (QML + services) | Rebuild, then `systemctl --user restart quickshell` |
| Terminal | `home/kitty/config/kitty.conf` (+ generated `active-kitty.conf`) | Rebuild |
| Shell | `home/zsh/` (`aliases.nix`, `keybindings.nix`, `shell.nix`, …) | Rebuild (new login shell) |
| Editor | `home/neovim/config/` (Lua, plugins, `lsp/`) | Rebuild |
| Applications | `modules/desktop/applications.nix` | Rebuild |
| Identity | `lib/variables.nix` (or `./setup.sh configure`) | Rebuild |

Keybinds reference shared variables (`home/hyprland/config/variables.lua`: `SUPER`/`ALT`, terminal `kitty`, browser `zen`, `qs ipc call …` pickers), so one edit propagates to every binding.

---

## Useful commands

All of these map to `./setup.sh` actions (run from the repo root):

```bash
./setup.sh check        # nix flake check
./setup.sh dry          # nixos-rebuild dry-build --flake .#sunflower
./setup.sh rebuild      # validate, then nixos-rebuild switch --flake .#sunflower
./setup.sh update       # git pull --ff-only + nix flake update (+ optional rebuild)
./setup.sh validate     # full configuration validator
./setup.sh maintain     # maintenance dashboard (generations, GC, verify)
./setup.sh rollback     # switch --rollback
./setup.sh generations  # list system generations
./setup.sh gc           # garbage collection
```

Safe order: `check` → `dry` → `rebuild` → verify the new generation. There is no repository-level formatter command; Lua is formatted inside Neovim via its formatter plugin.

---

## Philosophy

- One declarative source of truth: identity in `lib/variables.nix`, palettes in `lib/colorschemes/`, nothing duplicated across modules.
- Runtime over rebuilds: anything that can re-read (theme, wallpaper, shell surfaces) does, so the desktop changes without reactivating the system.
- Verify before mutating: flake check and dry-build gate rebuilds; installers verify UUIDs, bootloader and UEFI entries before reporting success; destructive steps confirm and back up first.
- Keyboard-first: launcher, pickers, workspaces and media all resolve to short chords defined once in `variables.lua`.

---

## Credits

- [NixOS / nixpkgs](https://nixos.org) (`nixos-26.05`) — base system and package set
- [Home Manager](https://github.com/nix-community/home-manager) (`release-26.05`) — user environment
- [Hyprland](https://hyprland.org) — Wayland compositor, driven here in Lua
- [Quickshell](https://quickshell.org) — QML desktop shell
- [Stylix](https://github.com/danth/stylix) (`release-26.05`) — base16 scheme, system fonts, cursor, fontconfig
- [Zen Browser](https://github.com/youwen5/zen-browser-flake) — default browser package
- [Apple Fonts](https://github.com/Lyndeno/apple-fonts.nix) — overlay-provided fonts
- [Kitty](https://sw.kovidgoyal.net/kitty/), [Neovim](https://neovim.io), [tmux](https://github.com/tmux/tmux), [Starship](https://starship.rs) — terminal stack
- [awww](https://github.com/lyghxht/awww) — animated wallpaper daemon behind the wallpaper picker and restore script

---

<div align="center">

<sub>Sunflower: plant once, bloom everywhere.</sub>

</div>
