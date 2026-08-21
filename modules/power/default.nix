{ ... }:

{
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;
  powerManagement.enable = true;
  networking.networkmanager.wifi.powersave = false;
  zramSwap.enable = true;
}
