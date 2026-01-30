-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Disable folding and set concealment based on file location for markdown and quarto files
vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
  pattern = { "*.md", "*.rmd", "*.qmd" },
  callback = function()
    local filepath = vim.fn.expand("%:p")
    if filepath:match("Github/obsidian_notes") then
      vim.opt.conceallevel = 2 -- Obsidian files - enable UI features
    else
      vim.opt.conceallevel = 0 -- All other markdown - keep concealed text visible
    end
    vim.opt.foldmethod = "manual" -- Use manual folding, no automatic folds
    vim.opt.foldenable = false -- Ensure folding is disabled by default
  end,
})

-- 1. Define a VISIBLE background color.
-- Catppuccin Mocha Base is #1e1e2e, so we use Surface0 (#313244) to make it stand out.
-- vim.api.nvim_set_hl(0, "QuartoCodeBlock", { bg = "#2C2525" })

-- 2. Create the Autocommand
local ns_id = vim.api.nvim_create_namespace("QuartoBlockHighlight")

vim.api.nvim_create_autocmd({ "BufEnter", "TextChanged", "InsertLeave" }, {
  pattern = { "*.qmd", "*.rmd", "*.md" },
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

    -- Clear previous highlights
    vim.api.nvim_buf_clear_namespace(buf, ns_id, 0, -1)

    local in_block = false

    for i, line in ipairs(lines) do
      -- Detect fenced code block markers
      if line:match("^%s*```") then
        -- We found a fence. Highlight this line, then toggle the state.
        vim.api.nvim_buf_set_extmark(buf, ns_id, i - 1, 0, {
          line_hl_group = "QuartoCodeBlock",
          priority = 200, -- High priority to ensure it renders
        })

        -- Toggle state: If we were out, we are now in. If we were in, we are now out.
        if in_block then
          in_block = false
        else
          in_block = true
        end
      elseif in_block then
        -- Inside the block: highlight the content
        vim.api.nvim_buf_set_extmark(buf, ns_id, i - 1, 0, {
          line_hl_group = "QuartoCodeBlock",
          priority = 200,
        })
      end
    end
  end,
})

-- Prevent auto commenting for new lines
vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    -- 'o' stops continuation on o/O
    -- 'r' stops continuation on Enter
    vim.opt.formatoptions:remove({ "o", "r" })
  end,
  desc = "Disable comment continuation",
})
