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
  #
  # This is what actually fixes that. cache.nixos.org is a CNAME onto
  # dualstack.n.sni.global.fastly.net, so a resolver hands back an AAAA first
  # and every fetch stalls on a route that does not exist. With IPv6 off,
  # getaddrinfo stops returning AAAA records at all and nix only ever tries
  # IPv4.
  networking.enableIPv6 = false;

  # There used to be a `networking.extraHosts` entry pinning cache.nixos.org to
  # 151.101.65.91.
  #
  # Removed, for two reasons.
  #
  # It was redundant: the line above already guarantees IPv4-only resolution,
  # which was the problem the pin was working around.
  #
  # And it was a time bomb. extraHosts overrides DNS outright, so it has no
  # fallback. 151.101.65.91 is one Fastly anycast address out of many, and the
  # day Fastly withdraws it every substitution on this machine fails at once,
  # with a TLS or connection error that says nothing about a stale hosts entry.
  # Cloudflare resolvers are already configured above and resolve the name
  # correctly, including picking a nearer endpoint than a hardcoded one can.

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
