return {
	"nvim-treesitter/nvim-treesitter",
	branch = "master",
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
				"typst",
			},
			highlight = { enable = true },
			indent = { enable = true },
		})
	end,
}
