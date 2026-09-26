{ ... }:

{
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;
  powerManagement.enable = true;
  zramSwap.enable = true;
}
