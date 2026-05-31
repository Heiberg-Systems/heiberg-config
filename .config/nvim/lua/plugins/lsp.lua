-- File: ~/.config/nvim/lua/plugins/lsp.lua
return {
  -- Core package manager for LSP servers and debuggers
  {
    "williamboman/mason.nvim",
    dependencies = {
      "mason-org/mason-lspconfig.nvim",
      "hrsh7th/nvim-cmp",         -- Autocompletion Engine
      "hrsh7th/cmp-nvim-lsp",     -- LSP source for nvim-cmp
    },
    config = function()
      require("mason").setup()
      
      -- Declare language servers to auto-provision
      local servers = {
        pyright = {},
        ruff = {},
        vtsls = {},
        lemminx = {},
        jsonls = {},
      }

      require("mason-lspconfig").setup({
        ensure_installed = vim.tbl_keys(servers),
        automatic_enable = true, -- Automatically bootstraps to Neovim 0.11 native LSP handler
      })

      -- Set up auto-completion engine
      local cmp = require("cmp")
      cmp.setup({
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = "nvim-lsp" },
        }),
      })

      -- Set up 0.11 Global Keymaps on LSP attach
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local opts = { buffer = args.buf }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
          
          -- Format on save implementation
          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = args.buf,
            callback = function()
              vim.lsp.buf.format({ async = false })
            end,
          })
        end,
      })
    end,
  },
}

