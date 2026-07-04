return {
	"L3MON4D3/LuaSnip",
	version = "v2.*",
	-- jsregexp（正規表現変換）はビルドが失敗しやすく、使わない限り不要なので入れない。
	config = function()
		-- リポジトリ内 snippets/ の VSCode 形式 JSON を、filetype ごとに遅延ロードする。
		-- 配置先は stdpath("config")/snippets = ~/.config/nvim/snippets（switch で配備）。
		require("luasnip.loaders.from_vscode").lazy_load({
			paths = { vim.fn.stdpath("config") .. "/snippets" },
		})
	end,
}
