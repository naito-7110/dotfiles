return {
"APZelos/blamer.nvim",
event = "VeryLazy",
init = function()
  vim.g.blamer_enabled = true
  vim.g.blamer_delay = 200
  vim.g.blamer_prefix = " "
  vim.g.blamer_show_in_insert_modes = 0
end,
} 
