return {
  {
    "pwntester/octo.nvim",
    cmd = "Octo", -- 使う時だけロード
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("octo").setup()
    end,
  },
}
