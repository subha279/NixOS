{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [

    btop
    htop

    iotop
    iftop

    lsof
    lm_sensors
    pciutils
    usbutils
  ];
}
