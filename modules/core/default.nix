{ ... }:

{
  time.timeZone = "Asia/Kolkata";

  i18n.defaultLocale = "en_US.UTF-8";

  console.keyMap = "us";

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    # 1. Boost concurrent downloads (default is only 25)
    http-connections = 50;

    # 2. Allow Nix to use all CPU cores if it has to build something locally
    cores = 0;
    max-jobs = "auto";

    # 3. Restore the official cache and use Asian mirrors safely
    substituters = [
      "https://cache.nixos.org/"
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      "https://mirror.sjtu.edu.cn/nix-channels/store"
    ];
  };

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "26.05";
}
