{ ... }:

{
  # Boot Loader

  boot.loader = {
    grub = {
      enable = true;
      efiSupport = true;
      device = "nodev";
      useOSProber = false;
    };

    efi.canTouchEfiVariables = true;

    # NixOS defaults this to 5, which is five seconds spent staring at a menu you almost never use.
    timeout = 1;
  };

  # Initrd

  # The legacy initrd is a shell script that does its work in sequence.
  boot.initrd.systemd.enable = true;

  boot.initrd.verbose = false;

  # Console Verbosity

  # Writing every kernel and udev message to the console costs real time during early boot, and none of it is readable at that speed anyway.
  boot.kernelParams = [
    "quiet"
    "loglevel=3"
    "udev.log_level=3"
    "rd.udev.log_level=3"

    # No hardware watchdog on a laptop.
    "nowatchdog"
  ];

  boot.consoleLogLevel = 0;
}
