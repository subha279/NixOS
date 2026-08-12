{ ... }:

{
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "subha279";
        email = "111702137+subha279@users.noreply.github.com";
      };

      init.defaultBranch = "main";

      pull.rebase = false;
    };
  };
}
