{ ... }:

{


  xdg.portal.config.common = {
    "org.freedesktop.impl.portal.Notification" = [ "gtk" ];

    default = [
      "hyprland"
      "gtk"
    ];

    "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];

    "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
  };


  programs.dconf.enable = true;


  services.upower = {
    percentageLow = 20;

    percentageCritical = 10;

    percentageAction = 5;

    # Not Hibernate: no swap device, so hibernating would fail silently.
    criticalPowerAction = "PowerOff";
  };
}
