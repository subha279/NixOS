{ ... }:

{
  # TMUX
  #
  # Behaviour only. Every colour comes from the generated Aurora theme sourced at
  # the bottom of extraConfig, so `aurora-theme <id>` recolours tmux the same way
  # it recolours kitty, starship, Hyprland and the shell.

  programs.tmux = {

    enable = true;

    # Explicit, like stylix.autoEnable = false elsewhere in this config.
    #
    # tmux-sensible is a reasonable set of defaults, but it also sets
    # default-terminal, escape-time and history-limit, which are set deliberately
    # below. Leaving it on means two sources for the same options and a plugin
    # dependency for settings that fit in a dozen lines.
    sensibleOnTop = false;

    # tmux-256color, not screen-256color: the latter caps at 8 colours for some
    # capabilities and is why italics and undercurl go missing inside tmux.
    terminal = "tmux-256color";

    historyLimit = 50000;

    keyMode = "vi";

    mouse = true;

    # Windows and panes both start at 1. The default 0 puts the first window on
    # the far side of the number row from the rest.
    baseIndex = 1;

    # 500ms by default, which is felt directly as lag leaving insert mode in
    # Neovim. 10 is low enough to be imperceptible without breaking terminals
    # that send real escape sequences.
    escapeTime = 10;

    clock24 = true;

    extraConfig = ''
      # --------------------------------------------------------
      # Terminal capabilities
      # --------------------------------------------------------
      #
      # RGB advertises 24-bit colour, which the Aurora themes need: without it
      # tmux quantises every hex colour to the 256-colour cube and the palette
      # visibly shifts the moment you attach.
      #
      # usstyle advertises coloured undercurl. Neovim draws diagnostics with it,
      # and inside tmux it degrades to a plain underline unless declared here.

      set -as terminal-features ",xterm-kitty:RGB:usstyle"

      set -as terminal-features ",xterm-256color:RGB:usstyle"

      set -as terminal-features ",foot:RGB:usstyle"


      # --------------------------------------------------------
      # Panes
      # --------------------------------------------------------

      setw -g pane-base-index 1

      # Close the gap left in the numbering after a window is killed.
      set -g renumber-windows on

      # Lets Neovim's autoread and focus-dependent plugins see focus changes.
      set -g focus-events on

      # Size to the smallest client actually looking at a window, rather than the
      # smallest client attached to the session.
      setw -g aggressive-resize on


      # --------------------------------------------------------
      # New splits and windows inherit the current directory
      # --------------------------------------------------------
      #
      # tmux opens them in the path the session was created in, which is almost
      # never what you want by the time you are three directories deep.

      bind '"' split-window -v -c "#{pane_current_path}"

      bind % split-window -h -c "#{pane_current_path}"

      bind c new-window -c "#{pane_current_path}"


      # --------------------------------------------------------
      # Vi copy mode, wired to the Wayland clipboard
      # --------------------------------------------------------
      #
      # wl-copy comes from wl-clipboard, already installed by
      # modules/hyprland and home/quickshell. Without piping to it, a yank only
      # reaches the tmux buffer and nothing else on the desktop can paste it.

      bind -T copy-mode-vi v send -X begin-selection

      bind -T copy-mode-vi y send -X copy-pipe-and-cancel "wl-copy"

      bind -T copy-mode-vi Escape send -X cancel

      bind -T copy-mode-vi MouseDragEnd1Pane send -X copy-pipe-and-cancel "wl-copy"


      # --------------------------------------------------------
      # Reload
      # --------------------------------------------------------

      bind R source-file ~/.config/tmux/tmux.conf \; display-message "tmux reloaded"


      # --------------------------------------------------------
      # Aurora appearance
      # --------------------------------------------------------
      #
      # Sourced last so the generated theme wins over anything above it.
      #
      # -q keeps tmux quiet if the file is not there yet, which is the case on a
      # fresh machine until the home-manager activation has run and created the
      # active-tmux.conf symlink.
      #
      # This exact path is what `aurora-theme` re-sources to recolour a running
      # server, so appearance can be reloaded without rebuilding keybindings.

      source-file -q ~/.config/aurora/active-tmux.conf
    '';
  };
}
