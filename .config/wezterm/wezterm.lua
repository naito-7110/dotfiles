local wezterm = require("wezterm")
local config = wezterm.config_builder()
local act = wezterm.action

config.automatically_reload_config = true
config.font_size = 12.0
config.line_height = 1.0
config.use_ime = true

-- 非アクティブなペインを暗くする
config.inactive_pane_hsb = {
	saturation = 0.8,
	brightness = 0.7,
}

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

-- tmux と指の動きをそろえるため、prefix は LEADER = C-q に統一。
-- mac は wezterm のペイン、WSL は tmux のペインを同じキーで操作できる。
config.leader = { key = "q", mods = "CTRL", timeout_milliseconds = 1000 }

config.keys = {
	-- 全画面（prefix なし、ウィンドウ単位）
	{ key = "f", mods = "CTRL|CMD", action = act.ToggleFullScreen },

	-- ペイン分割
	{ key = "\\", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "-", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },

	-- ペイン移動
	{ key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
	{ key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
	{ key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
	{ key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },

	-- ペイン削除・最大化
	{ key = "w", mods = "LEADER", action = act.CloseCurrentPane({ confirm = true }) },
	{ key = "z", mods = "LEADER", action = act.TogglePaneZoomState },
}

return config
