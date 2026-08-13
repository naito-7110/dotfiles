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

-- 矩形ビジュアル（マルチカーソル）の代替キー。
-- WSL では wezterm が Ctrl+V をクリップボード画像の取り込みに使っており nvim まで届かないため。
vim.keymap.set({ "n", "v" }, "<leader>v", "<C-v>", { desc = "Visual block mode" })

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

-- dotnet build → quickfix。LSP とは別に、デプロイ先が受け付ける言語バージョンの確認や
-- ソリューション全体の最終確認に使う。
-- auto-save と組み合わせると保存ごとにビルドが走って重いので、自動化せず明示実行にしている。
vim.keymap.set("n", "<leader>bb", ":DotnetBuild<CR>", { silent = true, desc = "dotnet build → quickfix" })

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

-- HTML preview: カレントファイルのディレクトリで HTTP サーバーを起動しブラウザで開く
local preview_job_id = nil

local function stop_preview()
	if preview_job_id then
		vim.fn.jobstop(preview_job_id)
		preview_job_id = nil
	end
end

vim.keymap.set("n", "<leader>pv", function()
	local dir, filename

	local ok, oil = pcall(require, "oil")
	if ok and vim.bo.filetype == "oil" then
		dir = oil.get_current_dir()
		local entry = oil.get_cursor_entry()
		filename = entry and entry.name or ""
	else
		local bufpath = vim.fn.expand("%:p")
		if bufpath == "" then
			vim.notify("No file to preview", vim.log.levels.WARN)
			return
		end
		dir = vim.fn.fnamemodify(bufpath, ":h")
		filename = vim.fn.fnamemodify(bufpath, ":t")
	end

	stop_preview()
	preview_job_id = vim.fn.jobstart({ "preview", dir, filename }, {
		on_exit = function()
			preview_job_id = nil
		end,
	})
	vim.notify("Preview: http://localhost:8787/" .. filename)
end, { desc = "Preview HTML in browser" })

vim.api.nvim_create_autocmd("VimLeavePre", { callback = stop_preview })

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
vim.keymap.set("n", "<leader>dq", function()
	require("dap").terminate()
end, { desc = "DAP terminate" })
