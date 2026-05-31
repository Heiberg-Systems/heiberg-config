-- File: ~/.config/nvim/lua/plugins/treesitter.lua
return {
  "nvim-treesitter/nvim-treesitter",
  -- CRITICAL: Tells Lazy to pull the frozen branch designed for Neovim v0.11
  branch = "master", 
  build = ":TSUpdate",
  config = function()
    -- Reverts back to the proper master branch configuration endpoint
    require("nvim-treesitter.configs").setup({
      ensure_installed = { 
        "python", 
        "javascript", 
        "typescript", 
        "tsx", 
        "xml", 
        "json", 
        "lua" 
      },
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      indent = {
        enable = true,
      },
    })
  end,
}

