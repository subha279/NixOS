{ ... }:

{
  networking = {
    networkmanager.enable = true;
  };

  # ==================================================
  # Boot Speed
  # ==================================================

  # NetworkManager pulls in NetworkManager-wait-online.service, which
  # holds the boot at network-online.target until a link actually comes
  # up. On a laptop that is routinely 10-30 seconds of dead time, and
  # nothing in this config needs the network before you reach the
  # desktop. NetworkManager itself still starts normally; only the
  # blocking wait is removed.
  systemd.services.NetworkManager-wait-online.enable = false;

  services.openssh = {
    enable = true;

    # Socket activated: sshd is launched by the first incoming
    # connection rather than occupying a slot in the boot path.
    startWhenNeeded = true;

    settings = {
      PasswordAuthentication = true;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";

      X11Forwarding = false;
    };

    openFirewall = true;
  };
}
