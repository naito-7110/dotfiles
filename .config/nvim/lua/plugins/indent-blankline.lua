return {
	"lukas-reineke/indent-blankline.nvim",
	main = "ibl",
	---@module "ibl"
	---@type ibl.config
	config = function()
		-- インデントレベルごとに循環させる色（青系ターミナルでも埋もれないよう
		-- 青を避けた、彩度控えめの暖色寄りパレット）
		local highlight = {
			"IblIndent1",
			"IblIndent2",
			"IblIndent3",
			"IblIndent4",
			"IblIndent5",
			"IblIndent6",
		}

		local hooks = require("ibl.hooks")
		hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
			vim.api.nvim_set_hl(0, "IblIndent1", { fg = "#a3705d" }) -- テラコッタ
			vim.api.nvim_set_hl(0, "IblIndent2", { fg = "#b0894b" }) -- アンバー
			vim.api.nvim_set_hl(0, "IblIndent3", { fg = "#7d9a5f" }) -- オリーブ
			vim.api.nvim_set_hl(0, "IblIndent4", { fg = "#5f9a8a" }) -- ティール
			vim.api.nvim_set_hl(0, "IblIndent5", { fg = "#9a7bb0" }) -- モーヴ
			vim.api.nvim_set_hl(0, "IblIndent6", { fg = "#b06d8a" }) -- ローズ
		end)

		require("ibl").setup({
			indent = { highlight = highlight },
		})
	end,
}
