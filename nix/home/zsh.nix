{ ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    shellAliases = {
      vim = "nvim";
      vi = "nvim";
      v = "nvim";

      c = "clear";

      gs = "git status";
      gl = "git log --oneline --graph --decorate --all";
    };

    initExtra = ''
      # ---- history ----
      setopt hist_ignore_all_dups
      setopt hist_ignore_dups
      setopt hist_reduce_blanks
      setopt append_history
      setopt share_history

      HISTFILE=$HOME/.zsh_history
      HISTSIZE=10000
      SAVEHIST=10000
    '';
  }; 
}
