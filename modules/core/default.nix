{ ... }:

let
  vars = import ../../lib/variables.nix;
in
{
  time.timeZone = vars.timezone;

  i18n.defaultLocale = vars.locale;

  console.keyMap = "us";

  # Use Cloudflare DNS instead of ISP DNS.
  networking.networkmanager.dns = "none";

  networking.nameservers = [
    "1.1.1.1"
    "1.0.0.1"
  ];

  # Your ISP has no working IPv6 route to the Nix cache.
  networking.enableIPv6 = false;

  # Official Nix cache, pinned to the currently best-performing
  # Fastly endpoint on this ISP.
  networking.extraHosts = ''
    151.101.65.91 cache.nixos.org
  '';

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

    http-connections = 25;

    connect-timeout = 10;
    stalled-download-timeout = 90;

    cores = 0;
    max-jobs = "auto";
  };

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "26.05";
}
