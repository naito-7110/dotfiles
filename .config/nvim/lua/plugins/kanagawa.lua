return {
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
}
