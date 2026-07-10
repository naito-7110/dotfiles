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
			-- css = true はまとめ有効化で names(色名)も強制 ON にしてしまい、
			-- コメントや変数名の "red"/"blue" まで色付いて邪魔なので使わない。
			-- コード形式(hex / rgb / hsl)だけを個別に有効化する。
			names = false, -- "Blue" などの色名は対象にしない
			RGB = true, -- #RGB
			RRGGBB = true, -- #RRGGBB
			RRGGBBAA = true, -- #RRGGBBAA
			rgb_fn = true, -- rgb() / rgba()
			hsl_fn = true, -- hsl() / hsla()
			tailwind = true, -- Tailwind の色クラス
			mode = "background", -- 背景色として色を表示
		},
	},
}
