---@type LazyPluginSpec
return {
  'akinsho/toggleterm.nvim',
  version = '*',
  config = function()
    require('toggleterm').setup()
    local Terminal = require('toggleterm.terminal').Terminal
    local lazygit = Terminal:new {
      cmd = 'lazygit',
      direction = 'float',
      hidden = true,
    }

    vim.keymap.set({ 'n', 't' }, '<SPACE>\\', function()
      lazygit:toggle()
    end, { desc = 'Toggle Lazygit (float)' })

--    local shellName = vim.fn.has("win64") and "pwsh" or "zsh"
    local shellName = "zsh"

    local shell = Terminal:new {
      cmd = shellName,
      direction = 'float',
      hidden = true,
    }

    vim.keymap.set({'n'}, '<SPACE>z', function()
      shell:toggle()
    end, { desc = "ToggleTerm(" .. shellName .. ")"})
  end,
}
