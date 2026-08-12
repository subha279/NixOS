{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [

    # Version Control
    git

    # Networking
    curl
    wget

    # Archives
    zip
    unzip

    # File Utilities
    tree
    file
    which

    # System Utilities
    killall
  ];
}
