{ ... }:

{
  boot.loader = {
    grub = {
      enable = true;
      efiSupport = true;
      device = "nodev";
      useOSProber = false;
    };

    efi.canTouchEfiVariables = true;
  };
}
