return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		-- Show the current path: oil's browsing dir for oil buffers,
		-- otherwise the file's path relative to cwd (with ~ for $HOME).
		local function current_path()
			if vim.bo.filetype == "oil" then
				local ok, oil = pcall(require, "oil")
				if ok then
					local dir = oil.get_current_dir()
					if dir then
						return vim.fn.fnamemodify(dir, ":~")
					end
				end
			end

			local name = vim.api.nvim_buf_get_name(0)
			if name == "" then
				return "[No Name]"
			end

			local path = vim.fn.fnamemodify(name, ":~:.")
			if vim.bo.modified then
				path = path .. " [+]"
			elseif vim.bo.readonly or not vim.bo.modifiable then
				path = path .. " [-]"
			end
			return path
		end

		require("lualine").setup({
			options = {
				icons_enabled = true,
				theme = "auto",
				component_separators = { left = "", right = "" },
				section_separators = { left = "", right = "" },
				disabled_filetypes = {
					statusline = {},
					winbar = {},
				},
				ignore_focus = {},
				always_divide_middle = true,
				always_show_tabline = true,
				globalstatus = false,
				refresh = {
					statusline = 1000,
					tabline = 1000,
					winbar = 1000,
					refresh_time = 16, -- ~60fps
					events = {
						"WinEnter",
						"BufEnter",
						"BufWritePost",
						"SessionLoadPost",
						"FileChangedShellPost",
						"VimResized",
						"Filetype",
						"CursorMoved",
						"CursorMovedI",
						"ModeChanged",
					},
				},
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch", "diff", "diagnostics" },
				lualine_c = {
					{ current_path, icon = "" },
				},
				lualine_x = { "encoding", "fileformat", "filetype" },
				lualine_y = { "progress" },
				lualine_z = { "location" },
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = { { current_path, icon = "" } },
				lualine_x = { "location" },
				lualine_y = {},
				lualine_z = {},
			},
			tabline = {},
			winbar = {},
			inactive_winbar = {},
			extensions = {},
		})
	end,
}
