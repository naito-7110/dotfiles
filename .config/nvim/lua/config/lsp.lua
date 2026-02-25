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
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
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


vim.lsp.config("marksman", {
  filetypes = { "markdown" },
  cmd = { "marksman", "server"},
})

vim.lsp.enable("marksman")


-- In my lsp config file:

-- TypeScript Server with Vue Plugin
vim.lsp.config("ts_ls", {
  filetypes = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescriptreact",
    "typescript.tsx",
    "vue",
  },
  init_options = {
    plugins = {
      {
        name = "@vue/typescript-plugin",
        location = vim.env.HOME .. "$PWD/node_modules/@vue/typescript-plugin",
        languages = { "vue" },
      },
    },
  },
  cmd = { "typescript-language-server", "--stdio" },
  --capabilities = capabilities,
})

vim.lsp.enable("ts_ls")

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
