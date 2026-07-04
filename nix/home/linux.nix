{ pkgs, ... }:
let
  # wslu は上流がアーカイブされ nixpkgs から削除されたため、wslview だけを自前で再現する。
  # gh / octo などの browser opener は wslview（無ければ xdg-open）を探すので、同名で提供すれば
  # Windows 側の既定ブラウザで URL/ファイルを開ける。Start-Process は終了コードが素直。
  wslview = pkgs.writeShellScriptBin "wslview" ''
    if [ -z "$1" ]; then
      echo "usage: wslview <url|path>" >&2
      exit 1
    fi
    exec /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe \
      -NoProfile -Command "Start-Process -- '$1'"
  '';
in
{
  # WSL (Ubuntu) 上の standalone home-manager 用のホーム設定。
  # 共通部分は common.nix に集約し、ここでは WSL 固有の差分のみを足す。
  # username / homeDirectory は flake.nix の extraSpecialArgs から渡される。
  imports = [ ./common.nix ];

  # standalone home-manager では home-manager 自身も home-manager で管理する。
  programs.home-manager.enable = true;

  # gh / xdg-open / octo の <leader>ob などから Windows 既定ブラウザを開くため。
  home.sessionVariables.BROWSER = "wslview";

  # WSL 固有の追加パッケージ。
  # （wezterm / aerospace / vscode / docker は Windows 側で扱うため除外）
  # macOS は Xcode CLT が cc を提供するが、WSL には無いので gcc を入れる
  # （nvim-treesitter のパーサーコンパイルに必要）。
  # wl-clipboard は WSLg 経由で Windows clipboard と連携するため
  # （nvim の `+`/`*` レジスタと CLI の wl-copy/wl-paste 両方で使う）。
  home.packages = with pkgs; [
    gcc
    wl-clipboard
    wslview
  ];
}
