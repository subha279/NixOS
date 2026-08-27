{ ... }:

{
  # Notification Delivery

  # Portal notification backend

  xdg.portal.config.common = {
    "org.freedesktop.impl.portal.Notification" = [ "gtk" ];

    # Keep the rest of the portal behaviour explicit while we are here, so a future backend does not silently take over the file picker.
    default = [
      "hyprland"
      "gtk"
    ];

    "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];

    "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
  };

  # GLib / GApplication support

  programs.dconf.enable = true;

  # Battery notifications

  services.upower = {
    percentageLow = 20;

    percentageCritical = 10;

    percentageAction = 5;

    # NOT "Hibernate": this host has no resume device. hardware-configuration
    # declares `swapDevices = [ ]` and modules/power enables zramSwap only, so a
    # hibernate request fails and the battery keeps draining past percentageAction.
    #
    # To go back to hibernating, add swap of at least RAM size (a partition, or a
    # file plus boot.resumeDevice + the resume_offset kernel param) and flip this.
    criticalPowerAction = "PowerOff";
  };
}
