vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"

-- File: ~/.config/nvim/lua/core/options.lua

-- Create an autocommand group for web/data markup formats
local indent_group = vim.api.nvim_create_augroup("DataIndent", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "json", "xml", "javascript", "typescript", "tsx" },
  group = indent_group,
  callback = function()
    vim.opt_local.tabstop = 2      -- A tab counts for 2 spaces
    vim.opt_local.shiftwidth = 2   -- Auto-indentation uses 2 spaces
    vim.opt_local.softtabstop = 2  -- Editing rules treat tabs as 2 spaces
  end,
})

