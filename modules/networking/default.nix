{ ... }:

{
  networking = {
    networkmanager.enable = true;
  };

  # Boot Speed

  # NetworkManager pulls in NetworkManager-wait-online.service, which holds the boot at network-online.target until a link actually comes up.
  systemd.services.NetworkManager-wait-online.enable = false;

  services.openssh = {
    enable = true;

    # Socket activated: sshd is launched by the first incoming connection rather than occupying a slot in the boot path.
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
