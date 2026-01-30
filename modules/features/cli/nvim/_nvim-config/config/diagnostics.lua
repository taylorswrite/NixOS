-- File: lua/config/diagnostics.lua
-- Suppress markdown LSP warnings for better editing experience

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "qmd", "rmd" },
  callback = function()
    vim.diagnostic.config({
      virtual_text = false,
      signs = false,
      underline = false,
    }, 0) -- Apply to current buffer only
  end,
})