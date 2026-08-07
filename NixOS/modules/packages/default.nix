{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [

    # Version Control
    git

    # Editors
    neovim

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

    # Modern CLI Tools
    bat
    eza
    fd
    ripgrep
    jq
    fzf
    zoxide

    # System
    htop
    btop
    lsof
    pciutils
    usbutils
    killall
  ];
}
