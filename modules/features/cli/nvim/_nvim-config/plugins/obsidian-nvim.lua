return {
  "obsidian-nvim/obsidian.nvim",
  version = "*",
  event = { "BufReadPre", "BufNewFile" },
  ft = "markdown",

  dependencies = {
    "nvim-lua/plenary.nvim",
  },

  keys = {
    { "<localleader>on", "<cmd>ObsidianNew<cr>", desc = "New Obsidian Note" },

    -- SEARCH BY FILENAME
    {
      "<localleader>of",
      function()
        local client = require("obsidian").get_client()
        -- Fallback to expanded path if client isn't fully loaded
        local dir = client and client.dir and tostring(client.dir) or vim.fn.expand("~/Github/obsidian_notes")
        require("snacks").picker.files({ dirs = { dir } })
      end,
      desc = "Find Obsidian Files",
    },

    -- SEARCH BY TEXT CONTENT
    {
      "<localleader>os",
      function()
        local client = require("obsidian").get_client()
        local dir = client and client.dir and tostring(client.dir) or vim.fn.expand("~/Github/obsidian_notes")
        require("snacks").picker.grep({ dirs = { dir } })
      end,
      desc = "Search Obsidian Text",
    },

    { "<localleader>ot", "<cmd>ObsidianToday<cr>", desc = "Today's Note" },
    { "<localleader>od", "<cmd>ObsidianDailies<cr>", desc = "Past Dailies" },
    { "<localleader>oo", "<cmd>ObsidianQuickSwitch<cr>", desc = "Quick Switch" },
  },

  ---@module 'obsidian'
  ---@type obsidian.config
  opts = {
    legacy_commands = false,

    workspaces = {
      {
        name = "personal",
        -- FIXED: Use vim.fn.expand to resolve the "~" to your actual home directory
        path = vim.fn.expand("~/Github/obsidian_notes"),
      },
      {
        name = "no-vault",
        path = function()
          return assert(vim.fs.dirname(vim.api.nvim_buf_get_name(0)))
        end,
        overrides = {
          notes_subdir = vim.NIL,
          new_notes_location = "current_dir",
          templates = { folder = vim.NIL },
          disable_frontmatter = true,
        },
      },
    },

    -- Callbacks
    callbacks = {
      enter_note = function(client, note)
        vim.keymap.set(
          "n",
          "<localleader>oc",
          "<cmd>ObsidianToggleCheckbox<cr>",
          { buffer = true, desc = "Toggle checkbox" }
        )
        vim.keymap.set("n", "<localleader>oa", function()
          require("obsidian.api").smart_action()
        end, { buffer = true, desc = "Obsidian Smart Action" })
        vim.keymap.set("n", "<Tab>", function()
          require("obsidian.api").nav_link("next")
        end, { buffer = true, desc = "Next link" })
        vim.keymap.set("n", "<S-Tab>", function()
          require("obsidian.api").nav_link("prev")
        end, { buffer = true, desc = "Prev link" })
      end,
    },

    -- Templates
    templates = {
      folder = "_templates", -- This will now join correctly with the expanded path
      date_format = "%Y-%m-%d",
      time_format = "%H:%M",
      substitutions = {
        topic = function(ctx)
          local title = ""
          if ctx.note and ctx.note.title then
            title = ctx.note.title
          elseif ctx.type == "clone_template" and ctx.partial_note then
            title = ctx.partial_note.title or ""
          end
          local parts = vim.split(title, " - ", { trimempty = true })
          if #parts >= 2 then
            return parts[2]
          else
            return title
          end
        end,
      },
    },

    cache = { enable = true },

    checkbox = {
      enabled = true,
      create_new = true,
      order = { " ", "~", "!", ">", "x" },
    },

    attachments = {
      img_folder = "assets/imgs",
      img_text_func = function(client, path)
        path = client:vault_relative_path(path) or path
        return string.format("![%s](%s)", path.name, path)
      end,
    },
  },
}
