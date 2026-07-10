-- markdown の TODO チェックボックスをトグルする ([ ] <-> [x])。
-- <leader>x で現在行、ビジュアル選択中は選択範囲すべてに適用する。

-- 1 行を受け取り、状態に応じてトグルした行を返す。
local function toggle_line(line)
	if line:match("%[[xX]%]") then
		-- チェック済み -> 未チェック
		return (line:gsub("%[[xX]%]", "[ ]", 1))
	elseif line:match("%[ %]") then
		-- 未チェック -> チェック済み
		return (line:gsub("%[ %]", "[x]", 1))
	elseif line:match("^%s*[-*+]%s+") then
		-- チェックボックス無しのリスト項目 -> チェックボックスを付与
		return (line:gsub("^(%s*[-*+]%s+)", "%1[ ] ", 1))
	elseif line:match("%S") then
		-- 通常行 -> チェックボックス付きリストにする（先頭インデントは維持）
		return (line:gsub("^(%s*)", "%1- [ ] ", 1))
	else
		-- 空行はそのまま
		return line
	end
end

-- s..e（1 始まり・両端含む）の各行をトグルする。
local function toggle_range(s, e)
	local lines = vim.api.nvim_buf_get_lines(0, s - 1, e, false)
	for i, line in ipairs(lines) do
		lines[i] = toggle_line(line)
	end
	vim.api.nvim_buf_set_lines(0, s - 1, e, false, lines)
end

-- normal: 現在行
vim.keymap.set("n", "<leader>x", function()
	local lnum = vim.api.nvim_win_get_cursor(0)[1]
	toggle_range(lnum, lnum)
end, { buffer = true, silent = true, desc = "Toggle markdown checkbox" })

-- visual: 選択範囲（選択解除して normal に戻す）
vim.keymap.set("x", "<leader>x", function()
	local s = vim.fn.line("v")
	local e = vim.fn.line(".")
	if s > e then
		s, e = e, s
	end
	toggle_range(s, e)
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
end, { buffer = true, silent = true, desc = "Toggle markdown checkbox" })
