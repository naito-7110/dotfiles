-- markdownをブラウザでライブプレビューする
-- build はプリビルドバイナリをダウンロードするので node 不要。
-- WSL では xdg-open (wslu/wslview) 経由で Windows 側ブラウザが開く。
return {
	"iamcco/markdown-preview.nvim",
	cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
	ft = { "markdown" },
	-- node 不要でプリビルドバイナリを同期ダウンロードする
	-- (mkdp#util#install は非同期かつ遅延ロードと相性が悪い)
	build = "cd app && ./install.sh",
	keys = {
		{ "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown preview (browser)" },
	},
}
