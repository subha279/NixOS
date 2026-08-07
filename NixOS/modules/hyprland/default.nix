{ pkgs, ... }:

{
  programs.hyprland = {
    enable = true;

    xwayland.enable = true;
  };

  environment.systemPackages = with pkgs; [
    
    hyprcursor

    wl-clipboard
    cliphist

    brightnessctl
    playerctl

    grim
    slurp

    wayland-utils

    kitty
  ];
}
