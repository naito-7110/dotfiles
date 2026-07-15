-- ####################
--    共通config
-- ####################
vim.api.nvim_create_user_command("Config", function()
	vim.cmd.edit(vim.fn.stdpath("config") .. "/init.lua")
end, { desc = "open init.lua" })
