-- File: ~/.config/nvim/init.lua

-- 1. Load your core configuration options
require("core.options")
require("core.keymaps")

-- 2. Bootstrap lazy.nvim installation directly here
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- 3. Tell lazy to load all plugin configuration files inside the lua/plugins/ folder
require("lazy").setup("plugins")


