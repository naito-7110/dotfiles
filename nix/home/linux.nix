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

  # Windows のスクショ (Win+Shift+S) はクリップボードに BI_BITFIELDS 形式の BMP として入り、
  # WSLg がそのまま Linux 側クリップボードへ橋渡しする。Claude Code はこの BMP 変種を
  # デコードできず、Ctrl+V / Alt+V での画像貼り付けが無言で失敗する。
  #
  # クリップボードに PNG を書き戻す方式は Claude 側のデコードに依存して不安定なため、
  # 「画像をファイルに保存し、その @パス をテキストとしてクリップボードへ入れる」方式を採る。
  # テキスト貼り付けは確実に動くので、Ctrl+V で `@/path/....png` が貼られ、
  # Claude Code が @ 参照でファイルから画像を読む。ffmpeg は BI_BITFIELDS も正しく読める。
  # 参考: https://qiita.com/k_izutani/items/98a5bc5601a7057ba51d
  clipimg = pkgs.writeShellScriptBin "clipimg" ''
    set -euo pipefail
    # WezTerm(Windows) から wsl.exe 経由で最小 PATH で呼ばれても date/mkdir/grep/find が
    # 解決できるよう、必要な coreutils 群を先頭に固定する。
    export PATH=${pkgs.coreutils}/bin:${pkgs.gnugrep}/bin:${pkgs.findutils}/bin:$PATH
    wl_paste=${pkgs.wl-clipboard}/bin/wl-paste
    wl_copy=${pkgs.wl-clipboard}/bin/wl-copy
    ffmpeg=${pkgs.ffmpeg}/bin/ffmpeg

    dir="''${XDG_CACHE_HOME:-$HOME/.cache}/claude-screenshots"
    mkdir -p "$dir"
    # 7日より古い保存済みスクショを掃除して溜め込みを防ぐ（~/.cache は破棄前提の領域）。
    find "$dir" -name 'ss_*.png' -mtime +7 -delete 2>/dev/null || true
    out="$dir/ss_$(date +%Y%m%d_%H%M%S).png"

    types=$("$wl_paste" --list-types 2>/dev/null || true)
    if printf '%s\n' "$types" | grep -qx 'image/png'; then
      "$wl_paste" --type image/png > "$out"
    elif printf '%s\n' "$types" | grep -qx 'image/bmp'; then
      "$wl_paste" --type image/bmp \
        | "$ffmpeg" -loglevel error -i pipe:0 -c:v png -f image2pipe pipe:1 > "$out"
    else
      echo "clipimg: クリップボードに画像がありません (types: ''${types:-none})" >&2
      exit 1
    fi

    # --stdout: @パスを stdout に出すだけ（WezTerm がこれを受け取りブラケットペーストする）。
    # 既定: @パスをクリップボードにも入れる（!clipimg を手動実行して Ctrl+V する用途）。
    if [ "''${1:-}" = "--stdout" ]; then
      printf '@%s' "$out"
    else
      printf '@%s' "$out" | "$wl_copy"
      echo "clipimg: $out を保存し、@パスをクリップボードに入れました。Ctrl+V で貼り付けてください。" >&2
    fi
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
  # （wezterm / vscode / docker は Windows 側で扱うため除外）
  # macOS は Xcode CLT が cc を提供するが、WSL には無いので gcc を入れる
  # （nvim-treesitter のパーサーコンパイルに必要）。
  # wl-clipboard は WSLg 経由で Windows clipboard と連携するため
  # （nvim の `+`/`*` レジスタと CLI の wl-copy/wl-paste 両方で使う）。
  home.packages = with pkgs; [
    gcc
    wl-clipboard
    wslview
    clipimg
  ];
}
