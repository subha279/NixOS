{ ... }:

{
  programs.zsh = {
    enableCompletion = true;

    # Autosuggestions
    autosuggestion.enable = true;

    # Syntax highlighting
    syntaxHighlighting.enable = true;

    # History substring search
    historySubstringSearch.enable = true;

    initContent = ''
      # Completion
      ZSH_HIGHLIGHT_MAXLENGTH=512

      # Case-insensitive completion
      zstyle ':completion:*' matcher-list \
        'm:{a-z}={A-Za-z}'

      # Completion colors
      if [[ -n "$LS_COLORS" ]]; then
        zstyle ':completion:*' list-colors \
          "''${(s.:.)LS_COLORS}"
      fi

      # Let fzf-tab control the completion menu
      zstyle ':completion:*' menu no

      # fzf-tab
      zstyle ':fzf-tab:*' use-fzf-default-opts yes

      # Directory preview
      zstyle ':fzf-tab:complete:cd:*' fzf-preview \
        'eza --tree --level=2 --icons --color=always $realpath'

      # File / directory preview
      zstyle ':fzf-tab:complete:*:*' fzf-preview \
        'if [[ -d $realpath ]]; then
          eza --tree --level=2 --icons --color=always $realpath
        elif [[ -f $realpath ]]; then
          bat --color=always --style=numbers,changes --line-range=:300 $realpath
        fi'

      # fzf-tab keybindings

      # Tab
      bindkey '^I' fzf-tab-complete

      # Shift + Tab
      bindkey '^[[Z' reverse-menu-complete

      # Completion behaviour
      setopt AUTO_MENU
      setopt COMPLETE_IN_WORD
      setopt ALWAYS_TO_END
    '';
  };
}
