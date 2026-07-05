local wezterm = require("wezterm")
local config = wezterm.config_builder()
local act = wezterm.action

config.automatically_reload_config = true
config.font_size = 12.0
config.line_height = 1.0
config.use_ime = true

-- macOS では ~/works を起点に tmux へ自動アタッチ (セッション名: main)
-- tmux は nix 管理のため PATH 解決にログインシェルを経由する
if wezterm.target_triple:find("apple%-darwin") then
	config.default_cwd = wezterm.home_dir .. "/works"
	config.default_prog = { "/bin/zsh", "-l", "-c", "exec tmux new-session -A -s main" }
end

-- 透過設定
local default_opacity = 0.65
local min_opacity = 0.5
local max_opacity = 1.0
local opacity = default_opacity
config.window_background_opacity = default_opacity
config.macos_window_background_blur = 0

function adjust_opacity(window, delta)
	opacity = math.max(max_opacity, math.min(min_opacity, opacity + delta))

	window:set_config_overrides({
		window_background_opacity = opacity,
	})
end

wezterm.on("increase-opacity", function(window, _)
	adjust_opacity(window, 0.05)
end)

wezterm.on("decrease-opacity", function(window, _)
	adjust_opacity(window, -0.05)
end)

-- ペイン操作は tmux (prefix = C-q) に一本化。wezterm 側で C-q を奪わないよう
-- leader やペイン系バインドは持たない。
config.keys = {
	-- 全画面（ウィンドウ単位）
	{ key = "f", mods = "CTRL|CMD", action = act.ToggleFullScreen },

	-- Ctrl+Enter はデフォルトで CR (Enter と同じ) になるため、
	-- LF (= Ctrl+J) を送って Claude Code などで改行として扱えるようにする
	{ key = "Enter", mods = "CTRL", action = act.SendString("\n") },
}

return config
