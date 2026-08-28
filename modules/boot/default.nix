{ ... }:

{
  boot.loader = {
    grub = {
      enable = true;
      efiSupport = true;
      device = "nodev";
      useOSProber = false;

      # Install GRUB to the UEFI fallback path:
      # /EFI/BOOT/BOOTX64.EFI
      efiInstallAsRemovable = true;

      # Cap the generation list.
      #
      # Unbounded, every rebuild adds a menu entry permanently: GRUB has to read
      # and render the whole list before the timeout, and it becomes unusable as a
      # recovery tool long before that. Older generations still exist and are
      # still bootable via nixos-rebuild; they just stop being offered here.
      configurationLimit = 10;
    };

    # Don't depend on UEFI NVRAM entries.
    efi.canTouchEfiVariables = false;

    timeout = 1;
  };

  # Initrd
  boot.initrd.systemd.enable = true;
  boot.initrd.verbose = false;

  # Console verbosity
  boot.kernelParams = [
    "quiet"
    "loglevel=3"
    "udev.log_level=3"
    "rd.udev.log_level=3"
    "nowatchdog"
  ];

  boot.consoleLogLevel = 0;
}
