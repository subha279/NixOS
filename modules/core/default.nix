{ ... }:

let
  vars = import ../../lib/variables.nix;
in
{
  time.timeZone = vars.system.timezone;
  i18n.defaultLocale = vars.system.locale;
  console.keyMap = "us";
  networking.enableIPv6 = false;
  networking.networkmanager.dns = "default";
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    # Official Nix binary cache ONLY.
    substituters = [
      "https://cache.nixos.org/"
    ];

    require-sigs = true;
    http-connections = 3;
    connect-timeout = 10;
    stalled-download-timeout = 90;
    cores = 0;
    max-jobs = "auto";
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";

    # Do not let a garbage collect fight a rebuild for I/O.
    randomizedDelaySec = "30min";
  };

  nix.optimise = {
    automatic = true;
    dates = [ "weekly" ];
  };

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "26.05";
}
