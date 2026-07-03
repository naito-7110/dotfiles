-- クリップボードの画像をmarkdownに貼り付ける
-- 保存先は編集中ファイルからの相対 assets/ ディレクトリ
-- (WSL: wl-clipboard 経由で Windows クリップボードを読む / macOS: pngpaste 推奨)
return {
	"HakonHarnes/img-clip.nvim",
	event = "VeryLazy",
	opts = {
		default = {
			dir_path = "assets",
			relative_to_current_file = true,
			prompt_for_file_name = true,
		},
	},
	keys = {
		{ "<leader>mi", "<cmd>PasteImage<cr>", desc = "Paste image from clipboard" },
	},
}
