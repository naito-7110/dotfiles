{
  pkgs,
  pkgs-master,
  username,
  homeDirectory,
  ...
}:
{
  imports = [
    ./git.nix
    ./zsh.nix
    ./eza.nix
    ./zoxide.nix
    ./lazygit.nix
    ./tmux.nix
    ./lsp.nix
  ];

  programs = {
    starship.enable = true;
    # cat 置換。abbr の `cat = "bat -pp"` と MANPAGER から使う。
    bat.enable = true;
    neovim = {
      enable = true;
      # Ruby / Python3 の host provider は使わないので明示的に無効化する。
      # （stateVersion 26.05 で false が既定になる予定の non-legacy 挙動。警告も消える）
      withRuby = false;
      withPython3 = false;
    };
    fzf.enable = true;
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };

  home = {
    inherit username homeDirectory;
    stateVersion = "24.05";

    # man を bat で色付き表示する（col -bx で制御文字を落としてから渡す）。
    sessionVariables.MANPAGER = "sh -c 'col -bx | bat -l man -p'";

    file = {
      ".config/starship.toml".source = ../../.config/starship/starship.toml;
      ".config/nvim".source = ../../.config/nvim;
    };

    # OS非依存の共通パッケージ。OS固有は darwin.nix / linux.nix で追加する。
    packages = with pkgs; [
      direnv
      nix-direnv
      fzf
      ripgrep
      fd
      jq
      yq-go
      mise
      kubectl
      gh
      git-secrets

      pkgs-master.claude-code

      ffmpeg
      poppler-utils

      # Neovim スタート画面のロゴアニメーション用 (tte)
      terminaltexteffects
    ];
  };
}
