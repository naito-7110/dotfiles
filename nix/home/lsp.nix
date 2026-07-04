{ pkgs, ... }:
{
  # Neovim の config/lsp.lua が vim.lsp.enable するサーバ群を nix で宣言する。
  # ここが無いと新しいマシンで switch しても各言語を開いた瞬間 LSP が動かない
  # （＝再現性の穴）。lsp.lua の enable 対象と 1:1 で対応させること。
  home.packages = with pkgs; [
    gopls # gopls        (Go)
    rust-analyzer # rust_analyzer (Rust)
    clang-tools # clangd       (C / C++)
    lua-language-server # lua_ls       (Lua)
    nil # nil_ls       (Nix)
    marksman # marksman     (Markdown)
    tinymist # tinymist     (Typst)
    typescript-language-server # ts_ls        (TypeScript / Vue)
    vue-language-server # vue_ls       (Vue)
    vscode-langservers-extracted # jsonls       (JSON, vscode-json-language-server を含む)
    roslyn-ls # roslyn_ls    (C#, Microsoft.CodeAnalysis.LanguageServer)
  ];
}
