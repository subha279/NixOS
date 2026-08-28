{ ... }:

{
  programs.zsh.initContent = ''
    # Zsh Vim Mode

    bindkey -v
    export KEYTIMEOUT=1

    # Vim Normal Mode

    bindkey -M vicmd 'h' backward-char
    bindkey -M vicmd 'j' down-line-or-history
    bindkey -M vicmd 'k' up-line-or-history
    bindkey -M vicmd 'l' forward-char

    bindkey -M vicmd 'w' forward-word
    bindkey -M vicmd 'b' backward-word
    bindkey -M vicmd 'e' forward-word-end

    bindkey -M vicmd '0' beginning-of-line
    bindkey -M vicmd '$' end-of-line

    # Keep your existing insert-mode shortcuts

    bindkey -M viins '^a' beginning-of-line
    bindkey -M viins '^e' end-of-line
    bindkey -M viins '^[b' backward-word
    bindkey -M viins '^[f' forward-word

    bindkey -M viins '^w' backward-kill-word
    bindkey -M viins '^u' backward-kill-line
    bindkey -M viins '^k' kill-line
    bindkey -M viins '^h' backward-delete-char

    bindkey -M viins '^p' history-substring-search-up
    bindkey -M viins '^n' history-substring-search-down

    # Tab / Shift-Tab are deliberately NOT bound here. completion.nix owns them
    # (fzf-tab-complete and reverse-menu-complete), and binding them in both files
    # meant the winner depended on whichever initContent fragment happened to be
    # emitted last -- so Tab sometimes fell back to plain expand-or-complete
    # instead of opening fzf-tab.

    bindkey -M viins '^l' clear-screen
    bindkey -M viins '^x^e' edit-command-line
    bindkey -M viins '^c' send-break

    # fzf

    # Ctrl-R → fzf history
    # Ctrl-T → fzf files
    # Alt-C  → fzf directories
  '';
}
