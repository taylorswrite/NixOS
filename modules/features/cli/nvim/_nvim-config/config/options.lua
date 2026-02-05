-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.relativenumber = true
vim.opt.colorcolumn = "72,80"

-- Global concealment settings
vim.opt.concealcursor = ""
vim.g.maplocalleader = ","

-- Custom Bracket and Brace Indent
vim.opt.cindent = true

local function copy(lines, _)
  require('vim.ui.clipboard.osc52').copy('+')(lines)
end

local function paste()
  return require('vim.ui.clipboard.osc52').paste('+')()
end

vim.g.clipboard = {
  name = 'osc52',
  copy = {
    ['+'] = copy,
    ['*'] = copy,
  },
  paste = {
    ['+'] = paste,
    ['*'] = paste,
  },
}

-- Use system clipboard
vim.opt.clipboard = 'unnamedplus'

-- Format-on-save status indicator function
function _G.format_on_save_status()
  local enabled = vim.g.format_on_save_enabled or false
  if enabled then
    return "⚡FMT"
  else
    return ""
  end
end

-- =========================================
-- Persistent Toggle Defaults
-- =========================================
vim.g.autoformat = false         -- <leader>uf (Format on Save)
vim.g.snacks_animate = true      -- <leader>ua (Animations)
vim.g.completion = true          -- <C-q>      (Completion) [!IMPORTANT] Added this
vim.opt.spell = false            -- <leader>us (Spelling)
vim.opt.wrap = false             -- <leader>uw (Wrap)
vim.diagnostic.config({ virtual_text = false }) -- Uncomment to disable diagnostic text
