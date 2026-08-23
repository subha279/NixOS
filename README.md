# Aurora

NixOS configuration. Flake-based, Hyprland on Wayland, with a Quickshell
desktop shell and Stylix-driven theming across every application.

|             |                                      |
| ----------- | ------------------------------------ |
| Host        | `laptop` — `x86_64-linux`            |
| Channel     | `nixos-26.05`                        |
| Compositor  | Hyprland, configured in **Lua**      |
| Shell / bar | Quickshell                           |
| Theming     | Stylix — 21 themes, active: `aurora` |
| Terminal    | Kitty · Zsh                          |
| Editor      | Neovim (17 LSPs)                     |

---

## Rebuild

```sh
cd ~/NixOS
sudo nixos-rebuild switch --flake .#laptop
```

Other common operations:

```sh
nix flake check                 # evaluate without building
nix flake update                # bump all inputs
sudo nixos-rebuild test --flake .#laptop     # apply without a boot entry
sudo nixos-rebuild boot --flake .#laptop     # apply on next boot only
```

After changing only Quickshell or Hyprland files you usually don't need a full
rebuild — see [Reloading without a rebuild](#reloading-without-a-rebuild).

---

## Layout

```
NixOS/
├── flake.nix              Inputs and the laptop host output
├── hosts/laptop/          Host entry point + hardware-configuration.nix
├── modules/               System-level NixOS modules
├── home/                  Home Manager modules and dotfiles
├── lib/                   Shared values: identity + theme definitions
└── scripts/               check.sh, cleanup.sh
```

---

## System modules

All imported from `hosts/laptop/default.nix`.

| Module           | Purpose                                                              |
| ---------------- | -------------------------------------------------------------------- |
| `core`           | Nix settings, garbage collection, locale, timezone                   |
| `boot`           | GRUB, systemd initrd, quiet boot, 1s menu timeout                    |
| `networking`     | NetworkManager                                                       |
| `users`          | Account, Zsh, sudo                                                   |
| `packages`       | Base system package set                                              |
| `fonts`          | Font packages including Apple fonts overlay                          |
| `audio`          | PipeWire, WirePlumber, rtkit                                         |
| `bluetooth`      | BlueZ + Blueman, powered on at boot                                  |
| `polkit`         | Polkit authentication agent                                          |
| `graphics`       | Mesa / OpenGL                                                        |
| `nvidia`         | Hybrid Intel + NVIDIA PRIME offload, open kernel module              |
| `xdg`            | XDG base directories and portals                                     |
| `notifications`  | Portal config, dconf, notification plumbing                          |
| `hyprland`       | Compositor package and session                                       |
| `desktop`        | `applications.nix` + `services.nix` — Thunar, gvfs, udisks2, tumbler |
| `session`        | Session variables and targets                                        |
| `monitoring`     | System monitoring tools                                              |
| `power`          | UPower, power management                                             |
| `stylix`         | Global theming engine and per-target settings                        |
| `development`    | Language toolchains and dev tooling                                  |
| `creator`        | Media creation applications                                          |
| `gaming`         | Steam, GameMode                                                      |
| `virtualisation` | libvirt / QEMU                                                       |

---

## Home modules

| Module                           | Contents                                                                          |
| -------------------------------- | --------------------------------------------------------------------------------- |
| `hyprland`                       | `hyprland.lua` entry point + `config/*.lua` + wallpaper script                    |
| `quickshell`                     | Full QML desktop shell, systemd user service, D-Bus activation                    |
| `neovim`                         | `init.lua`, 17 LSP configs, 12 plugin configs, custom theme                       |
| `zsh`                            | Split into aliases, completion, environment, history, keybindings, plugins, shell |
| `kitty`                          | Terminal configuration                                                            |
| `git` · `ssh`                    | Identity and client config, sourced from `lib/variables.nix`                      |
| `theme`                          | Home-level Stylix targets                                                         |
| `fastfetch` · `obsidian` · `xdg` | Misc user configuration                                                           |

---

## Hyprland

Unusually, the compositor is configured in **Lua** rather than `hyprland.conf`.
`hyprland.lua` is the entry point and pulls in each file below via
`require("config.<name>")`. The `hl` global is the Hyprland Lua DSL.

| File                         | Contents                                                               |
| ---------------------------- | ---------------------------------------------------------------------- |
| `variables.lua`              | Modifiers, default applications, command strings — **edit this first** |
| `keybinds.lua`               | All key bindings below                      |
| `monitor.lua`                | Display layout                                                         |
| `windowrules.lua`            | 38 window rules                                                        |
| `layerules.lua`              | 6 layer-surface rules                                                  |
| `animation.lua`              | Bezier curves and animation timings                                    |
| `decoration.lua`             | Rounding, blur, shadows, opacity                                       |
| `general.lua` · `layout.lua` | Gaps, borders, dwindle / master / scrolling                            |
| `input.lua`                  | Keyboard, touchpad, sensitivity                                        |
| `env.lua`                    | Environment variables                                                  |
| `startup.lua`                | Autostart and D-Bus handoff                                            |
| `misc.lua` · `theme.lua`     | Everything else                                                        |

**Regex escaping.** Window and layer rules are Lua strings, so every regex
backslash must be doubled — `^\\.blueman-manager-wrapped$`, not
`^\.blueman-manager-wrapped$`. A single backslash is an invalid Lua escape and
Hyprland will refuse to load the file.

# Keybindings

Every binding defined in `home/hyprland/config/keybinds.lua`, with the variables
from `config/variables.lua` resolved to the actual command.

**Modifiers:** `SUPER` is the main modifier. `ALT` is used only for focus
movement.

---

## Applications

| Keys          | Action       | Command                       |
| ------------- | ------------ | ----------------------------- |
| `SUPER` + `T` | Terminal     | `kitty`                       |
| `SUPER` + `E` | File manager | `thunar`                      |
| `SUPER` + `B` | Browser      | `firefox`                     |
| `SUPER` + `Z` | GUI editor   | `zeditor`                     |
| `SUPER` + `N` | Notes        | `obsidian`                    |
| `SUPER` + `A` | App launcher | `qs ipc call launcher toggle` |

---

## Shell surfaces

These toggle Quickshell surfaces over IPC rather than launching a process.

| Keys          | Action              | Command                        |
| ------------- | ------------------- | ------------------------------ |
| `SUPER` + `A` | App launcher        | `qs ipc call launcher toggle`  |
| `SUPER` + `C` | Colourscheme picker | `qs ipc call theme toggle`     |
| `SUPER` + `P` | Wallpaper picker    | `qs ipc call wallpaper toggle` |

---

## Windows

| Keys                    | Action               |
| ----------------------- | -------------------- |
| `SUPER` + `Q`           | Close focused window |
| `SUPER` + `F`           | Toggle floating      |
| `SUPER` + `Left Mouse`  | Drag window          |
| `SUPER` + `Right Mouse` | Resize window        |

---

## Focus

Vim directions, on `ALT` rather than `SUPER`.

| Keys        | Direction |
| ----------- | --------- |
| `ALT` + `H` | Left      |
| `ALT` + `J` | Down      |
| `ALT` + `K` | Up        |
| `ALT` + `L` | Right     |

---

## Workspaces

| Keys                        | Action                          |
| --------------------------- | ------------------------------- |
| `SUPER` + `1`…`9`           | Switch to workspace 1–9         |
| `SUPER` + `0`               | Switch to workspace **10**      |
| `SUPER` + `SHIFT` + `1`…`9` | Move window to workspace 1–9    |
| `SUPER` + `SHIFT` + `0`     | Move window to workspace **10** |

The loop is `for i = 1, 10` with `key = i % 10`, which is why workspace 10 sits
on the `0` key.

---

## Screenshot

| Keys                    | Action                         |
| ----------------------- | ------------------------------ |
| `SUPER` + `SHIFT` + `S` | Select a region, then annotate |

```sh
grim -g "$(slurp)" - | swappy -f -
```

Drag to select an area; Swappy opens for annotation and saving.

---

## Media keys

All of these are **locked**, meaning they still work on the lock screen.
Volume and brightness also **repeat** when held.

### Audio

| Key                    | Action          | Command                                          |
| ---------------------- | --------------- | ------------------------------------------------ |
| `XF86AudioRaiseVolume` | Volume +5%      | `wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+` |
| `XF86AudioLowerVolume` | Volume −5%      | `wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-`      |
| `XF86AudioMute`        | Mute output     | `wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle`     |
| `XF86AudioMicMute`     | Mute microphone | `wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle`   |

The `-l 1` on volume up caps output at 100% so it can't be pushed into
distortion.

### Brightness

| Key                     | Action         | Command                         |
| ----------------------- | -------------- | ------------------------------- |
| `XF86MonBrightnessUp`   | Brightness +5% | `brightnessctl -e4 -n2 set 5%+` |
| `XF86MonBrightnessDown` | Brightness −5% | `brightnessctl -e4 -n2 set 5%-` |

`-e4` applies a perceptual curve and `-n2` keeps a minimum level so the screen
can never go fully black.

### Playback

| Key              | Action         | Command                |
| ---------------- | -------------- | ---------------------- |
| `XF86AudioPlay`  | Play / pause   | `playerctl play-pause` |
| `XF86AudioPause` | Play / pause   | `playerctl play-pause` |
| `XF86AudioNext`  | Next track     | `playerctl next`       |
| `XF86AudioPrev`  | Previous track | `playerctl previous`   |

---

## Shell aliases

Not keybindings, but the other half of the muscle memory. Defined in
`home/zsh/aliases.nix`.

### Listing — `eza`

| Alias         | Expands to                                     |
| ------------- | ---------------------------------------------- |
| `ls`          | `eza --icons --group-directories-first`        |
| `ll`          | `eza -lah --icons --group-directories-first`   |
| `la`          | `eza -a --icons --group-directories-first`     |
| `lt` / `tree` | `eza --tree --icons --group-directories-first` |

### Navigation

| Alias  | Expands to    |
| ------ | ------------- |
| `..`   | `cd ..`       |
| `...`  | `cd ../..`    |
| `....` | `cd ../../..` |

### Editors

| Alias              | Expands to     |
| ------------------ | -------------- |
| `v` / `vi` / `vim` | `nvim`         |
| `sv`               | `sudo -E nvim` |

### Git

| Alias | Expands to                             |
| ----- | -------------------------------------- |
| `gs`  | `git status`                           |
| `gd`  | `git diff`                             |
| `gl`  | `git log --oneline --graph --decorate` |
| `ga`  | `git add`                              |
| `gc`  | `git commit`                           |
| `gp`  | `git push`                             |
| `gpl` | `git pull --ff-only`                   |

### Utilities

| Alias  | Expands to          |
| ------ | ------------------- |
| `c`    | `clear`             |
| `df`   | `df -h`             |
| `du`   | `du -h`             |
| `diff` | `diff --color=auto` |

---

## Changing a binding

Edit `home/hyprland/config/keybinds.lua`, then:

```sh
hyprctl reload
```

If you're changing _which application_ a key opens, edit
`home/hyprland/config/variables.lua` instead — the bindings reference it, so one
change updates every use.

The binding syntax is:

```lua
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(vars.terminal))
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(vars.volumeMute), { locked = true, repeating = true })
```

| Flag               | Meaning                                                    |
| ------------------ | ---------------------------------------------------------- |
| `locked = true`    | Works while the session is locked                          |
| `repeating = true` | Fires continuously while held                              |
| `mouse = true`     | Binds a mouse button (`mouse:272` left, `mouse:273` right) |

### Displays

| Output     | Configuration                           |
| ---------- | --------------------------------------- |
| `eDP-1`    | Disabled — laptop panel off             |
| `HDMI-A-1` | `1920x1080@180.00301` at `0x0`, scale 1 |

To use the laptop screen again, set `disabled = false` in `monitor.lua` and
uncomment the mode, position and scale lines.

---

## Quickshell

Quickshell replaces the usual Waybar + wofi + dunst stack with a single QML
process. `shell.qml` is the entry point.

```
config/
├── shell.qml       Root — instantiates the bar and every surface
├── core/           Shell.Core module: Theme, Icons, PopupManager, OsdController
├── services/       Shell.Services module: system state singletons
├── components/     Reusable UI: Bar, PopupSurface, LauncherSurface, ListRow…
└── modules/        Bar widgets and popups: Clock, Network, Bluetooth, Volume…
```

**Services** are singletons that own system state and expose it to the UI:
`AppsService`, `AudioService`, `BatteryService`, `BluetoothService`,
`BrightnessService`, `NetworkService`, `NotificationServer`, `ThemeService`,
`WallpaperService`.

### IPC

Three surfaces are toggled from Hyprland keybinds rather than launched:

```sh
qs ipc call launcher toggle     # SUPER + A
qs ipc call theme toggle        # SUPER + C
qs ipc call wallpaper toggle    # SUPER + P
```

### Notifications

Quickshell owns `org.freedesktop.Notifications` through a D-Bus activation file
in `home/quickshell/default.nix`, so it starts on demand when any application
sends its first notification. There is no separate daemon.

`nm-applet` and `blueman-applet` still run, but only as the NetworkManager
secret agent and the Bluetooth pairing agent — `Tray.qml` hides their icons and
their own popups are disabled via dconf so they don't duplicate the shell's
notifications.

Test delivery with:

```sh
notify-send "aurora" "test"
```

---

## Theming

Stylix drives colours, fonts and wallpaper across GTK, Qt, Kitty, Neovim and
Quickshell from one place.

- Theme definitions: `lib/themes.nix` — 21 themes
- Active theme: `global.activeTheme` in `lib/themes.nix`
- Runtime switcher: `SUPER + C`

Available themes:

`aurora` · `gruvbox` · `gruvbox-light` · `tokyo-night` · `tokyo-night-storm` ·
`monochrome` · `catppuccin-mocha` · `catppuccin-macchiato` · `catppuccin-frappe` ·
`catppuccin-latte` · `nord` · `dracula` · `one-dark` · `everforest` · `rose-pine` ·
`rose-pine-moon` · `solarized-dark` · `solarized-light` · `kanagawa` ·
`github-dark` · `monokai-pro`

`stylix.autoEnable` is off, so targets are enabled explicitly. Note that Stylix
exposes **two separate `targets` options** — one at NixOS level
(`modules/stylix/`) and one at Home Manager level (`home/theme/`). They are not
duplicates. Removing the home-level ones will silently unstyle GTK and Qt
applications.

---

## Identity

All personal values are centralised in `lib/variables.nix`:

Change them here rather than in individual modules.

---

## Scripts

```sh
./scripts/check.sh      # validate the configuration before rebuilding
./scripts/cleanup.sh    # maintenance dashboard; keeps 5 generations
```

`check.sh` runs a series of structural assertions over the repository —
flake evaluation, module wiring, keybind sanity, notification delivery — and
reports each as pass or fail.

---

## Reloading without a rebuild

| Changed                                  | Command                               |
| ---------------------------------------- | ------------------------------------- |
| Hyprland Lua                             | `hyprctl reload`                      |
| Quickshell QML                           | `systemctl --user restart quickshell` |
| Quickshell, with logs                    | `qs` in a terminal                    |
| Anything in `modules/` or `home/` `.nix` | full rebuild                          |

Running `qs` directly is the fastest way to debug QML — errors print with file
and line number instead of disappearing into the journal.

---

## Troubleshooting

**Hyprland won't load after editing a rule.** Almost always a single backslash
in a Lua regex. Double it.

**`Type X unavailable` / `Property value set multiple times`.** A QML error;
run `qs` to get the file and line.

**`Cannot assign to non-existent property`.** The property doesn't exist on
that type. Positioners (`Column`, `Row`, `Grid`, `Flow`) accept `add`, `move`
and `populate` only — `displaced` belongs to `ListView` and `GridView`.

**Applications lost their theme.** Check that the Home Manager Stylix targets
in `home/theme/default.nix` are still present.

**Rolling back.** Pick the previous generation from the GRUB menu. Note that
`timeout = 1` gives you a one-second window — hold `Shift` during boot if you
miss it.

---

## Recovery

```sh
sudo nixos-rebuild switch --rollback     # previous generation
nix-env --list-generations --profile /nix/var/nix/profiles/system
```
