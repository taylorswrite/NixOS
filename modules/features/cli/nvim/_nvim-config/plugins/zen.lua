return {
  -- Twilight: Dims inactive portions of the code
  {
    "folke/twilight.nvim",
    opts = {
      -- options here if you want to customize twilight specifically
    },
  },

  -- Zen Mode: Distraction-free coding
  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    opts = {
      plugins = {
        gitsigns = { enabled = true }, -- shows git signs
        tmux = { enabled = true }, -- disables tmux status bar if using tmux
        twilight = { enabled = true }, -- enables twilight automatically
      },
      window = {
        backdrop = 0.95, -- shade the backdrop of the Zen window
        width = 120, -- width of the Zen window
        options = {
          signcolumn = "no", -- disable signcolumn
          number = false, -- disable number column
          relativenumber = false, -- disable relative numbers
          cursorline = false, -- disable cursorline
          cursorcolumn = false, -- disable cursor column
          foldcolumn = "0", -- disable fold column
          list = false, -- disable whitespace characters
        },
      },
    },
    keys = {
      { "<leader>z", "<cmd>ZenMode<cr>", desc = "Zen Mode" },
    },
  },
}
