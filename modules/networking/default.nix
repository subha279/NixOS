{ ... }:

{
  networking = {
    networkmanager.enable = true;
  };

  services.openssh = {
    enable = true;

    settings = {
      PasswordAuthentication = true;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";

      X11Forwarding = false;
    };

    openFirewall = true;
  };
}
