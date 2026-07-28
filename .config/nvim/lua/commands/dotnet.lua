-- ####################
--    dotnet build -> quickfix
-- ####################
-- nixpkgs の LSP はどれも VB を扱えない（roslyn-ls / omnisharp-roslyn はどちらも
-- Microsoft.CodeAnalysis.VisualBasic.* を同梱していない）。VB 専用の vb-ls は
-- nixpkgs 未収録なので、`.vb` の型チェックは「ビルド出力を quickfix に流す」で担保する。
-- LSP が入っても、サーバー側が受け付ける言語バージョンの確認はコンパイラでしかできない
-- ため、この経路は残す。C# でも roslyn-ls の見ていないプロジェクトのエラーを拾える。

-- MSBuild / vbc / csc のエラー行（実測）:
--   /abs/Items.vb(20,32): error BC30456: 'X' is not a member of 'Y'. [/abs/Proj.vbproj]
--   /abs/Items.vb(111,17): warning BC42024: Unused local variable: 'x'. [/abs/Proj.vbproj]
-- 末尾の [プロジェクトパス] は quickfix 上でノイズなので、efm に渡す前に落とす。
local errorformat = table.concat({
	"%f(%l\\,%c): %trror %m",
	"%f(%l\\,%c): %tarning %m",
	"%f(%l): %trror %m",
	"%f(%l): %tarning %m",
	-- ファイルを持たない MSBuild 自身のエラー（例: MSBUILD : error MSB1009: ...）
	"%*[^:]: %trror %m",
	"%-G%.%#",
}, ",")

local PROJECT_PATTERNS = { "%.vbproj$", "%.csproj$", "%.fsproj$" }
local SOLUTION_PATTERNS = { "%.slnx$", "%.sln$" }

local function find_upward(patterns, start)
	local hits = vim.fs.find(function(name)
		for _, p in ipairs(patterns) do
			if name:match(p) then
				return true
			end
		end
		return false
	end, { upward = true, path = start, type = "file", limit = 1 })
	return hits[1]
end

-- ビルド対象は「バッファに一番近いプロジェクト」を優先する。
-- ソリューション全体をビルドすると無関係な C# プロジェクトまで巻き込んで遅い。
local function resolve_target()
	local bufpath = vim.api.nvim_buf_get_name(0)
	local start = bufpath ~= "" and vim.fs.dirname(bufpath) or vim.uv.cwd()
	local target = find_upward(PROJECT_PATTERNS, start) or find_upward(SOLUTION_PATTERNS, start)
	if not target then
		return nil, nil
	end
	return target, vim.fs.dirname(target)
end

-- devShell に入っていれば dotnet が PATH にある。無ければ flake 経由で叩くが、
-- nix の評価が毎回走って遅いので通常は devShell に入って使う。
-- dotnet に追加フラグ(--nologo 等)を渡さないのは意図的。`nix develop --command` は
-- 後続の `--foo` を nix 自身のオプションとして解釈して失敗する。バナー行は efm が捨てるので不要。
local function resolve_cmd(target, cwd)
	if vim.fn.executable("dotnet") == 1 then
		return { "dotnet", "build", target }
	end
	local flake = vim.fs.find("flake.nix", { upward = true, path = cwd, type = "file", limit = 1 })[1]
	if flake then
		return { "nix", "develop", "--command", "dotnet", "build", target }, vim.fs.dirname(flake)
	end
	return nil
end

-- dotnet build は同じ診断をインライン出力と末尾サマリの 2 回吐く。素通しすると
-- quickfix に全部 2 件ずつ並ぶので、プロジェクト名サフィックスを落としてから重複を除く。
local function normalize(stdout)
	local seen, lines = {}, {}
	for _, line in ipairs(vim.split(stdout or "", "\n", { trimempty = true })) do
		line = line:gsub("%s*%[[^%]]*%]%s*$", "")
		if not seen[line] then
			seen[line] = true
			table.insert(lines, line)
		end
	end
	return lines
end

local running = false

local function build()
	if running then
		vim.notify("dotnet build already running", vim.log.levels.WARN)
		return
	end

	local target, dir = resolve_target()
	if not target then
		vim.notify("No .vbproj/.csproj/.sln(x) found above this buffer", vim.log.levels.ERROR)
		return
	end

	local cmd, cwd = resolve_cmd(target, dir)
	if not cmd then
		vim.notify("dotnet not found (enter the devShell) and no flake.nix to fall back to", vim.log.levels.ERROR)
		return
	end

	running = true
	vim.notify("dotnet build " .. vim.fs.basename(target))

	vim.system(cmd, { cwd = cwd or dir, text = true }, function(res)
		vim.schedule(function()
			running = false
			local lines = normalize((res.stdout or "") .. "\n" .. (res.stderr or ""))
			vim.fn.setqflist({}, " ", { title = "dotnet build", lines = lines, efm = errorformat })

			local qf = vim.fn.getqflist()
			if #qf > 0 then
				vim.cmd("copen")
				vim.notify(("dotnet build: %d diagnostic(s)"):format(#qf), vim.log.levels.WARN)
			else
				if res.code == 0 then
					vim.cmd("cclose")
					vim.notify("dotnet build: OK", vim.log.levels.INFO)
				else
					-- restore 失敗や nix 側のエラーなど、コンパイラ診断の形をしていない失敗。
					-- 黙って閉じると原因が追えないので生ログをそのまま quickfix に出す。
					local raw = vim.tbl_map(function(l)
						return { text = l }
					end, lines)
					vim.fn.setqflist({}, " ", { title = "dotnet build (raw output)", items = raw })
					vim.cmd("copen")
					vim.notify("dotnet build failed; see quickfix for raw output", vim.log.levels.ERROR)
				end
			end
		end)
	end)
end

vim.api.nvim_create_user_command("DotnetBuild", build, { desc = "dotnet build -> quickfix" })

-- :make でも同じ形式を解釈できるようにしておく（同期実行になるので通常は :DotnetBuild）。
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "vb", "cs", "fsharp" },
	callback = function(ev)
		vim.bo[ev.buf].errorformat = errorformat
		vim.bo[ev.buf].makeprg = "dotnet build --nologo"
	end,
	desc = "dotnet errorformat/makeprg",
})

return { build = build, errorformat = errorformat }
