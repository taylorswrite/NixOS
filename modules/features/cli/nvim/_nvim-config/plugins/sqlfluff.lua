return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      -- 1. Ensure sqlfluff is assigned to the sql filetype
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.sql = { "sqlfluff" }
      opts.formatters_by_ft.mysql = { "sqlfluff" }
      opts.formatters_by_ft.plsql = { "sqlfluff" }

      -- 2. Configure the 'fix' command so it actually changes the casing
      opts.formatters = opts.formatters or {}
      opts.formatters.sqlfluff = {
        -- 'fix' is required to actually change lowercase to uppercase
        args = { "fix", "--dialect", "postgres", "-" }, 
        stdin = true,
      }
    end,
  },
}
