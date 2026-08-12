{ pkgs, ... }:

{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  environment.systemPackages = with pkgs; [

    # Cursor
    hyprcursor

    # Clipboard
    wl-clipboard
    cliphist

    # Hardware / Media Controls
    brightnessctl
    playerctl
    libinput

    # Wayland Utilities
    wayland-utils
  ];
}
