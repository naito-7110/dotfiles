{
  pkgs,
  lib,
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
  # 初回シェル起動時に deno が jsr/npm 依存を ~/.cache/deno へ取得する（要ネットワーク・一度きり）。
  home.packages = [ pkgs.deno ];

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
