╭──────────────────────────────────────────────────────────────────────────╮
│ │
│ ███████╗██╗ ██╗██████╗ ██╗ ██╗ █████╗ ██████╗ ███████╗ │
│ ██╔════╝██║ ██║██╔══██╗██║ ██║██╔══██╗██╔═══██╗██╔════╝ │
│ ███████╗██║ ██║██████╔╝███████║███████║██║ ██║███████╗ │
│ ╚════██║██║ ██║██╔══██╗██╔══██║██╔══██║██║ ██║╚════██║ │
│ ███████║╚██████╔╝██████╔╝██║ ██║██║ ██║╚██████╔╝███████║ │
│ ╚══════╝ ╚═════╝ ╚═════╝ ╚═╝ ╚═╝╚═╝ ╚═╝ ╚═════╝ ╚══════╝ │
│ a beautiful, functional Linux dotfiles │
│ │
╰──────────────────────────────────────────────────────────────────────────╯

A fully declarative **[NixOS](https://nixos.org)** + **[Home Manager](https://github.com/nix-community/home-manager)** setup powered by **[Stylix](https://github.com/danth/stylix)**, with the [Hyprland](https://hyprland.org) Wayland compositor, a custom [Quickshell](https://quickshell.outfoxxed.de) desktop shell, and an "Aurora" themed [Neovim](https://neovim.io) — all wallpaper color-synced by **[Wallust](https://github.com/explosion-mental/wallust)**.

> _Flake description: "Subha's NixOS Configuration" — username: `subha279`_

---

## Table of Contents

- [Features](#-features)
- [Directory Structure](#-directory-structure)
- [Hosts](#-hosts)
- [System Core](#-system-core)
- [Desktop & Theming](#-desktop--theming)
- [Installed Programs](#-installed-programs)
- [Keybindings](#-keybindings)
  - [Hyprland](#hyprland)
  - [Neovim](#neovim)
  - [Zsh](#zsh)
- [Neovim Deep Dive](#-neovim-deep-dive)
- [Scripts](#-scripts)
- [Usage](#-usage)
- [Theming Pipeline](#-theming-pipeline)

---

## ✦ Features

- **Flake-based** NixOS + Home Manager in a single repository, two host configurations
- **Hyprland** on Wayland with a Lua-driven config (`hyprland.lua`)
- **Quickshell** "Aurora" status bar — pill-shaped glass top bar with volume, brightness, clock, network, bluetooth and tray
- **Fuzzel** launcher with wallpaper previews and glass blur
- **Sticky wallpaper theming** — pick a wallpaper, `awww` + `wallust` re-theme **Hyprland, Kitty, Starship and Fuzzel** live
- **Stylix** dark polarity with automatic GTK/Qt theming
- **Neovim** with 16 LSP servers, Treesitter, blink.cmp completion, Conform/Lint pipelines, custom "Aurora" colorscheme
- **NVIDIA PRIME offload** support for the laptop
- **Utility scripts** — config validator (`check.sh`) and an interactive maintenance dashboard (`cleanup.sh`)

---

## 📁 Directory Structure

```
NixOS/
├── flake.nix                  # Flake entrypoint, inputs (nixpkgs, home-manager, stylix)
├── flake.lock
├── lib/
│   └── variables.nix          # Shared variables (user, email, host, timezone, locale)
├── hosts/
│   ├── laptop/                # Host: "subha" with NVIDIA, power, development
│   │   ├── default.nix
│   │   └── hardware-configuration.nix
│   └── vm/                    # Host: "vm" (minimal desktop)
│       ├── default.nix
│       └── hardware-configuration.nix
├── modules/                   # System-level NixOS modules
│   ├── audio/ bluetooth/ boot/ core/ creator/ desktop/ development/
│   ├── fonts/ graphics/ hyprland/ monitoring/ networking/ nvidia/
│   ├── packages/ polkit/ power/ session/ stylix/ users/ xdg/
├── home/                      # Home Manager user configuration
│   ├── default.nix
│   ├── fastfetch/ fuzzel/ git/ hyprland/ kitty/ neovim/
│   ├── quickshell/ ssh/ theme/ xdg/ zsh/
└── scripts/
    ├── check.sh               # NixOS configuration validator
    └── cleanup.sh             # Interactive maintenance dashboard
```

---

## 🖥️ Hosts

| Host     | Hostname | Description                                                       |
| -------- | -------- | ----------------------------------------------------------------- |
| `laptop` | `subha`  | Full desktop: NVIDIA PRIME, power management, dev + creator stack |
| `vm`     | —        | Minimal desktop: core + Hyprland + Stylix + monitoring            |

**Laptop hardware** (from `hardware-configuration.nix`):

- Intel CPU (`kvm-intel` kernel module), NVIDIA GPU via **PRIME offload** (`intelBusId PCI:0@0:2:0`, `nvidiaBusId PCI:1@0:0:0`, open kernel modules)
- ext4 root, vfat `/boot`, x86_64-linux

---

## 🧠 System Core

| Setting         | Value                      |
| --------------- | -------------------------- |
| OS              | NixOS 26.05 (stateVersion) |
| Nix features    | `nix-command`, `flakes`    |
| Unfree packages | allowed                    |
| Timezone        | `Asia/Kolkata`             |
| Locale          | `en_US.UTF-8`              |
| Console keymap  | `us`                       |
| Bootloader      | GRUB + EFI                 |
| Default shell   | Zsh (for user `subha`)     |
| Sudo            | enabled                    |
| User groups     | `wheel`, `networkmanager`  |

**System services**

- `networkmanager` + openssh (firewall opened, root login disabled)
- PipeWire (Pulse + ALSA + JACK) with rtkit
- Bluetooth with Blueman, power-on at boot
- `gvfs`, `udisks2`, polkit, `power-profiles-daemon`, `upower`, WiFi powersave
- XDG Desktop Portals (`gtk`, `hyprland`)

---

## 🎨 Desktop & Theming

### Stylix theme

| Aspect   | Choice                                    |
| -------- | ----------------------------------------- |
| Polarity | `dark`                                    |
| Mono     | JetBrains Mono Nerd Font                  |
| Sans     | Inter                                     |
| Serif    | Noto Sans                                 |
| Emoji    | Noto Color Emoji                          |
| Cursor   | Bibata-Modern-Classic (size 24)           |
| Icons    | Papirus-Dark / Papirus                    |
| Targets  | GTK + Qt auto-themed                      |
| Source   | Generated live from the current wallpaper |

### Hyprland

- **Lua configuration** split into modules (`env`, `monitor`, `theme`, `general`, `decoration`, `animation`, `input`, `layout`, `windowrules`, `layerules`, `startup`, `keybinds`, `misc`)
- Dwindle layout, no borders, `border_size 0`, gaps 2/10, 10px rounded corners (power 2)
- Glass look: blur (5 passes, xray), soft shadows, inactive window dimming
- Butter-smooth bezier animations (easeOutQuint, bounce, overshot…) — `preserve_split`, master layout, scrolling layout pre-configured
- Touchpad tuned (natural scroll, tap-to-click, palm rejection) + 3-finger workspace gesture
- Window rules for Thunar dialogs, Blueman, nm-connection-editor and floating pavucontrol
- Layer rules: glass blur on Fuzzel (`ignore_alpha 0.35`, top order) and the Quickshell bar

### Quickshell — "Aurora" bar

A floating pill-shaped top bar (`aurora-bar` namespace) with rounded modules:
Volume → Brightness → Clock (`HH:mm`) → Network → Bluetooth → System tray, separated by hairlines, with a soft glass shadow, driven by a custom `Theme.qml` singleton (accent `#b58cff` / `#cc16161f` glass backgrounds).

### Terminal — Kitty

- JetBrains Mono Nerd Font 12pt, 85% background opacity + 48px blur
- Powerline **tab bar** (slanted, top-aligned) with per-tab activity indicator
- 10000-line scrollback, `.` from the shell, socket remote control, copy on select
- Colors swapped live on wallpaper change via `kitty.remote` sockets

### Launcher — Fuzzel

`JetBrains Mono Nerd Font:size=11`, 42% width, 14px radius border, Papirus-Dark icons, wallpaper thumbnail previews (`image-size-ratio 0.35`), fully Stylix-colored.

### Shell — Zsh + Starship

- Autosuggestions, syntax highlighting, history substring search, 100k shared history
- **fzf** & **zoxide** shell integration
- Starship prompt that hot-swaps to the wallust-generated config (`~/.cache/wallust/starship.toml`)

### Fastfetch

`config.jsonc` shows: title, OS, host, kernel, uptime, packages, shell, display, DE, WM, theme, icons, font, cursor, terminal, CPU, GPU, memory, swap, disk, local IP, battery, adapter, locale + 16-color swatch.

---

## 📦 Installed Programs

### Desktop

| Category     | Programs                                                                                         |
| ------------ | ------------------------------------------------------------------------------------------------ |
| Browser      | Firefox (Wayland)                                                                                |
| File manager | Thunar + thunar-volman, gvfs, tumbler, ffmpegthumbnailer                                         |
| Archives     | p7zip, unar, file-roller, zip, unzip                                                             |
| Audio        | pavucontrol, PipeWire (Pulse/ALSA/JACK)                                                          |
| Theming      | nwg-look, qt6ct, kvantum                                                                         |
| Network      | networkmanagerapplet                                                                             |
| Screenshot   | grim, slurp, swappy                                                                              |
| Images       | Gwenview                                                                                         |
| Auth         | polkit-kde-agent-1                                                                               |
| Wallpaper    | awww, wallust                                                                                    |
| Launcher     | fuzzel                                                                                           |
| Notify       | libnotify (notify-send)                                                                          |
| Misc         | xdg-utils, cliphist, wl-clipboard, hyprcursor, brightnessctl, playerctl, libinput, wayland-utils |

### Creator

| Program         | Notes                                                 |
| --------------- | ----------------------------------------------------- |
| OBS Studio      | CUDA support enabled                                  |
| DaVinci Resolve | `.desktop` entry with `nvidia-offload` (X11 override) |
| ffmpeg          | Full multimedia suite                                 |
| VLC             | Video player                                          |
| LibreOffice     | `libreoffice-fresh`                                   |
| GIMP            | Image editing                                         |
| Blender         | 3D creation                                           |

### Development

| Stack             | Tools                                                    |
| ----------------- | -------------------------------------------------------- |
| C / C++           | gcc, clang, gnumake, cmake, pkg-config, gdb, clang-tools |
| Rust              | rustc, cargo, rustfmt, clippy, rust-analyzer             |
| JavaScript / Node | nodejs, pnpm, typescript-language-server                 |
| Python            | python3, pyright, ruff                                   |
| Containers        | podman, podman-compose                                   |
| Git               | git, git-lfs, gitsigns / lazygit in nvim                 |
| Shell             | shellcheck, shfmt, bash-language-server                  |
| Debugging         | strace, lldb, gdb                                        |
| Docs              | man-pages, man-pages-posix                               |
| Enhancement       | opencode (AI coding CLI)                                 |

### Monitoring

`btop`, `htop`, `iotop`, `iftop`, `lsof`, `lm_sensors`, `pciutils`, `usbutils`

### CLI (zsh)

| Tool     | Purpose        |
| -------- | -------------- |
| bat      | better `cat`   |
| eza      | better `ls`    |
| fd       | better `find`  |
| fzf      | fuzzy finder   |
| rg       | better `grep`  |
| jq       | JSON processor |
| zoxide   | smart `cd`     |
| starship | prompt         |

### Core utilities

`git`, `curl`, `wget`, `tree`, `file`, `which`, `killall`

---

## ⌨️ Keybindings

### Hyprland

> `MOD` = **SUPER** (⊞ Windows key)

**Applications & shortcuts**

| Keys              | Action                                     |
| ----------------- | ------------------------------------------ |
| `MOD + T`         | Launch terminal (Kitty)                    |
| `MOD + E`         | Launch file manager (Thunar)               |
| `MOD + B`         | Launch browser (Firefox)                   |
| `MOD + A`         | Open launcher (Fuzzel)                     |
| `MOD + I`         | Toggle Quickshell settings (IPC)           |
| `MOD + P`         | Wallpaper picker (fuzzel + wallust + awww) |
| `MOD + Q`         | Close focused window                       |
| `MOD + X`         | Exit / shutdown Hyprland                   |
| `MOD + SHIFT + S` | Screenshot region (grim + slurp + swappy)  |
| `MOD + V`         | Toggle floating window                     |
| `MOD + J`         | Toggle split layout                        |

**Focus & workspaces**

| Keys                      | Action                        |
| ------------------------- | ----------------------------- |
| `MOD + ← ↑ → ↓`           | Move focus by direction       |
| `MOD + 1` … `MOD + 0`     | Focus workspace 1–10          |
| `MOD + SHIFT + 1` … `+ 0` | Move window to workspace 1–10 |
| `MOD + scroll down / up`  | Next / previous workspace     |
| `MOD + left click drag`   | Move / drag window            |
| `MOD + right click drag`  | Resize window                 |

**Hardware keys** (locked, repeat-enabled)

| Keys                                        | Action                      |
| ------------------------------------------- | --------------------------- |
| `XF86AudioRaiseVolume` / `LowerVolume`      | Volume +5% / −5% (`wpctl`)  |
| `XF86AudioMute`                             | Toggle speaker mute         |
| `XF86AudioMicMute`                          | Toggle mic mute             |
| `XF86MonBrightnessUp` / `Down`              | Brightness +5% / −5%        |
| `XF86AudioNext` / `Prev` / `Play` / `Pause` | Media control (`playerctl`) |

### Neovim

> Leader = **Space**

**General**

| Keys                 | Action                     |
| -------------------- | -------------------------- |
| `Esc`                | Clear search highlight     |
| `C-d` / `C-u`        | Half-page scroll, centered |
| `n` / `N`            | Next/prev search, centered |
| `<` / `>` (visual)   | Re-indent, keep selection  |
| `J` / `K` (visual)   | Move lines up/down         |
| `<leader>p` (visual) | Paste without yanking      |
| `<leader>dd`         | Delete without yanking     |

**Buffers**

| Keys         | Action                  |
| ------------ | ----------------------- |
| `<leader>bn` | Next buffer             |
| `<leader>bp` | Previous buffer         |
| `<leader>bd` | Delete buffer           |
| `<leader>bb` | Buffer list (Telescope) |

**Windows**

| Keys                          | Action                |
| ----------------------------- | --------------------- |
| `C-h` / `C-j` / `C-k` / `C-l` | Navigate windows      |
| `<leader>ws`                  | Horizontal split      |
| `<leader>wv`                  | Vertical split        |
| `<leader>wc`                  | Close window          |
| `<leader>we`                  | Equalize window sizes |
| `C-↑/↓`                       | Resize height ±2      |
| `C-←/→`                       | Resize width ±2       |

**Tabs**

| Keys         | Action       |
| ------------ | ------------ |
| `<leader>tn` | New tab      |
| `<leader>tc` | Close tab    |
| `<leader>tl` | Next tab     |
| `<leader>th` | Previous tab |

**Terminal**

| Keys                   | Action              |
| ---------------------- | ------------------- |
| `<leader>tt`           | Open terminal split |
| `Esc Esc` (terminal)   | Exit insert mode    |
| `C-h/j/k/l` (terminal) | Navigate windows    |

**Telescope (find)**

| Keys         | Action            |
| ------------ | ----------------- |
| `<leader>ff` | Find files        |
| `<leader>fg` | Live grep         |
| `<leader>fb` | Buffers           |
| `<leader>fh` | Help tags         |
| `<leader>fr` | Recent files      |
| `<leader>fc` | Commands          |
| `<leader>fk` | Keymaps           |
| `<leader>fs` | Document symbols  |
| `<leader>fS` | Workspace symbols |
| `<leader>fd` | Diagnostics       |

**Explorer (NvimTree)**

| Keys            | Action                           |
| --------------- | -------------------------------- |
| `<leader>e`     | Toggle explorer                  |
| `<leader>E`     | Focus explorer                   |
| `<leader>ef`    | Reveal current file              |
| `<leader>ec`    | Collapse all                     |
| `<leader>er`    | Refresh                          |
| `l` / `Enter`   | Open file / folder (tree)        |
| `h`             | Close folder                     |
| `s` / `i`       | Open vertical / horizontal split |
| `P`             | Preview                          |
| `a` / `r` / `d` | Create / rename / delete         |
| `c` / `x` / `p` | Copy / cut / paste               |
| `R` / `u` / `.` | Refresh / parent / set root      |

**LSP**

| Keys         | Action                     |
| ------------ | -------------------------- |
| `gd` / `gD`  | Definition / declaration   |
| `gi`         | Implementation             |
| `gr`         | References                 |
| `gt`         | Type definition            |
| `K`          | Hover documentation        |
| `C-k`        | Signature help             |
| `<leader>lr` | Rename                     |
| `<leader>la` | Code actions               |
| `<leader>ld` | Line diagnostics (float)   |
| `[d` / `]d`  | Previous / next diagnostic |
| `<leader>lh` | Toggle inlay hints         |

**Git (gitsigns)**

| Keys         | Action                 |
| ------------ | ---------------------- |
| `]g` / `[g`  | Next / previous hunk   |
| `<leader>gh` | Preview hunk           |
| `<leader>gb` | Blame line             |
| `<leader>gd` | Diff                   |
| `<leader>gr` | Reset hunk             |
| `<leader>gS` | Stage hunk / selection |
| `<leader>gf` | Format (conform)       |
| `<leader>lg` | LazyGit (snacks)       |

**Diagnostics (trouble)**

| Keys         | Action             |
| ------------ | ------------------ |
| `<leader>xx` | Toggle diagnostics |
| `<leader>xX` | Buffer diagnostics |
| `<leader>xs` | Symbols            |
| `<leader>xl` | Location list      |
| `<leader>xq` | Quickfix list      |

**Quickfix**

| Keys         | Action         |
| ------------ | -------------- |
| `<leader>co` | Open quickfix  |
| `<leader>cc` | Close quickfix |
| `<leader>cn` | Next item      |
| `<leader>cp` | Previous item  |

**History, help & completion**

| Keys            | Action                     |
| --------------- | -------------------------- |
| `<leader>:`     | Command history            |
| `<leader>/`     | Search history             |
| `<leader>hh`    | Help (Telescope)           |
| `C-space`       | Show completion / docs     |
| `C-e`           | Hide completion            |
| `Enter`         | Accept completion          |
| `Tab` / `S-Tab` | Next / previous completion |

**Dashboard** (`[f]` Find File, `[r]` Recent, `[g]` Grep, `[n]` New File, `[c]` Config, `[q]` Quit)

### Zsh

| Alias | Command      |
| ----- | ------------ |
| `ls`  | `eza`        |
| `ll`  | `eza -lah`   |
| `la`  | `eza -a`     |
| `lt`  | `eza --tree` |
| `v`   | `nvim`       |
| `c`   | `clear`      |
| `..`  | `cd ../`     |

---

## 🐉 Neovim Deep Dive

**Plugins**

| Plugin          | Role                                       |
| --------------- | ------------------------------------------ |
| blink.cmp       | Completion (LSP/path/buffer)               |
| nvim-lspconfig  | LSP management                             |
| nvim-treesitter | Syntax (all grammars)                      |
| telescope-nvim  | Fuzzy search                               |
| gitsigns-nvim   | Git signs + hunk ops                       |
| conform-nvim    | Format-on-save (per filetype)              |
| nvim-lint       | Lint-on-write (ruff, eslint_d, shellcheck) |
| trouble-nvim    | Diagnostics UI                             |
| which-key-nvim  | Keymap guides (modern preset)              |
| lualine-nvim    | Custom "Aurora" statusline                 |
| snacks-nvim     | Bigfile, notifier, lazygit…                |
| nvim-tree-lua   | File explorer (nerd glyphs)                |

**16 LSP servers** — lua_ls, rust-analyzer (full inlay hints), ts_ls, pyright, clangd, nixd, bashls, jsonls, html, cssls, eslint, yamlls, marksman, tailwindcss, dockerls, taplo

**Formatters** — stylua, rustfmt, ruff_format, prettier, nixfmt, shfmt, taplo, clang_format

**Linters** — ruff, eslint_d, shellcheck

Custom **Aurora** colorscheme (`colors/aurora.lua`) — purple/violet/blue/cyan palette with `#CBA6F7` accents; a matching `aurora-forest` and `aurora-frost` variant are also included.

---

## 🔧 Scripts

| Script       | Purpose                                                                                                                                                                   |
| ------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `check.sh`   | Validates the repo: git, `nix flake check`, Nix syntax, required files, Neovim config load + Lua parse, Quickshell/Hyprland health, declared plugins & LSP tools          |
| `cleanup.sh` | Interactive maintenance dashboard: flake check → dry-build → generation cleanup (keeps 5) → GC → store optimize/verify, systemd health, store usage — all via an fzf menu |

---

## 🚀 Usage

```bash
# Validate everything before rebuilding
./scripts/check.sh

# Rebuild the laptop
sudo nixos-rebuild switch --flake .#laptop

# Rebuild the VM
sudo nixos-rebuild switch --flake .#vm

# Switch only Home Manager parts
home-manager switch --flake .#subha

# Maintenance dashboard
./scripts/cleanup.sh
```

---

## 🎨 Theming Pipeline

1. `MOD + P` → fuzzel menu of `~/Wallpapers`
2. `wallust run <image>` regenerates palettes from the wallpaper
3. `awww img` crossfades the wallpaper with a grow transition
4. Kitty terminals get live-recolored over their Unix sockets
5. Kitty, Starship, Fuzzel and Hyprland all hot-swap to the new colors
6. `restore-wallpaper.sh` restores everything on next login

---

Made with ❤ and flakes — **Subha**.
