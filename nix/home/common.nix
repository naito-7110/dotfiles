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
    ./atuin.nix
    ./nh.nix
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
    # fzf / direnv / nix-direnv は programs.*.enable で入るのでここには重複させない。
    packages = with pkgs; [
      ripgrep
      fd
      jq
      yq-go
      mise
      kubectl
      gh
      git-secrets

      # モダン CLI 置換（eza/bat/fd/rg と同路線）。abbr は du/df/top を zsh.nix で張る。
      dust # du:  容量をバーグラフ付きツリーで
      duf # df:  ディスク使用量を色付きテーブルで
      procs # ps:  プロセスを色付き＋検索で（`procs <query>`）
      btop # top: 対話モニタ
      sd # sed: 置換特化のモダン文法（`sd 'foo' 'bar'`）
      tealdeer # tldr: コマンド使用例（`tldr tar`）

      pkgs-master.claude-code

      # Cornix キーマップ同期 (cornix push/pull/diff)。vitaly は nix/pkgs で自前ビルド
      (pkgs.callPackage ../pkgs/cornix-sync.nix {
        vitaly = pkgs.callPackage ../pkgs/vitaly.nix { };
      })

      ffmpeg
      poppler-utils

      # Neovim スタート画面のロゴアニメーション用 (tte)
      terminaltexteffects
    ];
  };
}
