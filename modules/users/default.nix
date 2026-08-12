{ pkgs, ... }:

{
  users.users.subha = {
    isNormalUser = true;

    shell = pkgs.zsh;

    extraGroups = [
      "wheel"
      "networkmanager"
    ];
  };

  programs.zsh.enable = true;

  security.sudo.enable = true;
}
