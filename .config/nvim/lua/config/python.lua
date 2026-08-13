-- Python のインタプリタ解決。LSP (basedpyright) と DAP (debugpy) の両方が
-- 「プロジェクトの venv の python」を必要とするため、ここに一本化する。
--
-- nix の devShell が入れる python は素の interpreter で、プロジェクトの依存が
-- 入っていない。これを basedpyright に渡すと import が全部
-- "could not be resolved" になり、debugpy は起動すらしない。
-- 見るのは uv が作る .venv (テンプレートの devShell が UV_PROJECT_ENVIRONMENT=.venv)。

local M = {}

--- 探索の起点。編集中のファイルのディレクトリを優先する。
--- cwd 基準にすると、別ディレクトリから nvim を起動したときに
--- プロジェクトの .venv を見失って PATH の python に落ちる。
local function start_dir()
	local name = vim.api.nvim_buf_get_name(0)
	if name ~= "" and not name:match("^%a+://") then
		return vim.fs.dirname(name)
	end
	return vim.fn.getcwd()
end

--- venv の python を探す。見つからなければ PATH の python3 に落とす。
--- @param root string|nil 探索の起点ディレクトリ (省略時はバッファのあるディレクトリ)
--- @return string
function M.venv_python(root)
	-- venv を activate 済みのシェルから起動した場合はそれが最優先。
	local active = vim.env.VIRTUAL_ENV
	if active and active ~= "" then
		return active .. "/bin/python"
	end

	-- .venv はプロジェクト直下とは限らない (モノレポのサブパッケージ等) ので
	-- 上方向に探す。
	local found = vim.fs.find(".venv", {
		path = root or start_dir(),
		upward = true,
		type = "directory",
		limit = 1,
	})[1]
	if found then
		local python = found .. "/bin/python"
		if vim.uv.fs_stat(python) then
			return python
		end
	end

	return vim.fn.exepath("python3")
end

--- デバッグ用のインタプリタ。debugpy が入っていなければ警告してから返す。
--- nvim-dap は adapter の起動に失敗しても "exited with 1" としか言わないので、
--- ここで原因を出しておかないと追うのがつらい。
--- @param root string|nil
--- @return string
function M.debugpy_python(root)
	local python = M.venv_python(root)
	local ok = vim.system({ python, "-c", "import debugpy" }):wait(5000).code == 0
	if not ok then
		vim.notify(
			("debugpy が見つからない (%s)\nプロジェクトの venv に入れる: uv add --dev debugpy"):format(
				python
			),
			vim.log.levels.WARN
		)
	end
	return python
end

return M
