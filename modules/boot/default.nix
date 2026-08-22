{ ... }:

{
  # ==================================================
  # Boot Loader
  # ==================================================

  boot.loader = {
    grub = {
      enable = true;
      efiSupport = true;
      device = "nodev";
      useOSProber = false;
    };

    efi.canTouchEfiVariables = true;

    # NixOS defaults this to 5, which is five seconds spent staring at a
    # menu you almost never use. One second is still long enough to catch
    # it with a keypress when you need an older generation.
    timeout = 1;
  };

  # ==================================================
  # Initrd
  # ==================================================

  # The legacy initrd is a shell script that does its work in sequence.
  # The systemd initrd starts the same work in parallel and hands off to
  # the real root sooner. Safe here because root is plain ext4 with no
  # LUKS, LVM or RAID that would need unlocking or assembly first.
  boot.initrd.systemd.enable = true;

  boot.initrd.verbose = false;

  # ==================================================
  # Console Verbosity
  # ==================================================

  # Writing every kernel and udev message to the console costs real time
  # during early boot, and none of it is readable at that speed anyway.
  # Everything is still recorded, so `journalctl -b` loses nothing.
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
