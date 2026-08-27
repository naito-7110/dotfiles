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

		-- タイムスタンプ挿入。VSCode 形式の変数では曜日が英語になり、
		-- 和訳には jsregexp（未導入）が要るため Lua で定義する。
		local ls = require("luasnip")
		local function timestamp()
			local wday = ({ "日", "月", "火", "水", "木", "金", "土" })[os.date("*t").wday]
			return os.date("%Y-%m-%d(" .. wday .. ") %H:%M")
		end
		ls.add_snippets("markdown", {
			ls.snippet({ trig = "now", desc = "timestamp: YYYY-MM-DD(曜) HH:MM" }, {
				ls.function_node(timestamp),
			}),
		})
	end,
}
