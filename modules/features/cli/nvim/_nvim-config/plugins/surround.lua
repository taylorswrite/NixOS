return {
  {
    "nvim-mini/mini.surround",
    -- opts = {} tells lazy.nvim to automatically call require("mini.surround").setup()
    opts = {
      mappings = {
        add = "gsa",            -- Add surrounding: gsaiw"
        delete = "gsd",         -- Delete: gsd"
        find = "gsf",           -- Find right
        find_left = "gsF",      -- Find left
        highlight = "gsh",      -- Highlight
        replace = "gsr",        -- Replace: gsr"'
        update_n_lines = "gsn", 
      },
    },
  },
}
