-- ####################
--    共通config
-- ####################
local opt = vim.opt

-- osのclipboradの連携設定
opt.clipboard:append('unnamedplus,unnamed')
opt.expandtab = true
opt.shiftround= true
opt.shiftwidth = 2
opt.softtabstop = 2
opt.tabstop = 2
opt.scrolloff = 3
opt.expandtab = true
opt.whichwrap = 'b,s,h,l,<,>,[,],~'
opt.swapfile = false
-- 行表示
vim.wo.number = true

vim.api.nvim_create_user_command(
  'InitLua',
  function()
    vim.cmd.edit(vim.fn.stdpath('config') .. '/init.lua')
  end,
  { desc = 'open init.lua'  }
)

-- ####################
--    keymap設定
-- ####################
local keymap = vim.keymap

-- ファイルのクローズ設定
keymap.set('n', '<SPACE>s', ':wq<CR>') -- saveして閉じる
keymap.set('n', '<SPACE>q', ':q<CR>')  -- 閉じる
keymap.set('n', '<SPACE>w', ':w<CR>')  -- saveする

-- キー移動10倍設定
keymap.set({ 'n', 'v' }, 'J', '10j')
keymap.set({ 'n', 'v' }, 'K', '10k')
keymap.set({ 'n', 'v' }, 'H', '10h')
keymap.set({ 'n', 'v' }, 'L', '10l')

-- 行入れ替え
keymap.set('n', '<SPACE>k', 'ddkkp')
keymap.set('n', '<SPACE>j', 'ddp')

keymap.set({ 'i', 'v' }, '<C-e>', '<ESC>') -- 'Ctr'と'e'でnormal modeにする

-- プラグイン関係のkeymap
keymap.set({ 'n', 'v' }, '<SPACE>f', ':Telescope find_files<CR>') -- ファイルファインダー
keymap.set({ 'n', 'v' }, '<SPACE>g', ':Telescope live_grep<CR>')  -- グレップファインド
keymap.set('n', '<C-w>', ':NvimTreeToggle<CR>')                   -- エクスプローラー
keymap.set('n', '<C-s>', ':ASToggle<CR>', {})                     -- 自動保存

-- ####################
--   plugin設定
-- ####################
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"


require("lazy").setup({
  spec = {
    -- thema
    {
      'rebelot/kanagawa.nvim',
        config = function()
          require('kanagawa').setup({
            transparent = true,
            colors = {
              palette = {
                sumiInk0 = "#000000",
                fujiWhite = "#FFFFFF",
              },
              theme = {
                dragon = {
                  syn = {
                    parameter = "yellow",
                  },
                }
              }
            }
          })

          vim.cmd("colorscheme kanagawa-dragon")
        end
    },
    -- Nvim Tree
    {
      "nvim-tree/nvim-tree.lua",
        version = "*",
        lazy = false,
        dependencies = {
          "nvim-tree/nvim-web-devicons",
        },
        config = function()
          require("nvim-tree").setup {
            sort = {
              sorter = "case_sensitive",
            },
            view = {
              width = 25,
            },
            renderer = {
              group_empty = true,
            },
            filters = {
              dotfiles = false,
              custom = {"^.git"}
            },
          }
        end,
    },
    -- Telescope
    {
      'nvim-telescope/telescope.nvim',
      tag = '0.1.6',
      dependencies = { 'nvim-lua/plenary.nvim' },
    },
    {
      'nvim-lualine/lualine.nvim',
      dependencies = { 'nvim-tree/nvim-web-devicons' },
    }
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})

require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'auto',
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    ignore_focus = {},
    always_divide_middle = true,
    always_show_tabline = true,
    globalstatus = false,
    refresh = {
      statusline = 1000,
      tabline = 1000,
      winbar = 1000,
      refresh_time = 16, -- ~60fps
      events = {
        'WinEnter',
        'BufEnter',
        'BufWritePost',
        'SessionLoadPost',
        'FileChangedShellPost',
        'VimResized',
        'Filetype',
        'CursorMoved',
        'CursorMovedI',
        'ModeChanged',
      },
    }
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = {'filename'},
    lualine_x = {'encoding', 'fileformat', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  winbar = {},
  inactive_winbar = {},
  extensions = {}
}
