{ ... }:

{

  home.sessionVariables = {


    EDITOR = "nvim";

    VISUAL = "nvim";


    PAGER = "less";

    LESS = "-R";

    MANPAGER = "less -R";


    BROWSER = "zen";

    TERMINAL = "kitty";


    PNPM_HOME = "$HOME/.local/share/pnpm";


    LIBVIRT_DEFAULT_URI = "qemu:///system";
  };


  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.local/share/pnpm"
  ];
}
