{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    gcc
    clang
    gnumake
    cmake
    pkg-config

    git-lfs
    shellcheck
    claude-desktop-fhs
    zed-editor

    rustc
    cargo
    rustfmt
    clippy

    nodejs
    pnpm

    python3

    podman
    podman-compose

    gdb
    strace
    lldb

    man-pages
    man-pages-posix

    clang-tools

  ];
}
