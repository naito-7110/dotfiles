-- Windows(ホスト)側 WezTerm 設定の正本。
-- WSL の home-manager は $HOME 配下しか宣言的に管理できず、Windows の実ファイルは
-- 管理領域の外。Windows の User 環境変数 WEZTERM_CONFIG_FILE が本ファイルを
--   \\wsl.localhost\ubuntu-nix\home\naito-7110\works\dotfiles\.config\wezterm\windows.lua
-- として直接指しており、編集はそのままホストに反映される（\\wsl.localhost 越しは
-- 自動リロードが効かないことがあるので、反映されない時は Ctrl+Shift+R で再読込）。
--
-- 環境変数が無い起動経路では既定の探索先が読まれるため、フォールバックとして
-- 同内容のコピーを C:\Users\rsima\.config\wezterm\wezterm.lua にも置く。更新:
--   cp ~/works/dotfiles/.config/wezterm/windows.lua \
--      /mnt/c/Users/rsima/.config/wezterm/wezterm.lua
-- ※過去に手動コピー運用のみだった頃、コピー忘れでキーバインド欠落が再発したため
--   環境変数での直接参照に移行した(2026-09-03)。

local wezterm = require("wezterm")
local config = wezterm.config_builder()

local target = wezterm.target_triple

if target:find("windows") then
	config.default_prog = { "wsl.exe", "-d", "ubuntu-nix", "--cd", "~/works" }
end

config.automatically_reload_config = true
config.font_size = 12.0
config.use_ime = true
config.window_background_opacity = 0.75

config.window_decorations = "RESIZE"

config.window_frame = {
	inactive_titlebar_bg = "none",
	active_titlebar_bg = "none",
}

config.window_background_gradient = {
	colors = { "#000000" },
}

config.show_new_tab_button_in_tab_bar = false
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local background = "#5c6d74"
	local foreground = "#FFFFFF"

	if tab.is_active then
		background = "#ae8b2d"
		foreground = "#FFFFFF"
	end

	local title = "   " .. wezterm.truncate_right(tab.active_pane.title, max_width - 1) .. "   "

	return {
		{ Background = { Color = background } },
		{ Foreground = { Color = foreground } },
		{ Text = title },
	}
end)

-- Ctrl+V: クリップボードに画像があれば WSL 側 clipimg でファイル化し、その @パスを
-- ブラケットペーストで挿入する（Claude Code が @ 参照で画像を読む）。画像が無ければ
-- 従来どおりテキストを貼り付ける。Win+Shift+S のスクショは BI_BITFIELDS BMP で入り
-- Claude Code が直接デコードできないため、この経路で回避する。
local function smart_paste(window, pane)
	local ok, stdout = wezterm.run_child_process({
		"wsl.exe",
		"-d",
		"ubuntu-nix",
		"bash",
		"-c",
		'exec "$HOME/.nix-profile/bin/clipimg" --stdout',
	})
	local path = (ok and stdout or ""):gsub("%s+$", "")
	if #path > 0 then
		-- ブラケットペースト（@補完メニューを出さずリテラル挿入する）。
		-- 末尾スペースで @トークンを確定させる。これが無いと続けて打った文字が
		-- パスに連結されてファイル参照が壊れる上、カーソル下の @トークンに
		-- ファイル補完が反応し、IME 変換確定の Enter が補完確定に化けて
		-- パスが二重挿入される。
		pane:send_text("\x1b[200~" .. path .. " \x1b[201~")
	else
		window:perform_action(wezterm.action.PasteFrom("Clipboard"), pane)
	end
end

config.keys = {
	-- Ctrl+Enter はデフォルトで CR (Enter と同じ) になるため、
	-- LF (= Ctrl+J) を送って Claude Code などで改行として扱えるようにする
	{ key = "Enter", mods = "CTRL", action = wezterm.action.SendString("\n") },
	{
		key = "v",
		mods = "CTRL",
		action = wezterm.action_callback(smart_paste),
	},
}

return config
