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
      # Ctrl-a — Prefix
      set -g prefix C-a
      bind C-a send-prefix

      # Ctrl-a h — Pane Left
      # Ctrl-a j — Pane Down
      # Ctrl-a k — Pane Up
      # Ctrl-a l — Pane Right
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # Ctrl-a H — Resize Left
      # Ctrl-a J — Resize Down
      # Ctrl-a K — Resize Up
      # Ctrl-a L — Resize Right
      bind H resize-pane -L 5
      bind J resize-pane -D 5
      bind K resize-pane -U 5
      bind L resize-pane -R 5

      # Ctrl-a | — Vertical Split
      # Ctrl-a - — Horizontal Split
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      # Ctrl-a " — Horizontal Split
      # Ctrl-a % — Vertical Split
      bind '"' split-window -v -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"

      # Ctrl-a c — New Window
      bind c new-window -c "#{pane_current_path}"

      # Ctrl-a n — Next Window
      # Ctrl-a p — Previous Window
      # Ctrl-a Tab — Last Window
      bind n next-window
      bind p previous-window
      bind Tab last-window

      # Ctrl-a 1-9 — Select Window
      # Ctrl-a z — Zoom Pane
      # Ctrl-a x — Kill Pane
      # Ctrl-a d — Detach
      # Ctrl-a q — Show Pane Numbers

      # Ctrl-a [ — Copy Mode
      # v — Begin Selection
      # y — Copy Selection
      # Escape — Cancel Selection
      # MouseDragEnd1Pane — Copy Selection
      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi y send -X copy-pipe-and-cancel "wl-copy"
      bind -T copy-mode-vi Escape send -X cancel
      bind -T copy-mode-vi MouseDragEnd1Pane send -X copy-pipe-and-cancel "wl-copy"

      # Ctrl-a R — Reload Config
      bind R source-file ~/.config/tmux/tmux.conf \; display-message "tmux reloaded"

      set -as terminal-features ",xterm-kitty:RGB:usstyle"
      set -as terminal-features ",xterm-256color:RGB:usstyle"
      set -as terminal-features ",foot:RGB:usstyle"

      setw -g pane-base-index 1
      set -g renumber-windows on
      set -g focus-events on
      setw -g aggressive-resize on

      source-file -q ~/.config/aurora/active-tmux.conf
    '';
  };
}
