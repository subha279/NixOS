<div align="center">

❄️ NixOS

A declarative, polished Linux desktop built around NixOS + Hyprland

<p>
  <strong>Reproducible.</strong>
  <strong>Minimal.</strong>
  <strong>Fast.</strong>
  <strong>Beautiful.</strong>
</p>

<p>
  <a href="https://nixos.org/">NixOS</a> ·
  <a href="https://github.com/nix-community/home-manager">Home Manager</a> ·
  <a href="https://hyprland.org/">Hyprland</a> ·
  <a href="https://quickshell.outfoxxed.me/">Quickshell</a> ·
  <a href="https://github.com/danth/stylix">Stylix</a> ·
  <a href="https://github.com/explosion-mental/wallust">Wallust</a> ·
  <a href="https://neovim.io/">Neovim</a>
</p>

<img src="https://img.shields.io/badge/NixOS-26.05-5277C3?style=for-the-badge&logo=nixos&logoColor=white" alt="NixOS 26.05">
<img src="https://img.shields.io/badge/Wayland-Hyprland-58E1FF?style=for-the-badge" alt="Hyprland">
<img src="https://img.shields.io/badge/Config-Declarative-8A2BE2?style=for-the-badge" alt="Declarative configuration">

</div>

✦ About

My personal NixOS configuration and Linux desktop environment.

The goal is simple:

Build a Linux workstation that is reproducible, keyboard-driven, visually cohesive, and pleasant to use every day.

Almost everything is declared in Nix and Home Manager. The desktop is built around Hyprland, with a custom Quickshell shell, Stylix for system-wide theming, and Wallust + awww for dynamic wallpaper-driven colors.

It also doubles as my development environment for learning and building software — especially Linux, open source, systems programming, Rust, C/C++, and web development.

✨ Highlights

Area

What it provides

🧊 OS

Declarative NixOS configuration using flakes

🪟 Window Manager

Hyprland on Wayland

🖥️ Desktop Shell

Custom Quickshell bar

🎨 Theming

Stylix + Wallust wallpaper color generation

🖼️ Wallpaper

awww with animated transitions

🚀 Launcher

Fuzzel with icons and wallpaper previews

💻 Terminal

Kitty + dynamic Wallust colors

🧠 Editor

Neovim with LSP, Treesitter, completion, formatting and diagnostics

🐚 Shell

Zsh + Starship + fzf + zoxide

🎮 Graphics

Intel + NVIDIA PRIME offload

🔔 Notifications

libnotify / notify-send

🔊 Audio

PipeWire + WirePlumber

📡 Networking

NetworkManager + applet

🔵 Bluetooth

BlueZ + Blueman

🛠️ Validation

Custom configuration health checker

🧹 Maintenance

Interactive cleanup and system maintenance dashboard

🖼️ Desktop Philosophy

principles:

Declarative
    ↓
Reproducible
    ↓
Modular
    ↓
Maintainable
    ↓
Fast + keyboard driven
    ↓
Beautiful without unnecessary complexity

The desktop should feel like one system, rather than a collection of unrelated applications.

Wallpaper changes therefore drive the visual identity of the entire environment.

🧭 Architecture

                         ┌──────────────────┐
                         │      flake.nix   │
                         └────────┬─────────┘
                                  │
                 ┌────────────────┴────────────────┐
                 │                                 │
        ┌────────▼────────┐              ┌────────▼────────┐
        │     NixOS       │              │  Home Manager   │
        │     modules     │              │      home/      │
        └────────┬────────┘              └────────┬────────┘
                 │                                │
        ┌────────▼────────┐              ┌────────▼────────┐
        │ System services │              │ User programs   │
        │ Hardware        │              │ Dotfiles        │
        │ Networking      │              │ Applications    │
        └────────┬────────┘              └────────┬────────┘
                 │                                │
                 └────────────────┬───────────────┘
                                  │
                         ┌────────▼────────┐
                         │    Hyprland     │
                         │     Wayland     │
                         └────────┬────────┘
                                  │
              ┌───────────────────┼───────────────────┐
              │                   │                   │
       ┌──────▼──────┐     ┌──────▼──────┐     ┌──────▼──────┐
       │  Quickshell │     │   Fuzzel    │     │    Kitty    │
       │     UI      │     │   Launcher  │     │  Terminal   │
       └─────────────┘     └─────────────┘     └─────────────┘

