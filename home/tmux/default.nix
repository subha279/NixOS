{ ... }:

{
  programs.tmux = {
    enable = true;
    sensibleOnTop = false;
    terminal = "tmux-256color";
    historyLimit = 50000;
    keyMode = "vi";
    mouse = true;
    baseIndex = 1;
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
