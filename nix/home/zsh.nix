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
      l = "ls -lah";

      gs = "git status";
      gl = "git log --oneline --graph --decorate --all";
    };

    initContent = ''
      # ---- history ----
      setopt hist_ignore_all_dups
      setopt hist_ignore_dups
      setopt hist_reduce_blanks
      setopt append_history
      setopt share_history
      setopt inc_append_history
      HISTFILE=$HOME/.zsh_history
      HISTSIZE=10000
      SAVEHIST=10000

      # --- options
      setopt auto_cd

      # zoxide の doctor は「自分の init が zshrc の最後じゃない」と警告するが、
      # home-manager は starship 等の integration を宣言的に後段へ並べるため
      # 順序が前後するだけで実害はない。宣言構成では誤検知なので無効化する。
      export _ZO_DOCTOR=0
    '';
  };
}