📁 Repository Structure

NixOS/
├── flake.nix
├── flake.lock
├── README.md
├── .gitignore
│
├── hosts/
│   └── laptop/
│       ├── default.nix
│       └── hardware-configuration.nix
│
├── modules/
│   ├── audio/
│   ├── bluetooth/
│   ├── boot/
│   ├── core/
│   ├── creator/
│   ├── desktop/
│   ├── development/
│   ├── fonts/
│   ├── graphics/
│   ├── hyprland/
│   ├── monitoring/
│   ├── networking/
│   ├── nvidia/
│   ├── packages/
│   ├── polkit/
│   ├── power/
│   ├── session/
│   ├── stylix/
│   ├── users/
│   └── xdg/
│
├── home/
│   ├── default.nix
│   ├── fastfetch/
│   ├── fuzzel/
│   ├── git/
│   ├── hyprland/
│   ├── kitty/
│   ├── neovim/
│   ├── quickshell/
│   ├── ssh/
│   ├── theme/
│   ├── xdg/
│   └── zsh/
│
├── lib/
│   └── variables.nix
│
└── scripts/
    ├── check.sh
    └── cleanup.sh

Design rule

System-wide configuration belongs in modules/.

User-level configuration belongs in home/.

Machine-specific configuration belongs in hosts/.

Shared values belong in lib/.

That separation keeps the configuration easier to understand and extend.

🖥️ Host

laptop

The primary workstation.

CPU       Intel
GPU       Intel + NVIDIA
Graphics  NVIDIA PRIME offload
Kernel    6.x
Storage   ext4
Boot      EFI + GRUB
Session   Wayland
WM        Hyprland

The generated hardware-configuration.nix is intentionally kept under the host because it is machine-specific.

🎨 Theming System

The most distinctive part of the setup is the dynamic theming pipeline.

                 Wallpaper
                     │
                     ▼
                  Wallust
                     │
             ┌───────┼────────┐
             │       │        │
             ▼       ▼        ▼
          Hyprland  Kitty   Fuzzel
             │       │        │
             └───────┼────────┘
                     │
                     ▼
                  Starship
                     │
                     ▼
              Entire desktop

Wallpaper workflow

MOD + P
   │
   ▼
Fuzzel wallpaper picker
   │
   ▼
Select image
   │
   ▼
wallust extracts palette
   │
   ▼
awww transitions wallpaper
   │
   ├──► Hyprland colors
   ├──► Kitty colors
   ├──► Fuzzel colors
   └──► Starship colors

The result is a desktop where the wallpaper and application chrome feel like part of the same visual system.

🪟 Hyprland

Hyprland is configured through a modular Lua-based setup rather than one large configuration file.

home/hyprland/
├── hyprland.lua
├── config/
│   ├── animation.lua
│   ├── decoration.lua
│   ├── env.lua
│   ├── general.lua
│   ├── input.lua
│   ├── keybinds.lua
│   ├── layerules.lua
│   ├── layout.lua
│   ├── misc.lua
│   ├── monitor.lua
│   ├── startup.lua
│   ├── theme.lua
│   └── windowrules.lua
└── scripts/
    ├── launcher.sh
    ├── restore-wallpaper.sh
    └── wallpaper.sh

Hyprland is intentionally split into small modules so individualbehaviors can be changed without editing one huge configuration file.

Desktop characteristics

Wayland-first workflow

Dwindle layout

Minimal borders

