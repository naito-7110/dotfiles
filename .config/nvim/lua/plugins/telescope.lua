---@type LazyPluginSpec
return {
    'nvim-telescope/telescope.nvim', 
    branch = '0.1.x',
    dependencies = { 'nvim-lua/plenary.nvim' },
    event = 'VeryLazy',
    config = function()
      require("telescope").setup({
        defaults = {
          file_ignore_patterns = {
            "%.git/",
            "node_modules/",
            "target/",
            "obj/",
            "bin/",
            "dist/",
            "%.DS_Store"
          },
        },
        pickers = {
          find_files = {
            hidden = true
          },
          live_grep = {
            additional_args = function()
              return { "--hidden" }
            end
          }
        },
      })

      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>f", builtin.find_files, { desc = "Find files" })
      vim.keymap.set("n", "<leader>g", builtin.live_grep, { desc = "Live grep" })
      vim.keymap.set("n", "<leader>b", builtin.buffers, { desc = "Find buffers" })
    end
}
