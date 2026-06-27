-- C#
vim.lsp.config("roslyn_ls", {
	cmd = {
		"Microsoft.CodeAnalysis.LanguageServer",
		"--logLevel=Information",
		"--extensionLogDirectory=" .. vim.fs.dirname(vim.lsp.get_log_path()),
		"--stdio",
	},
	filetypes = { "cs" },
	root_markers = { "*.sln", "*.slnx", "*.csproj", "omnisharp.json", "function.json" },
})

vim.lsp.enable("roslyn_ls")

-- Rust
vim.lsp.config("rust_analyzer", {
	cmd = { "rust-analyzer" },
	filetypes = { "rust" },
})

vim.lsp.enable("rust_analyzer")

-- Go
vim.lsp.config("gopls", {
	cmd = { "gopls" },
	filetypes = { "go", "gomod", "gowork", "gotmpl" },
	root_markers = { "go.work", "go.mod", ".git" },
	settings = {
		gopls = {
			completeUnimported = true,
			usePlaceholders = true,
			staticcheck = true,
			gofumpt = true,
			analyses = {
				unusedparams = true,
				shadow = true,
			},
			hints = {
				assignVariableTypes = true,
				compositeLiteralFields = true,
				compositeLiteralTypes = true,
				constantValues = true,
				functionTypeParameters = true,
				parameterNames = true,
				rangeVariableTypes = true,
			},
		},
	},
})

vim.lsp.enable("gopls")

-- C/C++
vim.lsp.config("clangd", {
	cmd = {
		"clangd",
		"--background-index",
		"--clang-tidy",
		"--header-insertion=iwyu",
		"--completion-style=detailed",
		"--function-arg-placeholders",
	},
	filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
	root_markers = {
		".clangd",
		".clang-tidy",
		".clang-format",
		"compile_commands.json",
		"compile_flags.txt",
		"configure.ac",
		".git",
	},
})

vim.lsp.enable("clangd")

-- Lua
vim.lsp.config("lua_ls", {
	cmd = { "lua-language-server" },
	filetypes = { "lua" },
	settings = {
		Lua = {
			diagnostics = {
				globals = { "vim" },
			},
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
				checkThirdParty = false,
			},
		},
	},
})

vim.lsp.enable("lua_ls")

-- nix
vim.lsp.config("nil_ls", {
	cmd = { "nil" },
	filetypes = { "nix" },
})

vim.lsp.enable("nil_ls")

vim.lsp.config("marksman", {
	filetypes = { "markdown" },
	cmd = { "marksman", "server" },
})

vim.lsp.enable("marksman")

-- Typst
vim.lsp.config("tinymist", {
	cmd = { "tinymist" },
	filetypes = { "typst" },
	settings = {
		formatterMode = "typstyle",
		exportPdf = "onSave",
	},
})

vim.lsp.enable("tinymist")

-- In my lsp config file:

-- TypeScript Server with Vue Plugin
vim.lsp.config("ts_ls", {
	filetypes = {
		"javascript",
		"javascriptreact",
		"javascript.jsx",
		"typescript",
		"typescriptreact",
		"typescript.tsx",
		"vue",
	},
	init_options = {
		plugins = {
			{
				name = "@vue/typescript-plugin",
				location = vim.fn.getcwd() .. "/node_modules/@vue/typescript-plugin",
				languages = { "vue" },
			},
		},
	},
	cmd = { "typescript-language-server", "--stdio" },
	--capabilities = capabilities,
})

vim.lsp.enable("ts_ls")

vim.lsp.config("vue_ls", {
	filetypes = { "vue" },
})
vim.lsp.enable("vue_ls")
--メッセージ
vim.diagnostic.config({
	virtual_text = false, -- 行末にゴチャゴチャ出さない
	signs = true, -- 左側にアイコン表示
	underline = true, -- 下線表示
	severity_sort = true, -- 重要度順に並べる
	float = {
		border = "rounded",
		source = "if_many",
	},
})

-- JSON Language Server
vim.lsp.config("jsonls", {
	cmd = { "vscode-json-language-server", "--stdio" },
	filetypes = { "json", "jsonc" },
	settings = {
		json = {
			schemas = require("schemastore").json.schemas(),
			validate = { enable = true },
		},
	},
})

vim.lsp.enable("jsonls")
