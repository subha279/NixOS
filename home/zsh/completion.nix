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

      # Tab
      bindkey '^I' fzf-tab-complete

      # Shift + Tab
      bindkey '^[[Z' reverse-menu-complete

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