Small gaps

Rounded corners

Blur and shadows

Smooth animations

Floating application rules

Touchpad tuning

Workspace gestures

Dynamic wallpaper colors

Keyboard-driven navigation

🧊 Quickshell — Bar

The custom Quickshell UI is a compact floating pill rather than a traditionalfull-width panel.

<div align="center">

󱄅  ·  🔊  ·  ☀  ·  20:42  ·    ·    ·  tray

</div>

Bar modules

Module

Purpose

🚀 Launcher

Open the application launcher

🔊 Volume

Audio level and mute control

☀️ Brightness

Display brightness control

🕐 Clock

Current time

 Network

Network status

 Bluetooth

Bluetooth status

🧩 Tray

System tray applications

⚙️ Settings

Quick desktop controls

The shell is managed declaratively through Home Manager and runs as a usersystemd service.

🚀 Fuzzel

The launcher is intentionally compact and visual.

Features include:

Papirus icons

Nerd Font prompt

Stylix colors

Rounded glass-style UI

Application search

Wallpaper preview support

Keyboard-first navigation

Example:

╭──────────────────────────────────────╮
│ 󱄅   Search applications...           │
├──────────────────────────────────────┤
│ 󰈹   Firefox                          │
│ 󰆍   Kitty                            │
│ 󰙨   Neovim                           │
│ 󰀻   Thunar                           │
╰──────────────────────────────────────╯

💻 Kitty

Kitty is the primary terminal.

Configured with:

JetBrains Mono Nerd Font

Dynamic Wallust colors

Transparent/glass appearance

Blur

Powerline-style tabs

Large scrollback

Clipboard integration

Socket remote control

Live theme updates

🐚 Zsh

The shell environment is built around:

Zsh

Starship

fzf

zoxide

bat

eza

fd

ripgrep

jq

Everyday aliases

Alias

Command

ls

eza

ll

eza -lah

la

eza -a

lt

eza --tree

v

nvim

c

clear

..

cd ../

🧠 Neovim

Neovim is configured as a full development environment rather than a basic text editor.

Core stack

Neovim
├── blink.cmp
├── nvim-lspconfig
├── Treesitter
├── Telescope
├── Gitsigns
├── Conform
├── nvim-lint
├── Trouble
├── which-key
├── Lualine
├── Snacks
└── NvimTree

Language tooling

Configured development environments include:

Rust

C / C++

Lua

Nix

Python

TypeScript / JavaScript

HTML / CSS

JSON

YAML

Bash

Docker

Markdown

TOML

Tailwind CSS

Toolchain

Rust       rust-analyzer · rustfmt
C/C++      clangd · gcc · gdb · cmake
Lua        lua-language-server · stylua
Python     pyright · ruff
Nix        nixd · nixfmt
JS/TS      typescript-language-server · prettier
Shell      bash-language-server · shellcheck · shfmt
Docker     dockerfile-language-server
TOML       taplo
Markdown   marksman

⌨️ Keybindings

MOD = Super / Windows keyNeovim leader = Space

Hyprland

Key

Action

MOD + T

Terminal

MOD + E

File manager

MOD + B

Browser

MOD + A

Launcher

MOD + I

Quickshell settings

MOD + P

Wallpaper picker

MOD + Q

Close window

MOD + X

Exit Hyprland

MOD + SHIFT + S

Screenshot

MOD + V

Toggle floating

MOD + J

Toggle split

MOD + 1…0

Workspace 1–10

MOD + SHIFT + 1…0

Move window to workspace

MOD + Arrow Keys

Focus direction

MOD + Mouse

Move / resize windows

Hardware controls

Key

Action

XF86AudioRaiseVolume

Volume +5%

XF86AudioLowerVolume

Volume −5%

XF86AudioMute

Toggle mute

XF86AudioMicMute

Toggle microphone mute

XF86MonBrightnessUp

Brightness +5%

