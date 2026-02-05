return {
  "saghen/blink.cmp",
  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = function(_, opts)
    -- 1. Create the Snacks toggle
    local completion_toggle = Snacks.toggle({
      name = "Completion",
      get = function()
        -- Default to true if the variable hasn't been set yet
        return vim.g.completion ~= false
      end,
      set = function(state)
        vim.g.completion = state
      end,
    })

    -- 2. Define the toggle behavior
    local function toggle_completion()
      completion_toggle:toggle()
      if vim.g.completion == false then
        require("blink.cmp").hide()
      end
    end

    -- 3. Set the keymap
    vim.keymap.set({ "i", "n" }, "<leader>uM", toggle_completion, { desc = "Toggle Completion" })

    -- 4. Merge your existing settings
    opts.keymap = {
      preset = "super-tab",
    }

    -- 5. Set the enabled condition
    opts.enabled = function()
      return vim.g.completion ~= false
    end

    return opts
  end,
}
