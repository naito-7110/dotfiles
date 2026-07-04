-- ファイルのクローズ設定
vim.keymap.set("n", "<SPACE>s", ":wq<CR>") -- saveして閉じる
vim.keymap.set("n", "<SPACE>q", ":q<CR>") -- 閉じる
vim.keymap.set("n", "<SPACE>w", ":w<CR>") -- saveする

-- キー移動10倍設定
vim.keymap.set({ "n", "v" }, "J", "10j")
vim.keymap.set({ "n", "v" }, "K", "10k")
vim.keymap.set({ "n", "v" }, "H", "10h")
vim.keymap.set({ "n", "v" }, "L", "10l")

-- 行入れ替え
vim.keymap.set("n", "<SPACE>k", "ddkkp")
vim.keymap.set("n", "<SPACE>j", "ddp")
vim.keymap.set({ "i", "v" }, "<C-e>", "<ESC>") -- 'Ctr'と'e'でnormal modeにする

-- プラグイン関係のkeymap
vim.keymap.set({ "n", "v" }, "<SPACE>f", ":Telescope find_files<CR>") -- ファイルファインダー
vim.keymap.set({ "n", "v" }, "<SPACE>g", ":Telescope live_grep<CR>") -- グレップファインド
-- <C-w> は Vim のウィンドウ操作プレフィックスなので上書きしない。
-- （nvim-tree は未導入で :NvimTreeToggle は無効コマンド。ファイラは oil.nvim を使う）
-- 自動保存トグル。<C-s> は端末のフロー制御(XOFF)でフリーズし得るため leader 配下に置く。
vim.keymap.set("n", "<leader>as", ":ASToggle<CR>", { silent = true, desc = "Toggle auto-save" }) -- 自動保存
vim.keymap.set("n", "<SPACE><TAB>", ":Oil<CR>", { silent = true, desc = "Open Oil" }) -- Oil

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

-- LSP log level toggle (OFF <-> DEBUG) and viewer
vim.keymap.set("n", "<leader>ll", function()
	local current = vim.lsp.log.get_level()
	if current == vim.log.levels.OFF then
		vim.lsp.set_log_level("DEBUG")
		vim.notify("LSP log level: DEBUG", vim.log.levels.INFO)
	else
		vim.lsp.set_log_level("OFF")
		vim.notify("LSP log level: OFF", vim.log.levels.INFO)
	end
end, { desc = "Toggle LSP log level (OFF/DEBUG)" })

vim.keymap.set("n", "<leader>lL", function()
	vim.cmd("edit " .. vim.lsp.get_log_path())
end, { desc = "Open LSP log file" })

-- DAP (debugger)
vim.keymap.set("n", "<leader>du", function()
	require("dapui").toggle()
end, { desc = "Toggle DAP UI" })
vim.keymap.set("n", "<leader>dc", function()
	require("dap").continue()
end, { desc = "DAP continue / start" })
vim.keymap.set("n", "<leader>db", function()
	require("dap").toggle_breakpoint()
end, { desc = "DAP toggle breakpoint" })
vim.keymap.set("n", "<leader>do", function()
	require("dap").step_over()
end, { desc = "DAP step over" })
vim.keymap.set("n", "<leader>di", function()
	require("dap").step_into()
end, { desc = "DAP step into" })
vim.keymap.set("n", "<leader>dO", function()
	require("dap").step_out()
end, { desc = "DAP step out" })
vim.keymap.set("n", "<leader>dr", function()
	require("dap").repl.toggle()
end, { desc = "DAP toggle REPL" })
