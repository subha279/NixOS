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
    () {
      local env_file="$HOME/.keychain/''${HOST}-sh"

      if [[ -r "$env_file" ]]; then
        source "$env_file" > /dev/null 2>&1
      fi

      if [[ ! -S "''${SSH_AUTH_SOCK:-}" ]]; then
        eval "$(${pkgs.keychain}/bin/keychain --eval --quiet id_ed25519)"
      fi
    }
  '';
}
