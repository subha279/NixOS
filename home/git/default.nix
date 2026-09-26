{ ... }:

let
  vars = import ../../lib/variables.nix;
in
{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = vars.user.gitUser;
        email = vars.user.email;
      };
      init.defaultBranch = "main";
      pull.rebase = false;
    };
  };
}
