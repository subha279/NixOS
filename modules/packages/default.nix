{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [

    git

    curl
    wget

    zip
    unzip

    tree
    file
    which

    killall
  ];
}