XF86MonBrightnessDown

Brightness −5%

XF86AudioNext

Next track

XF86AudioPrev

Previous track

XF86AudioPlay

Play

XF86AudioPause

Pause

🔎 Neovim Navigation

A few of the most-used mappings:

Key

Action

<leader>ff

Find files

<leader>fg

Live grep

<leader>fb

Buffers

<leader>fr

Recent files

<leader>fd

Diagnostics

<leader>e

File explorer

gd

Definition

gr

References

K

Hover documentation

<leader>lr

Rename

<leader>la

Code action

<leader>xx

Diagnostics

<leader>lg

LazyGit

<leader>tt

Terminal

<leader>bn

Next buffer

<leader>bp

Previous buffer

For the complete keymap, see the Neovim configuration.

📦 Software

Desktop

Firefox

Thunar

File Roller

Pavucontrol

Blueman

qt6ct

Kvantum

NetworkManager applet

grim

slurp

swappy

Gwenview

Fuzzel

Quickshell

awww

Wallust

libnotify

Creator

OBS Studio

FFmpeg

VLC

LibreOffice

GIMP

Blender

DaVinci Resolve integration

Development

GCC

Clang

CMake

GDB

LLDB

Rust

Node.js

pnpm

Python

Podman

Git

Git LFS

ShellCheck

shfmt

strace

Monitoring

btop

htop

iotop

iftop

lsof

lm_sensors

pciutils

usbutils

🛠️ Validation & Maintenance

The repository includes custom scripts so the configuration can be checked before rebuilding.

check.sh

Validates things such as:

Git repository state

Flake evaluation

Nix syntax

Required files

Neovim configuration

Lua syntax

Quickshell health

Hyprland configuration

Desktop dependencies

Neovim development tools

Plugins

Generated configuration

Run:

./scripts/check.sh

cleanup.sh

Provides an interactive maintenance workflow for:

Flake checks

Dry builds

Nix generation cleanup

Garbage collection

Store optimization

Store verification

systemd health

Disk/store usage

Run:

./scripts/cleanup.sh

🚀 Installation

This repository is primarily intended for my own machine, but the structure can be adapted for other NixOS systems.

1. Clone

git clone git@github.com:subha279/NixOS.git
cd NixOS

2. Inspect

nix flake check

3. Validate

./scripts/check.sh

4. Rebuild the laptop

sudo nixos-rebuild switch --flake .#laptop

Important: hosts/laptop/hardware-configuration.nix is machine-specific. Generate your own hardware configuration before adapting this repository to different hardware.

Machine-specific configuration such as filesystem UUIDs may remain in hardware-configuration.nix because that file is required for the local NixOS installation and does not contain authentication credentials.

🗺️ Roadmap

An evolving configuration.

Completed

NixOS flakes

Modular NixOS architecture

Home Manager integration

Hyprland Wayland desktop

Custom Quickshell shell

Stylix theming

Wallust wallpaper theming

awww wallpaper transitions

Fuzzel launcher

Dynamic Kitty / Starship theming

Neovim development environment

Volume and brightness controls

Notification integration

Polkit authentication

NVIDIA PRIME offload

Repository validation scripts

Planned

More Quickshell widgets

Better system controls / quick settings

More desktop automation

Improved notification center

More reusable host modules

Better installation documentation

Automated CI checks

More hardware profiles

🤝 Philosophy

This configuration is not intended to be a universal NixOS distribution.

It is a living personal system.

The priorities are:

Reproducibility
      +
Maintainability
      +
Performance
      +
Developer experience
      +
Visual consistency
      +
Learning

Every improvement should make the system easier to understand, reproduce, or use.

📜 License

This configuration is intended to be shared as an open-source personal configuration.

If you use parts of it, feel free to adapt them to your own system.

<div align="center">

❄️ Built with Nix · Wayland · Hyprland · Neovim

Made with ❤️ and flakes by Subha

</div>
