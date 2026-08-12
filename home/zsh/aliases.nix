{ ... }:

{
  programs.zsh.shellAliases = {
    ls = "eza";
    ll = "eza -lah";
    la = "eza -a";
    lt = "eza --tree";
    v = "nvim";
    c = "clear";
    ".." = "cd ../";
  };
}
