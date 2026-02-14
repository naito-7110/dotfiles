local cmp = require("cmp")
local cmp_lsp = require("cmp_nvim_lsp")

-- 全LSPにcapabilitiesを適用（0.11系）
vim.lsp.config("*", {
  capabilities = cmp_lsp.default_capabilities(),
})

cmp.setup({
  completion = {
    autocomplete = { cmp.TriggerEvent.TextChanged },
  },

  mapping = cmp.mapping.preset.insert({
    ["<C-n>"] = cmp.mapping.select_next_item(),
    ["<C-p>"] = cmp.mapping.select_prev_item(),
    ["<CR>"]  = cmp.mapping.confirm({ select = true }),
  }),

  sources = {
    { name = "nvim_lsp" },
  },
})
