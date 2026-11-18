{
  pkgs,
  lib,
  config,
  zenoSrc,
  ...
}:
let
  # zeno のサーバー後始末は zshexit フック頼みで、tmux ペイン強制終了や WSL 停止では走らず
  # deno が PPID=1 の孤児として残り続ける。ソケット名 (zeno-<シェルPID>.sock) から親シェルの
  # PID を取り、そのシェルが消えたらサーバーも道連れにするラッパーを ZENO_SERVER_BIN に差す。
  zenoServerGuarded = pkgs.writeShellScriptBin "zeno-server-guarded" ''
    sock_name="''${ZENO_SOCK##*/}"
    owner="''${sock_name#zeno-}"
    owner="''${owner%.sock}"

    ${pkgs.deno}/bin/deno run --node-modules-dir=auto --no-check \
      --allow-env --allow-read --allow-run --allow-write --allow-ffi --allow-net \
      -- "$ZENO_ROOT/src/server.ts" "$@" &
    server=$!
    trap 'kill "$server" 2>/dev/null' TERM INT HUP

    # 数値でなければ監視せず server の終了だけ待つ
    if [[ "$owner" =~ ^[0-9]+$ ]]; then
      while kill -0 "$server" 2>/dev/null; do
        if ! kill -0 "$owner" 2>/dev/null; then
          kill "$server" 2>/dev/null
          break
        fi
        sleep 5
      done
    fi
    wait "$server"
  '';
in
{
  # zeno.zsh: Deno 製の zsh 統合プラグイン。フル機能はスペース(auto-snippet)/Tab(completion)/
  # Ctrl-R(history) を奪うが、ここは既存の zsh-abbr / fzf-tab / atuin を尊重して「共存」させる。
  # zeno には `zeno-insert-snippet`（プレースホルダ {{ }} 付きスニペットを fzf で挿入し、
  # 次のプレースホルダへジャンプできる）だけを Ctrl-Space に割り当てて純増で足す。
  #
  # zeno-bootstrap は deno が PATH に無いと即 return するので deno を同梱する。
  home.packages = [ pkgs.deno ];

  # zeno v0.4.1 から bin/zeno が `deno run --node-modules-dir=auto` を固定で渡すため、
  # Deno は workspace root（deno.json の場所 = ZENO_ROOT）に node_modules/.deno を作る。
  # flake input のまま store から直接 source すると root が読み取り専用になり
  # `Permission denied (os error 13)` がシェル起動のたびに出る。
  # そこで store のソースを書き込み可能な ~/.local/share/zeno へ複製し、
  # zeno-bootstrap が尊重する ZENO_ROOT をそこへ向ける（bin/src/node_modules 全てが複製側で動く）。
  # 初回起動時に deno が npm 依存を複製内 node_modules へ取得する（要ネットワーク・一度きり）。
  home.activation.zenoWritableRoot = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run rm -rf "${config.home.homeDirectory}/.local/share/zeno"
    run cp -rT ${zenoSrc} "${config.home.homeDirectory}/.local/share/zeno"
    run chmod -R u+w "${config.home.homeDirectory}/.local/share/zeno"
  '';

  # sessionVariables (hm-session-vars.sh) は __HM_SESS_VARS_SOURCED ガードで一度しか
  # 読まれないため、切替前から生きている tmux サーバー配下の新ペインでは ZENO_ROOT が
  # 未設定のまま store 直参照に戻ってしまう。ガードの外 (.zshenv) で毎回 export する。
  programs.zsh.envExtra = ''
    export ZENO_ROOT="${config.home.homeDirectory}/.local/share/zeno"
    export ZENO_SERVER_BIN="${zenoServerGuarded}/bin/zeno-server-guarded"
  '';

  programs.zsh.plugins = [
    {
      name = "zeno";
      src = zenoSrc;
      file = "zeno.zsh";
    }
  ];

  # ウィジェットは zeno-init が zle -N で定義するがキー割り当てはしない方針なので、
  # ここで Ctrl-Space(^@) にだけ束ねる。plugin ソース後に確実に効くよう mkAfter で最後に置く。
  # スニペット定義は ~/.config/zeno/config.yml（$XDG_CONFIG_HOME/zeno/config.yml）。
  programs.zsh.initContent = lib.mkAfter ''
    if [[ -n ''${ZENO_BOOTSTRAPPED-} ]]; then
      bindkey '^@' zeno-insert-snippet
      bindkey '^g' zeno-snippet-next-placeholder
    fi
  '';

  home.file.".config/zeno/config.yml".source = ../../.config/zeno/config.yml;
}
