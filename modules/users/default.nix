{ pkgs, ... }:

let
  vars = import ../../lib/variables.nix;
in
{
  users.users.${vars.username} = {
    isNormalUser = true;

    shell = pkgs.zsh;

    extraGroups = [
      "wheel"
      "networkmanager"
      "input"
    ];
  };

  programs.zsh.enable = true;

  security.sudo.enable = true;
}
