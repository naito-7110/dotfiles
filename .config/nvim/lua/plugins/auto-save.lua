return {
	"Pocco81/auto-save.nvim",
	event = { "InsertLeave", "TextChanged" },
	config = function()
		require("auto-save").setup({
			enabled = true,
			-- :noautocmd w でフォーマットをスキップ
			save_cmd = "silent! noautocmd w",
		})
	end,
}
