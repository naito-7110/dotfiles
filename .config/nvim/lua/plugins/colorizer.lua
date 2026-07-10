return {
	-- カラーコード（#RRGGBB, rgb(), hsl(), CSS 色名など）を
	-- その場で実際の色として表示する
	"catgoose/nvim-colorizer.lua",
	event = "BufReadPre",
	opts = {
		-- 対象ファイルタイプ（css/scss/js/ts/tsx などで有効化）
		filetypes = {
			"css",
			"scss",
			"sass",
			"less",
			"html",
			"javascript",
			"javascriptreact",
			"typescript",
			"typescriptreact",
			"vue",
			"lua",
		},
		user_default_options = {
			names = true, -- "Blue" などの色名も対象
			RGB = true, -- #RGB
			RRGGBB = true, -- #RRGGBB
			RRGGBBAA = true, -- #RRGGBBAA
			rgb_fn = true, -- rgb() / rgba()
			hsl_fn = true, -- hsl() / hsla()
			css = true, -- css 系機能を一括有効化
			css_fn = true, -- css の関数記法を有効化
			tailwind = true, -- Tailwind の色クラス
			mode = "background", -- 背景色として色を表示
		},
	},
}
