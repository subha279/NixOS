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
    wtype

    brightnessctl
    playerctl
    libinput

    wayland-utils
  ];
}
