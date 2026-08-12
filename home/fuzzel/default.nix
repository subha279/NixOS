{ config, ... }:

let
  colors = config.lib.stylix.colors;
in
{
  xdg.configFile."fuzzel/fuzzel.ini".text = ''
    [main]

    # ==================================================
    # Typography
    # ==================================================

    font=JetBrains Mono Nerd Font:size=11

    terminal=kitty

    # ==================================================
    # Layout
    # ==================================================

    prompt="  󱄅  "
    placeholder="Search applications..."

    width=42
    lines=8

    horizontal-pad=18
    vertical-pad=12
    inner-pad=8

    line-height=24
    letter-spacing=0

    layer=overlay
    anchor=center

    exit-on-keyboard-focus-loss=yes

    # ==================================================
    # Icons
    # ==================================================

    icons-enabled=yes
    icon-theme=Papirus-Dark

    dpi-aware=auto
    scaling-filter=bilinear

    # ==================================================
    # Wallpaper preview support
    # ==================================================

    image-size-ratio=0.35


    # ==================================================
    # Stylix colors
    # ==================================================

    [colors]

    background=${colors.base00}e6

    text=${colors.base05}ff
    prompt=${colors.base0D}ff
    placeholder=${colors.base03}ff
    input=${colors.base05}ff

    match=${colors.base0D}ff

    selection=${colors.base02}f2
    selection-text=${colors.base06}ff
    selection-match=${colors.base0C}ff

    counter=${colors.base03}ff

    border=${colors.base0D}66


    # ==================================================
    # Border
    # ==================================================

    [border]

    width=2
    radius=14
  '';
}
