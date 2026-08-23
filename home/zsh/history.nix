{ ... }:

{
  programs.zsh.history = {
    # Storage

    size = 100000;

    save = 100000;

    path = "$HOME/.local/share/zsh/history";

    # Duplicate Handling

    ignoreDups = true;
    ignoreAllDups = true;
    expireDuplicatesFirst = true;

    # Privacy / Noise Reduction

    ignoreSpace = true;

    # Shared History

    share = true;

    # Extended History

    extended = true;
  };
}
