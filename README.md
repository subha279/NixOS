# ❄️ Aurora NixOS

> My personal **NixOS + Hyprland** configuration — focused on a clean, fast, keyboard-driven Wayland desktop and a practical development environment.

## ✦ Stack

- **NixOS** + Flakes
- **Home Manager**
- **Hyprland** · Wayland
- **Quickshell** · Desktop shell
- **Stylix + Wallust** · Dynamic theming
- **awww** · Wallpapers
- **Fuzzel** · Launcher
- **Kitty** · Terminal
- **Neovim** · Development
- **Zsh + Starship** · Shell

## 📁 Structure

```text
NixOS/
├── hosts/       # Machine-specific configuration
├── modules/     # System-wide NixOS modules
├── home/        # Home Manager configuration
├── lib/         # Shared variables
├── scripts/     # Maintenance & validation
├── flake.nix
└── README.md
```

## ⌨️ Keybindings

**MOD = Super / Windows key**

### 🪟 Hyprland

| Key | Action |
|---|---|
| `MOD + T` | Terminal |
| `MOD + E` | File manager |
| `MOD + B` | Browser |
| `MOD + A` | Application launcher |
| `MOD + P` | Wallpaper picker |
| `MOD + I` | Quickshell settings |
| `MOD + Q` | Close window |
| `MOD + X` | Exit Hyprland |
| `MOD + SHIFT + S` | Screenshot |
| `MOD + V` | Toggle floating |
| `MOD + J` | Toggle split |
| `MOD + 1–0` | Switch workspace |
| `MOD + SHIFT + 1–0` | Move window to workspace |
| `MOD + Arrow` | Move focus |

### 🚀 Fuzzel

| Key | Action |
|---|---|
| `MOD + A` | Open launcher |
| `↑ / ↓` | Select application |
| `Enter` | Launch |
| `Esc` | Close |

### 🧠 Neovim

**Leader = Space**

| Key | Action |
|---|---|
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Buffers |
| `<leader>fr` | Recent files |
| `<leader>fd` | Diagnostics |
| `<leader>e` | File explorer |
| `gd` | Go to definition |
| `gr` | Find references |
| `K` | Hover documentation |
| `<leader>lr` | Rename |
| `<leader>la` | Code action |
| `<leader>xx` | Diagnostics |
| `<leader>bn` | Next buffer |
| `<leader>bp` | Previous buffer |

### 🐚 Zsh

| Command | Action |
|---|---|
| `ls` | `eza` |
| `ll` | Detailed listing |
| `la` | Show hidden files |
| `lt` | Tree listing |
| `v` | Open Neovim |
| `..` | Go to parent directory |

### 💻 Kitty

| Key | Action |
|---|---|
| `Ctrl + Shift + Enter` | New window |
| `Ctrl + Shift + T` | New tab |
| `Ctrl + Shift + W` | Close window |
| `Ctrl + Shift + Q` | Quit |
| `Ctrl + Shift + [` | Previous tab |
| `Ctrl + Shift + ]` | Next tab |

> Kitty keybindings may vary with the active Kitty configuration.

## 🛠️ Validation

Check the configuration before rebuilding:

```bash
./scripts/check.sh
```

Rebuild:

```bash
sudo nixos-rebuild switch --flake .#laptop
```
## ⚠️ Hardware

`hosts/laptop/hardware-configuration.nix` is specific to my laptop and should be regenerated when adapting this configuration to different hardware.

---

<div align="center">

**❄️ NixOS · Hyprland · Wayland · Neovim**

</div>
