return {
  -- 1. Configure ty within nvim-lspconfig
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Explicitly disable pyright to avoid conflicts
        pyright = { enabled = false },
        
        -- Enable the ty language server
        ty = {
          settings = {
            ty = {
              -- You can add specific ty settings here
            },
          },
        },
      },
    },
  },

  -- 2. Update venv-selector to handle ty activation
  {
    "linux-cultist/venv-selector.nvim",
    opts = function(_, opts)
      -- Replace the Pyright-specific logic with ty logic
      opts.options.on_venv_activate_callback = function()
        local venv_selector = require("venv-selector")
        local python_path = venv_selector.python()
        local venv_path = venv_selector.venv()
        
        if not python_path then
          vim.notify("No Python path found in venv-selector", vim.log.levels.WARN)
          return
        end
        
        -- Notify user of the change
        vim.notify("🔧 Updating ty: " .. vim.fn.fnamemodify(python_path, ":t"), vim.log.levels.INFO)
        
        -- Get active ty clients
        local clients = vim.lsp.get_clients({ name = "ty" })
        
        if #clients == 0 then
          vim.notify("⚠️ ty not running - will apply on next start", vim.log.levels.WARN)
          return
        end
        
        -- Update all ty clients with the new Python path
        for _, client in ipairs(clients) do
          client.config.settings = vim.tbl_deep_extend("force", client.config.settings or {}, {
            python = {
              pythonPath = python_path,
              -- Pass venv details if needed for path resolution
              venvPath = vim.fn.fnamemodify(venv_path, ":h"),
            }
          })
          
          -- Push the configuration change to the server
          client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
        end
        
        -- Restart ty to ensure it picks up the new environment immediately
        vim.defer_fn(function()
          vim.cmd("LspRestart ty")
          vim.notify("✅ ty restarted with new venv", vim.log.levels.INFO)
        end, 100)
      end
      
      return opts
    end,
  },
}
