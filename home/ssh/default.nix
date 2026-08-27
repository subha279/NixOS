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

  # Agent setup, once per boot rather than once per shell.
  #
  # This used to run `keychain --eval` unconditionally in every interactive
  # shell, which forks keychain, which in turn inspects or starts ssh-agent --
  # tens of milliseconds on the critical path of every new terminal and every
  # new tab, to reach a state that is almost always already set up.
  #
  # keychain caches the agent environment in ~/.keychain/<host>-sh precisely so
  # later shells can source it instead. So: source that if present, and only
  # actually invoke keychain when no live agent socket came out of it.
  #
  # Trade-off: an agent that is running but has had its keys dropped (ssh-add -D)
  # will not be repopulated automatically, since we only test for the socket.
  # Run `keychain --eval id_ed25519` by hand in that case.
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
