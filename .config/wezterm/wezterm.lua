local wezterm = require 'wezterm'
local config = wezterm.config_builder()
local act = wezterm.action

config.automatically_reload_config = true
config.font_size = 12.0
config.line_height = 1.0
config.use_ime = true
config.window_background_opacity = 0.70

-- 非アクティブなペインを暗くする
config.inactive_pane_hsb = {
  saturation = 0.8,
  brightness = 0.7,
}


-- keybind
config.keys = {
  -- weztermのFullScreen展開
  { key = 'f', mods = 'CTRL|CMD', action = act.ToggleFullScreen },

  -- ペイン操作
  { key = '\\', mods = 'CMD', action = act.SplitHorizontal { domain = "CurrentPaneDomain"} },
  { key = '-', mods = 'CMD', action = act.SplitVertical { domain = "CurrentPaneDomain"} },

  -- ペイン移動
  { key = 'h', mods = 'CMD', action = act.ActivatePaneDirection "Left" },
  { key = 'j', mods = 'CMD', action = act.ActivatePaneDirection "Down" },
  { key = 'k', mods = 'CMD', action = act.ActivatePaneDirection "Up" },
  { key = 'l', mods = 'CMD', action = act.ActivatePaneDirection "Right" },

  -- ペイン削除（閉じる）
  { key = 'w', mods = 'CMD', action = act.CloseCurrentPane { confirm = true } },

  -- ペイン最大化（トグルズーム）
  { key = 'z', mods = 'CMD', action = act.TogglePaneZoomState },
}

return config
