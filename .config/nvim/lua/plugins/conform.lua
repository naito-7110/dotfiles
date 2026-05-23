return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	keys = {
		{
			"<leader>cf",
			function()
				require("conform").format({ async = true, lsp_fallback = true })
			end,
			desc = "Format buffer",
		},
	},
	opts = {
		formatters_by_ft = {
			javascript = { "oxfmt", "biome", "eslint_d", "prettierd", "prettier", stop_after_first = true },
			typescript = { "oxfmt", "biome", "eslint_d", "prettierd", "prettier", stop_after_first = true },
			javascriptreact = { "oxfmt", "biome", "eslint_d", "prettierd", "prettier", stop_after_first = true },
			typescriptreact = { "oxfmt", "biome", "eslint_d", "prettierd", "prettier", stop_after_first = true },
			vue = { "oxfmt", "eslint_d", "prettierd", "prettier", stop_after_first = true },
			json = { "biome", "prettierd", "prettier", stop_after_first = true },
			jsonc = { "biome", "prettierd", "prettier", stop_after_first = true },
			css = { "prettierd", "prettier", stop_after_first = true },
			html = { "prettierd", "prettier", stop_after_first = true },
			markdown = { "prettierd", "prettier", stop_after_first = true },
			yaml = { "prettierd", "prettier", stop_after_first = true },
			lua = { "stylua" },
			rust = { "rustfmt" },
			nix = { "nixfmt" },
		},
		format_on_save = {
			timeout_ms = 1000,
			lsp_fallback = true,
		},
		formatters = {
			oxfmt = {
				condition = function(_, ctx)
					return vim.fs.find({ "oxfmt.config.ts" }, { path = ctx.filename, upward = true })[1] ~= nil
				end,
			},
			biome = {
				condition = function(_, ctx)
					return vim.fs.find({ "biome.json", "biome.jsonc" }, { path = ctx.filename, upward = true })[1]
						~= nil
				end,
			},
			eslint_d = {
				condition = function(_, ctx)
					-- oxfmt/biome がある場合は使わない
					if vim.fs.find({ ".oxfmtrc.json", "biome.json" }, { path = ctx.filename, upward = true })[1] then
						return false
					end
					return vim.fs.find({
						".eslintrc",
						".eslintrc.json",
						".eslintrc.js",
						".eslintrc.cjs",
						"eslint.config.js",
						"eslint.config.mjs",
					}, { path = ctx.filename, upward = true })[1] ~= nil
				end,
			},
			prettierd = {
				condition = function(_, ctx)
					-- oxfmt/biome/eslint がある場合は使わない
					if
						vim.fs.find(
							{ ".oxfmtrc.json", "biome.json", ".eslintrc", ".eslintrc.json", "eslint.config.js" },
							{ path = ctx.filename, upward = true }
						)[1]
					then
						return false
					end
					return vim.fs.find({
						".prettierrc",
						".prettierrc.json",
						".prettierrc.yml",
						".prettierrc.yaml",
						"prettier.config.js",
						"prettier.config.cjs",
					}, { path = ctx.filename, upward = true })[1] ~= nil
				end,
			},
			prettier = {
				condition = function(_, ctx)
					-- prettierd と同じ条件
					if
						vim.fs.find(
							{ ".oxfmtrc.json", "biome.json", ".eslintrc", ".eslintrc.json", "eslint.config.js" },
							{ path = ctx.filename, upward = true }
						)[1]
					then
						return false
					end
					return vim.fs.find({
						".prettierrc",
						".prettierrc.json",
						".prettierrc.yml",
						".prettierrc.yaml",
						"prettier.config.js",
						"prettier.config.cjs",
					}, { path = ctx.filename, upward = true })[1] ~= nil
				end,
			},
		},
	},
}
