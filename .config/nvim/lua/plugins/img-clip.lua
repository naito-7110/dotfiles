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
	config = function(_, opts)
		require("img-clip").setup(opts)

		-- markdownでは通常の p でも貼り付け可能にする:
		-- クリップボードが画像なら画像として保存+リンク挿入、それ以外は普通のペースト
		local function smart_paste_keymap(buf)
			vim.keymap.set("n", "p", function()
				-- paste_image() はテキストに対して警告を出すため、先に画像かどうかだけ判定する
				local clipboard = require("img-clip.clipboard")
				if clipboard.get_clip_cmd() and clipboard.content_is_image() then
					require("img-clip").paste_image()
					return
				end
				vim.cmd("normal! " .. vim.v.count1 .. '"' .. vim.v.register .. "p")
			end, { buffer = buf, desc = "Paste (image-aware)" })
		end

		vim.api.nvim_create_autocmd("FileType", {
			pattern = "markdown",
			group = vim.api.nvim_create_augroup("img_clip_smart_paste", { clear = true }),
			callback = function(args)
				smart_paste_keymap(args.buf)
			end,
		})

		-- VeryLazy 読み込み時点で既に開いている markdown バッファにも適用する
		for _, buf in ipairs(vim.api.nvim_list_bufs()) do
			if vim.bo[buf].filetype == "markdown" then
				smart_paste_keymap(buf)
			end
		end
	end,
}
