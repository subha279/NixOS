{ ... }:

{
  programs.zsh.initContent= ''
    # ==================================================
    # Zsh Keybindings
    # ==================================================

    bindkey -e

    # ==================================================
    # Cursor Movement
    # ==================================================

    # Beginning of line
    bindkey '^a' beginning-of-line

    # End of line
    bindkey '^e' end-of-line

    # Previous word
    bindkey '^[b' backward-word

    # Next word
    bindkey '^[f' forward-word

    # ==================================================
    # Editing
    # ==================================================

    # Delete previous word
    bindkey '^w' backward-kill-word

    # Delete everything before cursor
    bindkey '^u' backward-kill-line

    # Delete everything after cursor
    bindkey '^k' kill-line

    # Delete previous character
    bindkey '^h' backward-delete-char

    # ==================================================
    # History
    # ==================================================

    # Previous matching history entry
    bindkey '^p' history-substring-search-up

    # Next matching history entry
    bindkey '^n' history-substring-search-down

    # ==================================================
    # Completion
    # ==================================================

    # Tab
    bindkey '^i' expand-or-complete

    # Shift + Tab
    bindkey '^[[Z' reverse-menu-complete

    # ==================================================
    # Screen
    # ==================================================

    # Clear screen
    bindkey '^l' clear-screen

    # ==================================================
    # Command Editor
    # ==================================================

    # Edit current command in $EDITOR
    bindkey '^x^e' edit-command-line

    # ==================================================
    # Cancel
    # ==================================================

    bindkey '^c' send-break

    # ==================================================
    # fzf
    # ==================================================

    # These are intentionally documented here.
    #
    # Ctrl-R → fzf history
    # Ctrl-T → fzf files
    # Alt-C  → fzf directories
    #
    # fzf's native Zsh integration installs these.
  '';
}
