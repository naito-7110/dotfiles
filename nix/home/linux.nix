{ pkgs, ... }:
{
  # WSL (Ubuntu) 上の standalone home-manager 用のホーム設定。
  # 共通部分は common.nix に集約し、ここでは WSL 固有の差分のみを足す。
  # username / homeDirectory は flake.nix の extraSpecialArgs から渡される。
  imports = [ ./common.nix ];

  # standalone home-manager では home-manager 自身も home-manager で管理する。
  programs.home-manager.enable = true;

  # WSL 固有の追加パッケージ。
  # （wezterm / aerospace / vscode / docker は Windows 側で扱うため除外）
  # macOS は Xcode CLT が cc を提供するが、WSL には無いので gcc を入れる
  # （nvim-treesitter のパーサーコンパイルに必要）。
  # wl-clipboard は WSLg 経由で Windows clipboard と連携するため
  # （nvim の `+`/`*` レジスタと CLI の wl-copy/wl-paste 両方で使う）。
  # wslu は wslview を提供し、xdg-open / gh などの browser opener 経由で
  # Windows 側の既定ブラウザを開けるようにする。
  home.packages = with pkgs; [
    gcc
    wl-clipboard
    wslu
  ];
}
