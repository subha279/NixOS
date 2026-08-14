{ lib, ... }:

{
  time.timeZone = "Asia/Kolkata";

  i18n.defaultLocale = "en_US.UTF-8";

  console.keyMap = "us";

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nix.settings.substituters = lib.mkForce [
    "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
  ];

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "26.05";
}
