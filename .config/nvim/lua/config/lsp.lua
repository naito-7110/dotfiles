-- LSP のログは既定で OFF。デバッグ時は <leader>ll で DEBUG に切替する。
vim.lsp.set_log_level("OFF")

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

-- VB.NET
-- nixpkgs には VB を扱える LSP が無い。roslyn-ls も omnisharp-roslyn も
-- Microsoft.CodeAnalysis.VisualBasic.* を同梱しておらず、`.vb` を開いても補完ゼロ。
-- vb-ls は同じ公式 Roslyn LSP に VB のアセンブリを同梱し直した dotnet tool なので、
-- roslyn_ls とまったく同じ流儀で動く。dotnet テンプレートの devShell が供給する。
--
-- 注意: このサーバは rootUri からプロジェクトを自動で開かない。
-- initialize 後に solution/open を送るまで接続しても機能がゼロのままなので、
-- ソリューション(.slnx/.sln)を見つけて明示的に渡している。
-- root_markers はグロブを解決しないため（`*.slnx` を渡すと root_dir が nil になり、
-- solution/open も飛ばず補完ゼロのまま繋がる）、上方向探索を自前で書く。
local function find_upward(pattern, bufnr)
	local name = vim.api.nvim_buf_get_name(bufnr)
	if name == "" then
		return nil
	end
	return vim.fs.find(function(n)
		return n:match(pattern)
	end, { path = vim.fs.dirname(name), upward = true, type = "file", limit = 1 })[1]
end

local function find_solution(bufnr)
	return find_upward("%.slnx?$", bufnr)
end

local function find_project(bufnr)
	return find_upward("%.vbproj$", bufnr)
end

local vb_ls_opened = {}

vim.lsp.config("vb_ls", {
	cmd = {
		"vb-ls",
		"--logLevel=Information",
		"--extensionLogDirectory=" .. vim.fs.dirname(vim.lsp.get_log_path()),
		"--stdio",
	},
	filetypes = { "vb" },
	-- グローバルの vim.lsp.handlers には置かない。nvim-lspconfig が roslyn_ls 用に
	-- 同じ通知を扱っているため、上書きすると C# 側のメッセージを奪う。
	handlers = {
		["workspace/projectInitializationComplete"] = function()
			vim.notify("vb_ls: project loaded", vim.log.levels.INFO)
		end,
	},
	root_dir = function(bufnr, on_dir)
		local marker = find_solution(bufnr) or find_project(bufnr)
		if marker then
			on_dir(vim.fs.dirname(marker))
		end
	end,
	on_attach = function(client, bufnr)
		-- ソリューションはクライアントごとに一度だけ開く。
		if vb_ls_opened[client.id] then
			return
		end
		vb_ls_opened[client.id] = true

		local sln = find_solution(bufnr)
		if sln then
			client:notify("solution/open", { solution = vim.uri_from_fname(sln) })
			return
		end
		-- ソリューションが無いリポジトリではプロジェクト単位で開く。
		local proj = find_project(bufnr)
		if proj then
			client:notify("project/open", { projects = { vim.uri_from_fname(proj) } })
		else
			vb_ls_opened[client.id] = nil
			vim.notify("vb_ls: no .slnx/.sln/.vbproj found — completion will be empty", vim.log.levels.WARN)
		end
	end,
})

vim.lsp.enable("vb_ls")

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
		"--function-arg-placeholders=true",
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

-- TypeScript (Vue plugin 同梱)
-- 注意: vue_ls / ts_ls / @vue/typescript-plugin は必ずプロジェクトから供給し、
-- vue-language-server と @vue/typescript-plugin のメジャーを一致させること。
-- 世代がズレると hybrid-mode が壊れ v-on / v-bind 補完が死ぬ（静的ディレクティブは出る）。
-- そのため nix グローバル(lsp.nix)には TS/Vue を置かない。devShell 供給が正。
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

-- Python
-- basedpyright (型・補完・ジャンプ) と ruff (lint・format) の 2 枚構成。
-- どちらも python テンプレートの devShell から供給する（プロジェクトの
-- インタプリタ世代に合わせたいのでグローバルの lsp.nix には置かない）。
--
-- 最重要: pythonPath に uv の .venv を渡すこと。渡さないと basedpyright は
-- 素の python を見に行き、サードパーティの import が全部
-- "could not be resolved" になる（自前のコードだけ補完が効くので気付きにくい）。
vim.lsp.config("basedpyright", {
	cmd = { "basedpyright-langserver", "--stdio" },
	filetypes = { "python" },
	root_markers = { "pyproject.toml", "uv.lock", "setup.py", "setup.cfg", "requirements.txt", ".venv", ".git" },
	settings = {
		basedpyright = {
			-- import 整理は ruff の担当。両方有効だと code action が二重に出る。
			disableOrganizeImports = true,
			analysis = {
				-- 既定の "recommended" は型注釈の無い既存コードに対して
				-- 診断が壊滅的に出るので一段落とす。
				typeCheckingMode = "standard",
				diagnosticMode = "openFilesOnly",
				autoSearchPaths = true,
				useLibraryCodeForTypes = true,
				autoImportCompletions = true,
			},
		},
	},
	on_init = function(client)
		local settings = client.config.settings
		settings.python = vim.tbl_deep_extend("force", settings.python or {}, {
			pythonPath = require("config.python").venv_python(client.config.root_dir),
		})
		client:notify("workspace/didChangeConfiguration", { settings = settings })
	end,
})

vim.lsp.enable("basedpyright")

vim.lsp.config("ruff", {
	cmd = { "ruff", "server" },
	filetypes = { "python" },
	root_markers = { "pyproject.toml", "ruff.toml", ".ruff.toml", ".git" },
	on_attach = function(client)
		-- ホバーは basedpyright の担当。両方出すと型情報が lint 文言に負ける。
		client.server_capabilities.hoverProvider = false
	end,
})

vim.lsp.enable("ruff")
