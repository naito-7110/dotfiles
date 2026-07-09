-- Windows(ホスト)側 WezTerm 設定の正本。
-- WSL の home-manager は $HOME 配下しか宣言的に管理できず、Windows の実ファイルは
-- 管理領域の外。そのため本ファイルを git 管理の正本とし、Windows へは手動でコピーする
-- （自動同期も実行時の host→WSL 参照もしない）。反映手順は README を参照。
--
-- 反映先: C:\Users\rsima\.config\wezterm\wezterm.lua
--   （WEZTERM_CONFIG_FILE がこのパスを指している）
-- コピー: cp ~/works/dotfiles/.config/wezterm/windows.lua \
--           /mnt/c/Users/rsima/.config/wezterm/wezterm.lua

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
		-- ブラケットペースト（@補完メニューを出さずリテラル挿入する）
		pane:send_text("\x1b[200~" .. path .. "\x1b[201~")
	else
		window:perform_action(wezterm.action.PasteFrom("Clipboard"), pane)
	end
end

config.keys = {
	{
		key = "v",
		mods = "CTRL",
		action = wezterm.action_callback(smart_paste),
	},
}

return config
