-- ~/.config/nvim/lua/config/python_env.lua

local M = {}

--- Returns the path to the currently active virtual environment's python executable.
--- This path is set globally by venv-selector.nvim when an environment is selected.
function M.get_python_path()
  -- venv-selector sets this global variable in the nvim environment when a venv is activated.
  local python_path = vim.g.venv_selected_path

  if python_path then
    -- The venv_selected_path is typically the path to the bin/python executable itself.
    -- Example: "/path/to/project/.venv/bin/python"
    return python_path
  end

  -- Fallback to the default 'python' if no venv is active
  return "python"
end

return M
