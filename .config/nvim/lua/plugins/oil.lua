-- 非表示ディレクトリ
local hidden_dirs = {
  ".git",
  "node_modules",
  ".DS_Store",
}

local hidden_set = {}
for _, name in ipairs(hidden_dirs) do
  hidden_set[name] = true
end

return {
  'stevearc/oil.nvim',
  ---@module 'oil'
  ---@type oil.SetupOpts
  -- Optional dependencies
  dependencies = { { "nvim-mini/mini.icons", opts = {} } },
  -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
  -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
  lazy = false,
  opts = {
    view_options = {
      show_hidden = true,
      is_always_hidden = function(name, _)
        return hidden_set[name] or false
      end,
    }
  }
}
