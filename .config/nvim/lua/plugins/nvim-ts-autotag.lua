return {
	"windwp/nvim-ts-autotag",
	event = "InsertEnter",
	opts = {
		opts = {
			enable_close = true, -- <div> → </div> 自動挿入
			enable_rename = true, -- タグ名変更時に閉じタグも連動
			enable_close_on_slash = true, -- <div>と入力後に/で</div>に変換
		},
	},
}
