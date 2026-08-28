{ ... }:

{
  programs.zsh = {
    # Completion

    enableCompletion = true;

    # Autosuggestions

    autosuggestion.enable = true;

    # Syntax Highlighting

    syntaxHighlighting.enable = true;

    # History Substring Search

    historySubstringSearch.enable = true;

    # Completion Configuration

    initContent = ''
      # --------------------------------------------------
      # Syntax highlighting cost ceiling
      # --------------------------------------------------
      #
      # zsh-syntax-highlighting re-highlights the whole buffer on every keystroke,
      # so editing a very long line -- a pasted command, a long here-string --
      # gets visibly laggy. Past a few hundred characters the colouring is not
      # telling you anything useful, so stop doing it.

      ZSH_HIGHLIGHT_MAXLENGTH=512


      # --------------------------------------------------
      # Case-insensitive completion
      # --------------------------------------------------

      zstyle ':completion:*' matcher-list \
        'm:{a-z}={A-Za-z}'

      # --------------------------------------------------
      # Completion colors
      # --------------------------------------------------

      if [[ -n "$LS_COLORS" ]]; then
        zstyle ':completion:*' list-colors \
          "''${(s.:.)LS_COLORS}"
      fi

      # --------------------------------------------------
      # Let fzf-tab handle the completion menu
      # --------------------------------------------------

      zstyle ':completion:*' menu no

      # ==================================================
      # fzf-tab
      # ==================================================

      zstyle ':fzf-tab:*' use-fzf-default-opts yes

      # --------------------------------------------------
      # Directory preview
      # --------------------------------------------------

      zstyle ':fzf-tab:complete:cd:*' fzf-preview \
        'eza --tree --level=2 --icons --color=always $realpath'

      # --------------------------------------------------
      # File / directory preview
      # --------------------------------------------------

      zstyle ':fzf-tab:complete:*:*' fzf-preview \
        'if [[ -d $realpath ]]; then
          eza --tree --level=2 --icons --color=always $realpath
        elif [[ -f $realpath ]]; then
          bat --color=always --style=numbers,changes --line-range=:300 $realpath
        fi'

      # ==================================================
      # fzf-tab Keybindings
      # ==================================================
      #
      # Bound explicitly into viins rather than the current keymap. keybindings.nix
      # runs `bindkey -v`, which relinks main to viins and discards anything bound
      # to main beforehand -- so an unqualified `bindkey` here silently lost Tab
      # whenever this fragment was emitted first.

      # Tab
      bindkey -M viins '^I' fzf-tab-complete

      # Shift + Tab
      bindkey -M viins '^[[Z' reverse-menu-complete

      # ==================================================
      # Completion Behaviour
      # ==================================================

      setopt AUTO_MENU
      setopt COMPLETE_IN_WORD
      setopt ALWAYS_TO_END

      # --------------------------------------------------
      # Command correction
      # --------------------------------------------------

      setopt CORRECT
    '';
  };
}
