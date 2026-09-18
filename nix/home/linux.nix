{
  config,
  pkgs,
  lib,
  ...
}:
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
    # 手動経路は末尾スペース付きで入れる（@トークンを確定させ、後続入力の連結と
    # ファイル補完の暴発を防ぐ。WezTerm 経路は windows.lua 側でスペースを付ける）。
    if [ "''${1:-}" = "--stdout" ]; then
      printf '@%s' "$out"
    else
      printf '@%s ' "$out" | "$wl_copy"
      echo "clipimg: $out を保存し、@パスをクリップボードに入れました。Ctrl+V で貼り付けてください。" >&2
    fi
  '';
  # Windows 側の Chrome を occlusion 検出無効で起動する。
  # Chrome は他ウィンドウに完全に覆われると描画を止めるが、この判定は透明度を見ない。
  # そのため透過 wezterm を重ねると「隠れた」扱いで描画停止し、透過越しの動画が
  # 真っ黒になる。CalculateNativeWinOcclusion を切ると覆われても描画を続ける。
  # 注意: フラグはプロセス起動時にしか効かない。Chrome が既に起動中だと
  # 既存プロセスに新規ウィンドウが乗るだけなので、完全終了してから使うこと。
  chrome = pkgs.writeShellScriptBin "chrome" ''
    # cmd.exe は Linux 側 cwd を UNC パスとして扱えず警告を出すので /mnt/c へ移る。
    cd /mnt/c
    exec /mnt/c/Windows/System32/cmd.exe /c start "" chrome \
      --disable-features=CalculateNativeWinOcclusion "$@"
  '';

  # Windows ホストの WezTerm 設定読み込み（詳細は .config/wezterm/windows.lua 冒頭）:
  #   1. User 環境変数 WEZTERM_CONFIG_FILE がリポジトリの windows.lua を \\wsl.localhost
  #      経由で直接指す（正）
  #   2. 環境変数が無い起動経路向けに %USERPROFILE%\.config\wezterm\wezterm.lua へ
  #      同内容のコピーを置く（フォールバック）
  # どちらも HKCU / Windows FS 上にあり home-manager の管理外なので、switch のたびに
  # PowerShell で冪等に突き合わせる。環境変数の書き込みは WM_SETTINGCHANGE を
  # broadcast するため、値が違うときだけ行う。
  weztermHostPs1 = pkgs.writeText "wezterm-host-config.ps1" ''
    param([string]$ConfigPath)
    $ErrorActionPreference = 'Stop'
    if ([Environment]::GetEnvironmentVariable('WEZTERM_CONFIG_FILE', 'User') -ne $ConfigPath) {
      [Environment]::SetEnvironmentVariable('WEZTERM_CONFIG_FILE', $ConfigPath, 'User')
      Write-Host "wezterm: WEZTERM_CONFIG_FILE (User) -> $ConfigPath"
    }
    $dst = Join-Path $env:USERPROFILE '.config\wezterm\wezterm.lua'
    if (!(Test-Path $dst) -or (Get-FileHash $ConfigPath).Hash -ne (Get-FileHash $dst).Hash) {
      New-Item -ItemType Directory -Force (Split-Path $dst) | Out-Null
      Copy-Item $ConfigPath $dst -Force
      Write-Host "wezterm: フォールバックコピーを更新 -> $dst"
    }
  '';

  weztermHostConfig = pkgs.writeShellScript "wezterm-host-config" ''
    set -eu
    ps=/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe
    cfg="$HOME/works/dotfiles/.config/wezterm/windows.lua"
    # interop 無効環境やリポジトリ未 clone 時は黙ってスキップ
    if [ ! -x "$ps" ] || [ ! -f "$cfg" ]; then
      exit 0
    fi
    # Windows 側の一時的な不調で switch 全体を落とさない
    if ! "$ps" -NoProfile -ExecutionPolicy Bypass \
        -File "$(/usr/bin/wslpath -w ${weztermHostPs1})" \
        "$(/usr/bin/wslpath -w "$cfg")"; then
      echo "wezterm-host-config: Windows 側の反映に失敗しました（無視して続行）" >&2
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

  # 一時ディレクトリを tmpfs (/tmp) から実ディスクへ逃がす。
  # nix develop / nix-shell は起動時の TMPDIR を基点に nix-shell.XXXX を作るが、
  # これを終了時に消さない（異常終了時だけでなく正常終了でも残る。クリーンな
  # `nix develop --command true` を 3 回実行して 3 個とも残ることを実測で確認）。
  # WSL の /tmp は tmpfs すなわち実メモリなので、direnv が cd のたびに devShell へ
  # 入り直す運用では約 250 個/日のペースでメモリを食い潰す。実際 10 日で 1509 個・
  # 3.5GB まで育ち、swap を満杯にして 2026-09-09 に OOM で tmux ペインが落ちた。
  # TMPDIR をディスク上に向けると、同じ量が漏れてもメモリは 1 バイトも減らない。
  # 実測では tmpfs との速度差は逐次書き込みで 1.23 倍・小ファイル 3000 個で 1.15 倍と
  # 小さく（WSL2 の rootfs が NVMe 上の ext4 のため）、page cache に載るぶん
  # メモリ逼迫時はむしろ有利。
  # 注意: /tmp を離れるので systemd-tmpfiles の 10d 掃除が効かない。溜まり続けるため
  # 別途この配下の定期削除が要る（ディスクなので緊急性は低い）。
  home.sessionVariables.TMPDIR = "${config.home.homeDirectory}/.cache/nix-tmp";

  home.activation.ensureNixTmpDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p ${config.home.homeDirectory}/.cache/nix-tmp
  '';

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
    chrome
  ];

  home.activation.weztermHostConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${weztermHostConfig}
  '';
}
