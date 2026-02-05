return {
  "akinsho/bufferline.nvim",
  opts = {
    highlights = {
      -- 1. Set the empty space (fill) to match the main background
      fill = {
        bg = "#1e1e2e",
      },
      
      -- 2. "Undim" inactive tabs: Make them use the same background 
      --    and a bright foreground so they don't look faded.
      background = {
        bg = "#1e1e2e",
        fg = "#9399b2", -- Overlay1 (or use #cdd6f4 for full brightness)
      },
      
      -- 3. Ensure visible (but not focused) tabs match
      buffer_visible = {
        bg = "#1e1e2e",
        fg = "#9399b2",
      },
      
      -- 4. Active tab styling
      buffer_selected = {
        bg = "#1e1e2e",
        bold = true,
        italic = true,
      },
      
      -- 5. Fix separators to blend in (removing the "cutout" look)
      separator = {
        fg = "#1e1e2e",
        bg = "#1e1e2e",
      },
      separator_selected = {
        fg = "#1e1e2e",
        bg = "#1e1e2e",
      },
      separator_visible = {
        fg = "#1e1e2e",
        bg = "#1e1e2e",
      },
      
      -- 6. Ensure modified indicators match the background
      modified = {
        bg = "#1e1e2e",
      },
      modified_visible = {
        bg = "#1e1e2e",
      },
      modified_selected = {
        bg = "#1e1e2e",
      },
      
      -- 7. Handle Close Buttons
      close_button = {
        bg = "#1e1e2e",
      },
      close_button_visible = {
        bg = "#1e1e2e",
      },
      close_button_selected = {
        bg = "#1e1e2e",
      },
    },
  },
}
