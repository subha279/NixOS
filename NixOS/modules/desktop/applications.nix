{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [

    # Browser
    firefox

    # File Manager
    pkgs.thunar
    pkgs.thunar-volman

    # Thunar setup
    shared-mime-info
    gvfs
    tumbler
    ffmpegthumbnailer


    # Archive integration 
    p7zip
    zip
    unar
    p7zip

    # Archive Manager
    file-roller

    # Audio
    pavucontrol

    # Bluetooth
    blueman

    # Theme Utilities
    nwg-look
    qt6Packages.qt6ct

    # Network
    networkmanagerapplet

    # Screenshots
    grim
    slurp
    swappy

    # Clipboard
    wl-clipboard
    cliphist

    # Misc
    xdg-utils
  ];
}
