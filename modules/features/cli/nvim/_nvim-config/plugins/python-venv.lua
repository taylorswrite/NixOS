return {
  -- 1. LSP: Keep this strictly for Python files
  -- (Use the 'quarto-nvim' plugin for LSP in .qmd/.md files instead)
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}

      opts.servers.pyright = {
        settings = {
          python = {
            analysis = {
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = "openFilesOnly",
              typeCheckingMode = "basic",
            },
          },
        },
        before_init = function(_, config)
          -- Safely check if our custom module exists before calling it
          local status, venv_config = pcall(require, "config.python_env")
          if status then
            local python_path = venv_config.get_python_path()
            if python_path then
              config.settings.python.pythonPath = python_path
            end
          end
        end,
        on_attach = function(client, _)
          -- Disable pyright LSP formatting to avoid conflicts with conform.nvim
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false
        end,
      }

      opts.servers.ruff = {
        on_attach = function(client, _)
          client.server_capabilities.hoverProvider = false
          -- Disable ruff LSP formatting to avoid conflicts with conform.nvim
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false
        end,
      }
      return opts
    end,
  },

  -- 2. Virtual environment selector: Enable for Python + Markdown types
  {
    "linux-cultist/venv-selector.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-telescope/telescope.nvim",
    },
    -- LOAD ON: Python, Quarto, RMarkdown, Markdown
    ft = { "python", "quarto", "rmd", "markdown" },
    keys = {
      -- REMOVE 'ft' restriction here so the hotkey works in all files
      { "<leader>cv", "<cmd>:VenvSelect<cr>", desc = "Select VirtualEnv" },
    },
    opts = {
      options = {
        notify_user_on_venv_activation = true,
        enable_cached_venvs = true,
        cached_venv_automatic_activation = true,
      },
      search = {
        cwd = {
          command = "fd '/bin/python$' $CWD --full-path --color never -E /proc -I -a -L",
        },
      },
    },
  },

  -- 3. Formatting: Use "injected" for mixed-content files with format-on-save toggle
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}

      -- Pure Python files use Ruff directly
      opts.formatters_by_ft.python = { "ruff_format" }

      -- Mixed content files use "injected"
      -- This tells Conform to parse the file, find python blocks,
      -- and format ONLY those blocks using the 'python' formatter defined above.
      opts.formatters_by_ft.quarto = { "injected" }
      opts.formatters_by_ft.rmd = { "injected" }
      opts.formatters_by_ft.markdown = { "injected" }

      opts.formatters = opts.formatters or {}
      opts.formatters.ruff_format = {
        command = "ruff",
        args = function(self, ctx)
          -- Safely check for custom module
          local status, venv_config = pcall(require, "config.python_env")
          local python_path = nil
          if status then
            python_path = venv_config.get_python_path()
          end

          local args = { "format", "--stdin-filename", "$FILENAME", "-" }

          if python_path and python_path ~= "python" then
            table.insert(args, 1, "--python")
            table.insert(args, 2, python_path)
          end

          return args
        end,
        stdin = true,
      }

      -- Initialize format-on-save global state (defaults to disabled)
      vim.g.format_on_save_enabled = vim.g.format_on_save_enabled or false

      return opts
    end,
  },
}
