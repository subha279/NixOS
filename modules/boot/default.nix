{ ... }:

{
  boot.loader = {
    grub = {
      enable = true;
      efiSupport = true;
      device = "nodev";
      useOSProber = false;

      efiInstallAsRemovable = true;

      configurationLimit = 10;
    };

    efi.canTouchEfiVariables = false;

    timeout = 1;
  };

  boot.initrd.systemd.enable = true;
  boot.initrd.verbose = false;

  boot.kernelParams = [
    "quiet"
    "loglevel=3"
    "udev.log_level=3"
    "rd.udev.log_level=3"
    "nowatchdog"
  ];

  boot.consoleLogLevel = 0;
}
