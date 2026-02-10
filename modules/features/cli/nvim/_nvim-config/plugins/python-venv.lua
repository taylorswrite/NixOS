return {
  -- 1. LSP: Replace Pyright with ty
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}

      -- Explicitly disable pyright to prevent conflicts
      opts.servers.pyright = { enabled = false }

      -- Enable ty language server
      opts.servers.ty = {
        settings = {
          ty = {
            -- Reference documentation for ty specific settings
          },
        },
        before_init = function(_, config)
          -- Maintain your existing logic to fetch python path on startup
          local status, venv_config = pcall(require, "config.python_env")
          if status then
            local python_path = venv_config.get_python_path()
            if python_path then
              config.settings.python = config.settings.python or {}
              config.settings.python.pythonPath = python_path
            end
          end
        end,
        on_attach = function(client, _)
          -- ty does not handle formatting (use Ruff/Conform), so we disable its providers
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false
        end,
      }

      opts.servers.ruff = {
        on_attach = function(client, _)
          client.server_capabilities.hoverProvider = false
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false
        end,
      }
      return opts
    end,
  },

  -- 2. Virtual environment selector: Updated for ty integration
  {
    "linux-cultist/venv-selector.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-telescope/telescope.nvim",
    },
    ft = { "python", "quarto", "rmd", "markdown" },
    keys = {
      { "<leader>cv", "<cmd>:VenvSelect<cr>", desc = "Select VirtualEnv" },
    },
    opts = function(_, opts)
      -- Merge your existing search and option settings
      opts.options = vim.tbl_deep_extend("force", opts.options or {}, {
        notify_user_on_venv_activation = true,
        enable_cached_venvs = true,
        cached_venv_automatic_activation = true,
        -- Custom callback to update ty when the venv changes
        on_venv_activate_callback = function()
          local python_path = require("venv-selector").python()
          if not python_path then return end

          -- Find active ty clients and update their configuration
          local clients = vim.lsp.get_clients({ name = "ty" })
          for _, client in ipairs(clients) do
            client.config.settings = vim.tbl_deep_extend("force", client.config.settings or {}, {
              python = { pythonPath = python_path }
            })
            client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
          end
          
          -- Restart the server to apply changes
          vim.defer_fn(function()
            vim.cmd("LspRestart ty")
            vim.notify("✅ ty restarted with new venv", vim.log.levels.INFO)
          end, 100)
        end,
      })
      
      opts.search = {
        cwd = {
          command = "fd '/bin/python$' $CWD --full-path --color never -E /proc -I -a -L",
        },
      }
      return opts
    end,
  },

  -- 3. Formatting: Retain Ruff via Conform as ty does not format
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.python = { "ruff_format" }
      opts.formatters_by_ft.quarto = { "injected" }
      opts.formatters_by_ft.rmd = { "injected" }
      opts.formatters_by_ft.markdown = { "injected" }

      opts.formatters = opts.formatters or {}
      opts.formatters.ruff_format = {
        command = "ruff",
        args = function(self, ctx)
          local status, venv_config = pcall(require, "config.python_env")
          local python_path = status and venv_config.get_python_path() or nil
          local args = { "format", "--stdin-filename", "$FILENAME", "-" }
          if python_path and python_path ~= "python" then
            table.insert(args, 1, "--python")
            table.insert(args, 2, python_path)
          end
          return args
        end,
        stdin = true,
      }
      vim.g.format_on_save_enabled = vim.g.format_on_save_enabled or false
      return opts
    end,
  },
}
