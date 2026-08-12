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
    ../../modules/hyprland
    ../../modules/stylix
    ../../modules/desktop
    ../../modules/session
    ../../modules/monitoring
  ];
}
