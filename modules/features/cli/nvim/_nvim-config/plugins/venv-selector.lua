return {
  {
    "linux-cultist/venv-selector.nvim",
    opts = {
      search = {
        -- Priority 1: UV .venv in current directory (git-aware)
        uv_cwd = {
          command = "fd '/bin/python$' .venv --full-path --color never -HI -a -L --no-require-git",
        },
        
        -- Priority 2: UV .venv in LSP workspace folder(s)
        uv_workspace = {
          command = "fd '/bin/python$' $WORKSPACE_PATH/.venv --full-path --color never -HI -a -L --no-require-git",
        },
        
        -- Priority 3: Standard cwd search (git-aware)
        cwd = {
          command = "fd '/bin/python$' '$CWD' --full-path --color never -HI -a -L --no-require-git -E /proc -E site-packages/",
        },
        
        -- Keep all default searches for other venv managers
        -- (poetry, pyenv, conda, hatch, pixi, etc. are preserved from defaults)
      },
      
      options = {
        cached_venv_automatic_activation = true,
        enable_cached_venvs = true,
        notify_user_on_venv_activation = true,
        debug = false,
        on_venv_activate_callback = function()
          local python_path = require("venv-selector").python()
          local venv_path = require("venv-selector").venv()
          
          -- Enhanced error handling and logging
          if not python_path then
            vim.notify("No Python path found in venv-selector", vim.log.levels.WARN)
            return
          end
          
          -- Notify user of the change
          vim.notify("🔧 Updating Pyright: " .. vim.fn.fnamemodify(python_path, ":t"), vim.log.levels.INFO)
          
          -- Get Pyright clients
          local clients = vim.lsp.get_clients({ name = "pyright" })
          if #clients == 0 then
            vim.notify("⚠️ Pyright not running - will apply on next start", vim.log.levels.WARN)
            return
          end
          
          -- Update all Pyright clients
          for _, client in ipairs(clients) do
            client.config.settings = vim.tbl_deep_extend("force", client.config.settings or {}, {
              python = {
                pythonPath = python_path,
                venvPath = vim.fn.fnamemodify(venv_path, ":h"),
                venv = vim.fn.fnamemodify(venv_path, ":t"),
                analysis = {
                  extraPaths = {
                    vim.fn.fnamemodify(venv_path, ":h") .. "/lib/python*/site-packages"
                  },
                },
              }
            })
            
            -- Apply configuration changes
            client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
          end
          
          -- Force restart Pyright to ensure changes take effect
          vim.defer_fn(function()
            vim.cmd("LspRestart pyright")
            vim.notify("✅ Pyright restarted with new venv", vim.log.levels.INFO)
          end, 100)
        end,
      },
      
      hooks = {
        -- Custom notification hook for project-relative paths
        function(python_path, venv_type)
          local project_path = vim.fn.getcwd()
          local relative_path = python_path:gsub("^" .. project_path .. "/", ""):gsub("^home/taylor/", "~/")
          
          if venv_type == "uv" and relative_path:match(".venv") then
            vim.notify("🐍 Activated UV: " .. relative_path, vim.log.levels.INFO, { title = "VenvSelect" })
            return 1
          elseif python_path:match("/usr/bin/python") then
            -- Silent for global Python fallback
            return 1
          else
            vim.notify("🐍 Activated: " .. relative_path, vim.log.levels.INFO, { title = "VenvSelect" })
            return 1
          end
        end,
      },
      
      -- Session-only cache configuration
      cache = {
        file = vim.fn.stdpath("state") .. "/venv-selector-session.json",
      },
    },
    
    -- Custom setup function for cache reset on startup
    config = function(_, opts)
      -- Delete session cache on startup to ensure fresh detection
      local cache_file = vim.fn.stdpath("state") .. "/venv-selector-session.json"
      if vim.fn.filereadable(cache_file) == 1 then
        vim.fn.delete(cache_file)
      end
      
      -- Setup the plugin
      require("venv-selector").setup(opts)
    end,
  },
}
