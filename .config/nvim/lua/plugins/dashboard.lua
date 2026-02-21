return {
  "nvimdev/dashboard-nvim",
  event = "VimEnter",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local dashboard = require("dashboard")

    dashboard.setup({
      theme = "doom",
      config = {
        header = {
          "",
          "███╗   ██╗██╗   ██╗██╗███╗   ███╗",
          "████╗  ██║██║   ██║██║████╗ ████║",
          "██╔██╗ ██║██║   ██║██║██╔████╔██║",
          "██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║",
          "██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║",
          "╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝",
          "",
        },

        -- 真ん中：ボタン（actions はコマンド文字列）
        center = {
          { icon = "  ", desc = "Find files", key = "f", action = "Telescope find_files" },
          { icon = "󰈚  ", desc = "Live grep",  key = "g", action = "Telescope live_grep" },
          { icon = "  ", desc = "Recent files", key = "r", action = "Telescope oldfiles" },
          { icon = "  ", desc = "New file", key = "n", action = "enew" },
          { icon = "  ", desc = "Edit config", key = "c", action = "edit $MYVIMRC" },
          { icon = "󰒲  ", desc = "Lazy", key = "l", action = "Lazy" },
          { icon = "󰗼  ", desc = "Quit", key = "q", action = "qa" },
        },

        -- 下：起動情報（Lazy の stats を拾う）
        footer = function()
          local stats = require("lazy").stats()
          local ms = math.floor(stats.startuptime * 100 + 0.5) / 100
          return {
            "",
            ("  Loaded %d/%d plugins in %.2fms"):format(stats.loaded, stats.count, ms),
          }
        end,
      },
    })
  end,
}


