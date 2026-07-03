-- markdownをエディタ内で整形表示する (見出し・表・チェックボックス等)
return {
	"MeanderingProgrammer/render-markdown.nvim",
	ft = { "markdown" },
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-mini/mini.icons",
	},
	opts = {},
	keys = {
		{ "<leader>mr", "<cmd>RenderMarkdown toggle<cr>", desc = "Toggle markdown render" },
	},
}
