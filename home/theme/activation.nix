{ lib, ... }:
{
  home.activation.initializeAuroraTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    theme_dir="$HOME/.config/aurora"
    theme_file="$theme_dir/active-theme"
    active_lua="$theme_dir/active-theme.lua"
    active_kitty="$theme_dir/active-kitty.conf"
    active_tmux="$theme_dir/active-tmux.conf"
    active_starship="$theme_dir/active-starship.toml"

    mkdir -p "$theme_dir"
    mkdir -p "$HOME/.cache/aurora"

    if [ ! -f "$theme_file" ]; then
      printf '%s\n' "catppuccin-mocha" > "$theme_file"
    fi

    selected="$(cat "$theme_file")"

    if [[ ! -f "$theme_dir/themes/$selected.lua" ]]; then
      printf '%s\n' "catppuccin-mocha" > "$theme_file"
      selected="catppuccin-mocha"
    fi

    ln -sfn \
      "$theme_dir/themes/$selected.lua" \
      "$active_lua"

    if [[ -f "$theme_dir/themes/$selected.kitty.conf" ]]; then
      ln -sfn \
        "$theme_dir/themes/$selected.kitty.conf" \
        "$active_kitty"
    else
      ln -sfn \
        "$theme_dir/themes/catppuccin-mocha.kitty.conf" \
        "$active_kitty"
    fi

    if [[ -f "$theme_dir/themes/$selected.tmux.conf" ]]; then
      ln -sfn \
        "$theme_dir/themes/$selected.tmux.conf" \
        "$active_tmux"
    else
      ln -sfn \
        "$theme_dir/themes/catppuccin-mocha.tmux.conf" \
        "$active_tmux"
    fi

    if [[ -f "$theme_dir/themes/$selected.starship.toml" ]]; then
      ln -sfn \
        "$theme_dir/themes/$selected.starship.toml" \
        "$active_starship"
    else
      ln -sfn \
        "$theme_dir/themes/catppuccin-mocha.starship.toml" \
        "$active_starship"
    fi

    gtk3_dir="$HOME/.config/gtk-3.0"
    gtk4_dir="$HOME/.config/gtk-4.0"
    kvantum_dir="$HOME/.config/Kvantum"
    kvantum_theme="$kvantum_dir/Base16Kvantum"

    mkdir -p "$gtk3_dir" "$gtk4_dir" "$kvantum_dir"

    ln -sfn "$theme_dir/themes/$selected/gtk-3.0/gtk.css" "$gtk3_dir/gtk.css"
    ln -sfn "$theme_dir/themes/$selected/gtk-4.0/gtk.css" "$gtk4_dir/gtk.css"

    if [[ -L "$kvantum_theme" || -e "$kvantum_theme" ]]; then
    rm -rf "$kvantum_theme"
    fi

    ln -s \
    "$theme_dir/themes/$selected/kvantum" \
    "$kvantum_theme"
  '';
}
