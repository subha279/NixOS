{ pkgs, ... }:

{
  programs.ssh = {
    enable = true;

    enableDefaultConfig = false;

    settings = {
      "*" = {
        AddKeysToAgent = "yes";
        ServerAliveInterval = 60;
        ServerAliveCountMax = 3;
      };
    };
  };

  home.packages = with pkgs; [
    keychain
  ];

  programs.zsh.initContent = ''
    eval "$(${pkgs.keychain}/bin/keychain --eval --quiet id_ed25519)"
  '';
}
