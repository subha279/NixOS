{ ... }:

{
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "subha279";
        email = "anupambiswas030@gmail.com";
      };

      init.defaultBranch = "main";

      pull.rebase = false;
    };
  };
}
