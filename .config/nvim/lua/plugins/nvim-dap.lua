return {
	{
		"rcarriga/nvim-dap-ui",
		dependencies = {
			"mfussenegger/nvim-dap",
			"nvim-neotest/nvim-nio",
			{ "theHamsta/nvim-dap-virtual-text", opts = {} },
		},
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")

			dapui.setup()

			dap.listeners.before.attach.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.launch.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated.dapui_config = function()
				dapui.close()
			end
			dap.listeners.before.event_exited.dapui_config = function()
				dapui.close()
			end

			vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError", linehl = "", numhl = "" })
			vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticWarn", linehl = "", numhl = "" })

			-- Rust (lldb-dap from pkgs.lldb)
			dap.adapters.lldb = {
				type = "executable",
				command = "lldb-dap",
				name = "lldb",
			}

			dap.configurations.rust = {
				{
					name = "Launch",
					type = "lldb",
					request = "launch",
					program = function()
						return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
					end,
					cwd = "${workspaceFolder}",
					stopOnEntry = false,
					args = {},
				},
			}

			-- .NET (netcoredbg from the dotnet devShell; Linux only — see docs/neovim.md)
			dap.adapters.coreclr = {
				type = "executable",
				command = "netcoredbg",
				args = { "--interpreter=vscode" },
			}

			dap.configurations.cs = {
				{
					name = "Launch DLL",
					type = "coreclr",
					request = "launch",
					program = function()
						return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
					end,
					cwd = "${workspaceFolder}",
				},
				{
					name = "Attach",
					type = "coreclr",
					request = "attach",
					processId = function()
						return require("dap.utils").pick_process()
					end,
				},
			}
			dap.configurations.vb = dap.configurations.cs

			-- Python (debugpy — nix ではなくプロジェクトの venv に入れる: `uv add --dev debugpy`)
			-- デバッグ対象と同じインタプリタで adapter を起動しないと
			-- ブレークポイントが刺さらないため、常に .venv の python を使う。
			local python = require("config.python")

			dap.adapters.python = function(callback, config)
				if config.request == "attach" then
					local port = (config.connect or config).port
					local host = (config.connect or config).host or "127.0.0.1"
					callback({
						type = "server",
						host = host,
						port = assert(port, "`connect.port` is required for a python attach configuration"),
						options = { source_filetype = "python" },
					})
					return
				end
				callback({
					type = "executable",
					command = python.debugpy_python(),
					args = { "-m", "debugpy.adapter" },
					options = { source_filetype = "python" },
				})
			end

			dap.configurations.python = {
				{
					name = "Launch file",
					type = "python",
					request = "launch",
					program = "${file}",
					cwd = "${workspaceFolder}",
					console = "integratedTerminal",
					pythonPath = python.venv_python,
				},
				{
					name = "Launch module",
					type = "python",
					request = "launch",
					module = function()
						return vim.fn.input("Module name: ")
					end,
					cwd = "${workspaceFolder}",
					console = "integratedTerminal",
					pythonPath = python.venv_python,
				},
				{
					-- 起動側で `python -m debugpy --listen 5678 --wait-for-client ...` した
					-- プロセスに繋ぐ。uvicorn / pytest などランナー経由のときはこちら。
					name = "Attach (127.0.0.1:5678)",
					type = "python",
					request = "attach",
					connect = { host = "127.0.0.1", port = 5678 },
					cwd = "${workspaceFolder}",
				},
			}
		end,
	},
}
