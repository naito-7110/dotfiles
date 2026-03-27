
-- ファイルのクローズ設定
vim.keymap.set('n', '<SPACE>s', ':wq<CR>') -- saveして閉じる
vim.keymap.set('n', '<SPACE>q', ':q<CR>')  -- 閉じる
vim.keymap.set('n', '<SPACE>w', ':w<CR>')  -- saveする

-- キー移動10倍設定
vim.keymap.set({ 'n', 'v' }, 'J', '10j')
vim.keymap.set({ 'n', 'v' }, 'K', '10k')
vim.keymap.set({ 'n', 'v' }, 'H', '10h')
vim.keymap.set({ 'n', 'v' }, 'L', '10l')

-- 行入れ替え
vim.keymap.set('n', '<SPACE>k', 'ddkkp')
vim.keymap.set('n', '<SPACE>j', 'ddp')
vim.keymap.set({ 'i', 'v' }, '<C-e>', '<ESC>') -- 'Ctr'と'e'でnormal modeにする

-- プラグイン関係のkeymap
vim.keymap.set({ 'n', 'v' }, '<SPACE>f', ':Telescope find_files<CR>') -- ファイルファインダー
vim.keymap.set({ 'n', 'v' }, '<SPACE>g', ':Telescope live_grep<CR>')  -- グレップファインド
vim.keymap.set('n', '<C-w>', ':NvimTreeToggle<CR>')                   -- エクスプローラー
vim.keymap.set('n', '<C-s>', ':ASToggle<CR>', {})                     -- 自動保存
vim.keymap.set('n', '<SPACE><TAB>', ':Oil<CR>', {})                     -- 自動保存

-- lsp
vim.keymap.set("n", "<leader>e", function()
  vim.diagnostic.open_float(nil, { focus = false })
end, { desc = "Show diagnostics" })

-- LSP navigation
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "Show references" })
vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
vim.keymap.set("n", "gh", vim.lsp.buf.hover, { desc = "Hover information" })

-- LSP actions
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol" })
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })

-- Diagnostic navigation
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
