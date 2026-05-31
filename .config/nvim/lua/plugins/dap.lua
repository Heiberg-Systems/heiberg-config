-- File: ~/.config/nvim/lua/plugins/dap.lua
return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "mfussenegger/nvim-dap-python", -- Extracted Python handling
    },
    config = function()
      local dap, dapui = require("dap"), require("dapui")
      dapui.setup()

      -- Automatically open/close visual UI panes when debugger activates
      dap.listeners.before.attach.dapui_config = function() dapui.open() end
      dap.listeners.before.launch.dapui_config = function() dapui.open() end
      dap.listeners.after.event_terminated.dapui_config = function() dapui.close() end
      dap.listeners.after.event_exited.dapui_config = function() dapui.close() end

      -- 1. Python DAP Hook (Assumes mason package debugpy is present)
      local python_path = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
      require("dap-python").setup(python_path)

      -- Docker remote attach (debugpy listening inside container, port forwarded to host)
      -- Start with: docker compose -f docker-compose.yml -f docker-compose.debug.yml up backend
      -- Note: --reload is intentionally omitted — uvicorn's reloader spawns subprocesses that break debugpy
      for _, proj in ipairs({
        { name = "eating-plan", path = "eating-plan/app/backend", port = 5678 },
        { name = "workout-plan", path = "workout-plan/app/backend", port = 5679 },
      }) do
        table.insert(dap.configurations.python, {
          type = "python",
          request = "attach",
          name = "Docker: " .. proj.name,
          connect = { host = "127.0.0.1", port = proj.port },
          pathMappings = {{
            localRoot = vim.fn.expand("~/Development/heiberg-systems/" .. proj.path),
            remoteRoot = "/app",
          }},
          justMyCode = false,
        })
      end

      -- 2. JS / TS Chromium/Node Adapter Configuration
      dap.adapters["pwa-node"] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
          command = "node",
          args = {
            vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js",
            "${port}",
          },
        },
      }

      dap.configurations.javascript = {
        {
          type = "pwa-node",
          request = "launch",
          name = "Launch Current File (Node.js)",
          program = "${file}",
          cwd = vim.fn.getcwd(),
          sourceMaps = true,
        },
      }
      dap.configurations.typescript = dap.configurations.javascript

      -- Navigation Mappings
      vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debug: Start/Continue" })
      vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Debug: Step Over" })
      vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Debug: Step Into" })
      vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
    end,
  },
}

