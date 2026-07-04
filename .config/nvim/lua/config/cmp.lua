local cmp = require("cmp")
local cmp_lsp = require("cmp_nvim_lsp")
local luasnip = require("luasnip")

-- 全LSPにcapabilitiesを適用（0.11系）
vim.lsp.config("*", {
	capabilities = cmp_lsp.default_capabilities(),
})

cmp.setup({
	completion = {
		autocomplete = { cmp.TriggerEvent.TextChanged },
	},

	-- スニペット展開器。これが無いと LSP が返すスニペット補完も展開できない。
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},

	mapping = cmp.mapping.preset.insert({
		["<C-n>"] = cmp.mapping.select_next_item(),
		["<C-p>"] = cmp.mapping.select_prev_item(),
		["<CR>"] = cmp.mapping.confirm({ select = true }),

		-- スニペットのプレースホルダ間を移動（<C-k>: 次へ/展開, <C-j>: 前へ）
		["<C-k>"] = cmp.mapping(function(fallback)
			if luasnip.expand_or_locally_jumpable() then
				luasnip.expand_or_jump()
			else
				fallback()
			end
		end, { "i", "s" }),
		["<C-j>"] = cmp.mapping(function(fallback)
			if luasnip.locally_jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, { "i", "s" }),
	}),

	sources = {
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
		{ name = "path" }, -- markdownリンク等のファイルパス補完
	},
})
