return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- Provides the Nerd Font developer icons
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup({
        default_component_configs = {
          -- Explicitly tell neo-tree to fetch and display file/folder icons
          icon = {
            folder_closed = "",
            folder_open = "",
            folder_empty = "󰜮",
            default = "󰈚",
          },
          git_status = {
            symbols = {
              added     = "✚",
              modified  = "",
              deleted   = "✖",
              renamed   = "󰁔",
              untracked = "",
              ignored   = "",
              unstaged  = "󰄱",
              staged    = "",
              conflict  = "",
            },
          },
        },
        window = {
          width = 30, -- Hardcoded layout width for your panel
        },
      })
    end,
  }
}

