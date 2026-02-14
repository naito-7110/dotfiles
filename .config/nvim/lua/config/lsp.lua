-- Rust
vim.lsp.config("rust_analyzer", {
  cmd = { "rust-analyzer" },
  filetypes = { "rust" },
})

vim.lsp.enable("rust_analyzer")


-- Lua
vim.lsp.config("lua_ls", {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
    },
  },
})

vim.lsp.enable("lua_ls")


-- nix
vim.lsp.config("nil_ls", {
  cmd = { "nil" },
  filetypes = { "nix" },
})

vim.lsp.enable("nil_ls")


--メッセージ
vim.diagnostic.config({
  virtual_text = false,  -- 行末にゴチャゴチャ出さない
  signs = true,          -- 左側にアイコン表示
  underline = true,      -- 下線表示
  severity_sort = true,  -- 重要度順に並べる
  float = {
    border = "rounded",
    source = "always",
  },
})
