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

  # Official Nix cache, pinned to the currently best-performing Fastly endpoint on this ISP.
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

    # Deliberately NOT auto-optimise-store: that hardlinks during every build,
    # taxing the thing you are waiting on. nix.optimise below does the same work
    # on a schedule instead.
  };

  # Store hygiene
  #
  # Neither of these existed, so nothing ever reclaimed space: every rebuild
  # added a generation and kept it forever. That grows /nix/store without bound
  # and, because each generation is a GRUB menu entry, lengthens the boot menu
  # too (see boot.loader.grub.configurationLimit in modules/boot).

  nix.gc = {
    automatic = true;

    dates = "weekly";

    options = "--delete-older-than 30d";

    # Do not let a garbage collect fight a rebuild for I/O.
    randomizedDelaySec = "30min";
  };

  # Hardlinks duplicate files in the store. The theme generator alone writes 28
  # files per rebuild (4 formats x 7 themes), most unchanged between generations.
  nix.optimise = {
    automatic = true;

    dates = [ "weekly" ];
  };

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "26.05";
}
