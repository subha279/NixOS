{ ... }:

{
  # Shell / Developer Environment

  home.sessionVariables = {

    # Editor

    EDITOR = "nvim";

    VISUAL = "nvim";

    # Pager

    PAGER = "less";

    LESS = "-R";

    MANPAGER = "less -R";

    # Applications

    BROWSER = "firefox";

    TERMINAL = "kitty";

    # Package Managers

    PNPM_HOME = "$HOME/.local/share/pnpm";

    # Virtualization

    LIBVIRT_DEFAULT_URI = "qemu:///system";
  };

  # User PATH

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.local/share/pnpm"
  ];
}
