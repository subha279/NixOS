{ ... }:

{
  networking = {
    networkmanager.enable = true;
  };


  systemd.services.NetworkManager-wait-online.enable = false;

  services.openssh = {
    enable = true;

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
