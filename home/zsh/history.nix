{ ... }:

{
  programs.zsh.history = {

    size = 100000;

    save = 100000;

    path = "$HOME/.local/share/zsh/history";


    ignoreDups = true;
    ignoreAllDups = true;
    expireDuplicatesFirst = true;


    ignoreSpace = true;


    share = true;


    extended = true;
  };
}
