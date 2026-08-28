{ ... }:

{
  programs.zsh.shellAliases = {


    ls = "eza --icons --group-directories-first";

    ll = "eza -lah --icons --group-directories-first";

    la = "eza -a --icons --group-directories-first";

    lt = "eza --tree --icons --group-directories-first";

    tree = "eza --tree --icons --group-directories-first";


    ".." = "cd ..";

    "..." = "cd ../..";

    "...." = "cd ../../..";


    v = "nvim";

    vi = "nvim";

    vim = "nvim";

    sv = "sudo -E nvim";


    c = "clear";

    df = "df -h";

    du = "du -h";

    diff = "diff --color=auto";


    gs = "git status";

    gd = "git diff";

    gl = "git log --oneline --graph --decorate";

    ga = "git add";

    gc = "git commit";

    gp = "git push";

    gpl = "git pull --ff-only";
  };
}
