-- スタート画面 + tte によるロゴアニメーション
-- 参考: https://zenn.dev/vim_jp/articles/de942e6414685e (issue #12)

-- ロゴ (https://texteditor.com/multiline-text-art/ で作成されたものを拝借)
local logo = [[
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
━━━━━━━━ ▄▄    ▄ ▄▄▄▄▄▄▄ ▄▄▄▄▄▄▄ ▄▄   ▄▄ ▄▄ ▄▄   ▄▄ ━━━━━━━━
━━━━━━━━█  █  █ █       █       █  █ █  █  █  █▄█  █━━━━━━━━
━━━━━━━━█   █▄█ █    ▄▄▄█   ▄   █  █▄█  █  █       █━━━━━━━━
━━━━━━━━█       █   █▄▄▄█  █ █  █       █  █       █━━━━━━━━
━━━━━━━━█  ▄    █    ▄▄▄█  █▄█  █       █  █       █━━━━━━━━
━━━━━━━━█ █ █   █   █▄▄▄█       ██     ██  █ ██▄██ █━━━━━━━━
━━━━━━━━█▄█  █▄▄█▄▄▄▄▄▄▄█▄▄▄▄▄▄▄█ █▄▄▄█ █▄▄█▄█   █▄█━━━━━━━━
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
]]

-- 表示に使う tte のサブコマンド（アニメーション指定）からランダムに1個を使用
local subcommands = {
	"middleout --center-movement-speed 0.8 --full-movement-speed 0.2",
	"slide --merge --movement-speed 0.8",
	"beams --beam-delay 5 --beam-row-speed-range 20-60 --beam-column-speed-range 8-12",
}

-- ロゴをフローティングウィンドウに描画する
local function display_logo()
	local logo_lines = vim.split(vim.trim(logo), "\n")

	-- 描画用の空バッファ作成
	local buf = vim.api.nvim_create_buf(false, true)

	-- サイズと位置の指定
	local line_widths = vim.tbl_map(function(line)
		return vim.fn.strdisplaywidth(line)
	end, logo_lines)
	local width = math.max(unpack(line_widths))
	local height = #logo_lines + 1
	local row = 2
	local col = math.floor((vim.o.columns - width) / 2) -- 左右中央

	local win = vim.api.nvim_open_win(buf, false, {
		style = "minimal",
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		border = "none",
		focusable = false,
		noautocmd = true,
	})
	vim.api.nvim_set_option_value("winblend", 100, { scope = "local", win = win })
	-- 非表示になったら wipeout
	vim.api.nvim_set_option_value("bufhidden", "wipe", { scope = "local", buf = buf })

	if vim.fn.executable("tte") == 1 then
		math.randomseed(os.time())
		local subcommand = subcommands[math.random(#subcommands)]
		local cmd = {
			"sh",
			"-c",
			"printf '%s' "
				.. vim.fn.shellescape(vim.trim(logo))
				.. " | tte --anchor-canvas s "
				.. subcommand
				.. " --final-gradient-direction diagonal",
		}
		-- 作成したバッファをターミナルとしてコマンドを実行
		vim.api.nvim_buf_call(buf, function()
			vim.fn.jobstart(cmd, { term = true })
		end)
	else
		-- tte が無い環境では静止ロゴ表示にフォールバック
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, logo_lines)
	end

	return { buf = buf, win = win }
end

return {
	"nvim-mini/mini.starter",
	version = false,
	lazy = false,
	config = function()
		-- header に改行を入れてロゴの表示場所を確保する
		require("mini.starter").setup({
			header = string.rep("\n", 7),
		})

		local augroup = vim.api.nvim_create_augroup("start-logo", {})
		vim.api.nvim_create_autocmd("User", {
			group = augroup,
			pattern = "MiniStarterOpened",
			callback = function()
				local logo_info = display_logo()
				-- スタート画面を抜けたらロゴのウィンドウも閉じる
				-- (bufhidden=wipe なのでバッファも自動で破棄される)
				vim.api.nvim_create_autocmd("BufLeave", {
					group = augroup,
					once = true,
					buffer = vim.api.nvim_get_current_buf(),
					callback = function()
						if vim.api.nvim_win_is_valid(logo_info.win) then
							vim.api.nvim_win_close(logo_info.win, true)
						end
					end,
					desc = "Close logo",
				})
			end,
			desc = "Display logo when starter opened",
		})
	end,
}
