return {
  {
    "tpope/vim-dadbod",
    dependencies = {
      "kristijanhusak/vim-dadbod-ui",
      "kristijanhusak/vim-dadbod-completion",
    },
    -- Global keymaps to open/toggle the UI
    keys = {
      { "<leader>dbu", "<cmd>DBUIToggle<cr>", desc = "Toggle Dadbod UI" },
      { "<leader>dbf", "<cmd>DBUIFindBuffer<cr>", desc = "Find Current Buffer in UI" },
      { "<leader>dbr", "<cmd>DBUIRenameBuffer<cr>", desc = "Rename Current DB Buffer" },
      { "<leader>dbl", "<cmd>DBUILastQueryInfo<cr>", desc = "Last Query Info" },
    },
    init = function()
      -- Your existing config
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_show_database_icon = 1
      vim.g.db_ui_win_index = 0
      vim.g.db_ui_save_queries_state = 0 -- Keeps <leader>w free for LazyVim

      -- Buffer-specific maps for SQL files
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "sql", "mysql", "plsql" },
        callback = function()
          vim.keymap.set("n", "<leader>dbs", "<Plug>(DBUI_ExecuteQuery)", { buffer = true, desc = "Execute Query" })
          vim.keymap.set("n", "<leader>dbw", "<Plug>(DBUI_SaveQuery)", { buffer = true, desc = "Save Query to Dadbod" })
          vim.keymap.set("n", "<leader>dbp", "vip<Plug>(DBUI_ExecuteQuery)", { buffer = true, desc = "Execute Paragraph" })
        end,
      })
    end,
  },
}
