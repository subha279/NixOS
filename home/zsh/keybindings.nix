{ ... }:

{
  programs.zsh.initContent = ''

    # Keybindings
    bindkey -e

    # Navigation
    bindkey '^a' beginning-of-line
    bindkey '^e' end-of-line
    bindkey '^[b' backward-word
    bindkey '^[f' forward-word

    # Editing
    bindkey '^w' backward-kill-word
    bindkey '^u' backward-kill-line
    bindkey '^k' kill-line
    bindkey '^h' backward-delete-char

    # History
    bindkey '^p' up-line-or-history
    bindkey '^n' down-line-or-history

    # Shell
    bindkey '^l' clear-screen
    bindkey '^x^e' edit-command-line
    bindkey '^c' send-break
  '';
}
