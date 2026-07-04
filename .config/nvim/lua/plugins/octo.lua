---@type LazyPluginSpec
return {
	"pwntester/octo.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope.nvim",
		"nvim-tree/nvim-web-devicons",
	},
	-- 必要になったときだけロード（:Octo コマンド or <leader>o 系キー）
	cmd = "Octo",
	keys = {
		-- PR
		{ "<leader>op", "<cmd>Octo pr list<cr>", desc = "Octo: PR 一覧" },
		{ "<leader>oP", "<cmd>Octo pr search<cr>", desc = "Octo: PR 検索" },
		{ "<leader>oo", "<cmd>Octo pr checkout<cr>", desc = "Octo: PR を checkout" },
		{ "<leader>oc", "<cmd>Octo pr create<cr>", desc = "Octo: PR 作成" },
		-- レビュー（nvim 内で完結）
		{ "<leader>or", "<cmd>Octo review start<cr>", desc = "Octo: レビュー開始" },
		{ "<leader>oR", "<cmd>Octo review resume<cr>", desc = "Octo: レビュー再開" },
		{ "<leader>os", "<cmd>Octo review submit<cr>", desc = "Octo: レビュー提出" },
		{ "<leader>od", "<cmd>Octo review discard<cr>", desc = "Octo: レビュー破棄" },
		-- Issue
		{ "<leader>oi", "<cmd>Octo issue list<cr>", desc = "Octo: Issue 一覧" },
		{ "<leader>oI", "<cmd>Octo issue create<cr>", desc = "Octo: Issue 作成" },
		-- その他
		{ "<leader>oa", "<cmd>Octo actions<cr>", desc = "Octo: 全アクション一覧" },
		{ "<leader>ob", "<cmd>Octo pr browser<cr>", desc = "Octo: ブラウザで開く" },
	},
	opts = {
		picker = "telescope",
		-- レビューを見やすく
		default_to_projects_v2 = true,
		suppress_missing_scope = {
			projects_v2 = true,
		},
	},
	-- 主なバッファ内キー（octo デフォルト。レビュー/PR/Issue バッファで有効）:
	--   <space>ca  … コメント追加        <space>cd  … コメント削除
	--   ]c / [c    … 次/前のコメントへ    <space>ct  … スレッド解決/未解決の切替
	--   ]q / [q    … 次/前の差分ファイル（レビュー中）
	--   <C-a>      … approve             <C-r>      … request changes
	--   <C-m>      … comment のみで提出   <space>gi  … Issue/PR を開く
	--   <space>rp 👍 / <space>rh ❤ 等   … リアクション
	-- 一覧は :h octo-mappings、または <leader>oa で確認できるわ。
	config = function(_, opts)
		require("octo").setup(opts)
	end,
}
