{ ... }:

{
  imports = [
    ./hardware-configuration.nix

    ../../modules/core
    ../../modules/boot
    ../../modules/networking
    ../../modules/users
    ../../modules/packages

    ../../modules/fonts
    ../../modules/audio
    ../../modules/bluetooth
    ../../modules/polkit
    ../../modules/graphics
    ../../modules/xdg
    ../../modules/greetd
    ../../modules/hyprland
    ../../modules/desktop
    ../../modules/session
    ../../modules/monitoring
  ];

  networking.hostName = "Subha";
}
