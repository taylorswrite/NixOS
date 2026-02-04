-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- lua/config/keymaps.lua

vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Prevents crashes if the file has a swap file (E325) or is already open
-- Helper function to safely open a file in a vertical split
local function safe_vsplit(filepath)
  -- 1. Check if the buffer is already loaded in the current session
  local bufnr = vim.fn.bufnr(filepath)
  if bufnr ~= -1 and vim.fn.bufloaded(bufnr) == 1 then
    vim.cmd("vsplit")
    vim.cmd("buffer " .. bufnr)
    return
  end

  -- 2. If not loaded, try to open it safely
  local ok, err = pcall(function()
    vim.cmd("vsplit " .. filepath)
  end)

  if not ok then
    vim.notify("Could not open paired file (Swap file exists?):\n" .. err, vim.log.levels.WARN)
  end
end

-- Helper to run jupytext commands
local function run_jupytext(args, format, desc)
  local current_file = vim.fn.expand("%:p")
  local cmd = "jupytext " .. args .. " " .. vim.fn.shellescape(current_file)
  local output = vim.fn.system(cmd)

  if vim.v.shell_error == 0 then
    vim.notify(desc .. " successful.", vim.log.levels.INFO)

    -- Jupytext always overwrites/creates files based on the primary file.
    local paired_file

    if format == "py" then
      paired_file = current_file:gsub(".ipynb", ".py")
    elseif format == "qmd" then
      paired_file = current_file:gsub(".ipynb", ".qmd")
    elseif format == "sync" then
      -- For sync, we reload to ensure we see latest contents
      vim.cmd("e!")
      return
    end

    -- Logic to open the paired file or switch back to notebook
    if paired_file then
      -- CASE 1: Opening the generated file (Forward: .ipynb -> .py)
      if vim.fn.filereadable(paired_file) == 1 then
        safe_vsplit(paired_file)
      else
        -- CASE 2: Switching back to notebook (Reverse: .py -> .ipynb)
        -- If we were in the .py file and synced, we might want to see the .ipynb
        local notebook_file = current_file:gsub(".py", ".ipynb"):gsub(".qmd", ".ipynb")

        if notebook_file ~= current_file and vim.fn.filereadable(notebook_file) == 1 then
          safe_vsplit(notebook_file)
        else
          -- Fallback: just reload current buffer
          vim.cmd("e!")
        end
      end
    end
  else
    vim.notify("Error: " .. output, vim.log.levels.ERROR)
  end
end

-- --- Jupytext Keymaps ---

-- 1. Pair current Notebook with Python (Percent format)
vim.keymap.set("n", "<leader>jP", function()
  run_jupytext("--set-formats ipynb,py:percent", "py", "Pairing with .py")
end, { desc = "Pair .ipynb with .py" })

-- 2. Pair current Notebook with Quarto
vim.keymap.set("n", "<leader>jQ", function()
  run_jupytext("--set-formats ipynb,qmd", "qmd", "Pairing with .qmd")
end, { desc = "Pair .ipynb with .qmd" })

-- 3. Sync (Update paired files based on timestamp)
vim.keymap.set("n", "<leader>js", function()
  run_jupytext("--sync", "sync", "Syncing paired files")
end, { desc = "Jupytext Sync" })

-- 4. Insert Jupytext Cell Marker and Newline
vim.keymap.set("n", "<leader>jj", function()
  local ft = vim.bo.filetype
  if ft == "python" or ft == "markdown" or ft == "qmd" then
    vim.cmd([[normal! o# %%]])
    vim.cmd([[normal! o]])
  else
    vim.notify("Not a recommended filetype for Jupytext cell markers.", vim.log.levels.WARN)
  end
end, { desc = "Insert Jupytext Cell (# %%)" })

-- --- Format-on-Save Keymaps ---

-- Toggle format-on-save for current buffer or globally
vim.keymap.set("n", "<leader>cf", function()
  -- Initialize the global state if it doesn't exist
  if vim.g.format_on_save_enabled == nil then
    vim.g.format_on_save_enabled = false
  end
  
  -- Toggle the state
  vim.g.format_on_save_enabled = not vim.g.format_on_save_enabled
  local state = vim.g.format_on_save_enabled and "enabled" or "disabled"
  local level = vim.g.format_on_save_enabled and vim.log.levels.INFO or vim.log.levels.WARN
  local icon = vim.g.format_on_save_enabled and "⚡" or "⏸️"
  vim.notify(icon .. " Format-on-save " .. state, level)
  
  -- Update autocmds
  if vim.g.format_on_save_enabled then
    -- Clear any existing format-on-save autocmds first
    pcall(vim.api.nvim_del_augroup_by_name, "FormatOnSave")
    vim.api.nvim_create_augroup("FormatOnSave", { clear = true })
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = "FormatOnSave",
      pattern = { "*.py", "*.qmd", "*.rmd", "*.md" },
      callback = function(args)
        local ft = vim.bo[args.buf].filetype
        vim.notify("🔧 Formatting " .. ft .. " file before save...", vim.log.levels.DEBUG)
        local success, err = pcall(require("conform").format, {
          buf = args.buf,
          lsp_fallback = false, -- Don't use LSP fallback to avoid double formatting
          timeout_ms = 500,
        })
        if not success then
          vim.notify("Formatting error: " .. tostring(err), vim.log.levels.ERROR)
        end
      end,
      desc = "Format on save",
    })
    vim.notify("✅ Format-on-save autocmd created", vim.log.levels.DEBUG)
  else
    -- Try to delete the augroup, but don't error if it doesn't exist
    local ok, err = pcall(vim.api.nvim_del_augroup_by_name, "FormatOnSave")
    if not ok and not err:match("No such group") then
      -- Only log errors that aren't "No such group"
      vim.notify("Error disabling format-on-save: " .. err, vim.log.levels.ERROR)
    else
      vim.notify("⏸️ Format-on-save autocmd removed", vim.log.levels.DEBUG)
    end
  end
end, { desc = "Toggle format-on-save" })

-- Format current buffer manually (one-time formatting)
vim.keymap.set("n", "<leader>cF", function()
  require("conform").format({
    buf = vim.api.nvim_get_current_buf(),
    lsp_fallback = true,
    timeout_ms = 500,
  })
  vim.notify("Buffer formatted", vim.log.levels.INFO)
end, { desc = "Format buffer" })

-- Show current format-on-save status
vim.keymap.set("n", "<leader>cS", function()
  local enabled = vim.g.format_on_save_enabled or false
  local state = enabled and "enabled" or "disabled"
  vim.notify("Format-on-save is currently " .. state, vim.log.levels.INFO)
end, { desc = "Show format-on-save status" })

-- --- Markdown Preview Keymaps ---

-- Toggle markdown preview
vim.keymap.set("n", "<leader>mp", "<Plug>MarkdownPreviewToggle", { desc = "Toggle Markdown Preview" })
vim.keymap.set("n", "<leader>ms", "<Plug>MarkdownPreviewStop", { desc = "Stop Markdown Preview" })
vim.keymap.set("n", "<leader>mo", "<Plug>MarkdownPreview", { desc = "Start Markdown Preview" })

-- Additional convenient mappings
vim.keymap.set("i", "<C-m>", "<Plug>MarkdownPreviewToggle", { desc = "Toggle Markdown Preview (Insert)" })
