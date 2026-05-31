-- File: ~/.config/nvim/lua/plugins/formatter.lua
return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>f",
      function()
        require("conform").format({ async = true, lsp_fallback = true })
      end,
      mode = "",
      desc = "Format buffer",
    },
  },
  opts = {
    -- Map formatters to specific languages
    formatters_by_ft = {
      javascript = { "prettier" },
      typescript = { "prettier" },
      json = { "prettier" },
      xml = { "xmlformat" },
      python = { "ruff_format" }, -- Rapid formatting for Python
    },
    -- Auto-format when saving the file
    format_on_save = {
      timeout_ms = 500,
      lsp_fallback = true,
    },
  },
}

