return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	event = { "BufReadPost", "BufNewFile" },
	config = function()
		require("nvim-treesitter.configs").setup({
			ensure_installed = {
				"html",
				"vue",
				"javascript",
				"typescript",
				"tsx",
				"lua",
				"rust",
				"markdown",
				"json",
			},
			highlight = { enable = true },
			indent = { enable = true },
		})
	end,
}
