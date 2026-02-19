return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters = {
        sqlfluff = {
          -- This tells conform to just run the command regardless of a root file
          cwd = require("conform.util").root_file({ ".sqlfluff", "pyproject.toml", ".git" }),
          require_cwd = false, 
          -- Ensure it uses 'fix' and a dialect, otherwise it won't capitalize
          args = { "fix", "--dialect", "postgres", "-" },
        },
      },
      formatters_by_ft = {
        sql = { "sqlfluff" },
      },
    },
  },
}
