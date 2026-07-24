{
  pkgs,
  lib,
  config,
  zenoSrc,
  ...
}:
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

  home.sessionVariables.ZENO_ROOT = "${config.home.homeDirectory}/.local/share/zeno";

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
