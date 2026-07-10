{ pkgs, ... }:
{
  # Neovim の config/lsp.lua が vim.lsp.enable するサーバのうち、
  # 「プロジェクトのツールチェインにバージョンを合わせる必要が無い」言語だけを
  # ここで宣言する。エディタ設定と一緒に持ち歩く前提の言語が対象。
  #
  # TypeScript / Vue / C# / Go / Rust / C・C++ などバージョン敏感なサーバは
  # ここに置かない。各プロジェクトの devShell（や node_modules）から供給し、
  # プロジェクトが pin したバージョンと一致させること。
  # 例: vue-language-server は @vue/typescript-plugin とメジャーを揃えないと
  #     hybrid-mode が壊れ、v-on / v-bind 補完が死ぬ。グローバル固定は厳禁。
  home.packages = with pkgs; [
    lua-language-server # lua_ls    (Lua)
    nil # nil_ls    (Nix)
    marksman # marksman  (Markdown)
    tinymist # tinymist  (Typst)
  ];
}
