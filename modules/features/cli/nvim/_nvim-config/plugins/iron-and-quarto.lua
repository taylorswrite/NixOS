return {
  {
    "quarto-dev/quarto-nvim",
    dependencies = {
      "jmbuhr/otter.nvim",
      "nvim-treesitter/nvim-treesitter",
      "neovim/nvim-lspconfig",
      "hrsh7th/nvim-cmp",
      {
        "Vigemus/iron.nvim",
        config = function()
          local iron = require("iron.core")
          local view = require("iron.view")
          local common = require("iron.fts.common")

          local function get_python_command()
            local uv_lock = vim.fn.findfile("uv.lock", ".;")
            if uv_lock ~= "" then
              return { "uv", "run", "ipython", "--no-autoindent", "--no-banner" }
            else
              return { "ipython", "--no-autoindent", "--no-banner" }
            end
          end

          local function get_r_command()
            local renv_lock = vim.fn.findfile("renv.lock", ".;")
            if renv_lock ~= "" then
              local renv_dir = vim.fn.fnamemodify(renv_lock, ":h")
              return { "bash", "-c", string.format('cd "%s" && radian -q', renv_dir) }
            else
              return { "radian", "-q" }
            end
          end

          iron.setup({
            config = {
              scratch_repl = true,
              close_window_on_exit = true,
              repl_definition = {
                python = {
                  command = get_python_command,
                  format = common.bracketed_paste_python,
                  block_dividers = { "# %%", "#%%", "```{python}", "```{.python}" },
                  env = { PYTHON_BASIC_REPL = "1" },
                },
                r = { command = get_r_command, block_dividers = { "# %%", "#%%", "```{r}", "```{.r}" } },
                julia = {
                  command = { "julia", "--project=@.", "-q" },
                  block_dividers = { "# %%", "#%%", "```{julia}", "```{.julia}" },
                },
                quarto = {
                  command = function()
                    local line = vim.api.nvim_get_current_line()
                    if line:match("```{python") or line:match("```{%.python") then
                      return get_python_command()
                    elseif line:match("```{r") or line:match("```{%.r") then
                      return get_r_command()
                    elseif line:match("```{julia") or line:match("```{%.julia") then
                      return { "julia", "--project" }
                    else
                      return get_python_command()
                    end
                  end,
                  block_dividers = { "```", "```{[^}]*}" },
                },
              },
              repl_filetype = function(bufnr, ft)
                if ft == "quarto" then
                  local line = vim.api.nvim_get_current_line()
                  if line:match("```{python") or line:match("```{%.python") then
                    return "python"
                  elseif line:match("```{r") or line:match("```{%.r") then
                    return "r"
                  elseif line:match("```{julia") or line:match("```{%.julia") then
                    return "julia"
                  else
                    return "python"
                  end
                end
                return ft
              end,
              repl_open_cmd = view.split.vertical.botright("45%"),
            },
            keymaps = {
              toggle_repl = "<leader>rr",
              restart_repl = "<leader>rR",
              send_motion = "<space>sc",
              visual_send = "<space>sc",
              send_file = "<space>sf",
              send_line = "<space>sl",
              send_paragraph = "<space>sp",
              send_until_cursor = "<space>su",
              send_mark = "<space>sm",
              send_code_block = "<space>sb",
              send_code_block_and_move = "<space>sn",
              mark_motion = "<space>mc",
              mark_visual = "<space>mc",
              remove_mark = "<space>md",
              cr = "<space>s<cr>",
              interrupt = "<space>s<space>",
              exit = "<space>sq",
              clear = "<space>cl",
            },
          })
          vim.keymap.set("n", "<leader>rf", "<cmd>IronFocus<cr>")
          vim.keymap.set("n", "<leader>rh", "<cmd>IronHide<cr>")
        end,
      },
    },

    opts = {
      debug = false,
      closePreviewOnExit = true,
      lspFeatures = {
        enabled = true,
        chunks = "all",
        languages = { "r", "python", "julia", "bash", "html" },
        diagnostics = { enabled = true, triggers = { "BufWritePost" } },
        completion = { enabled = true },
      },
      codeRunner = {
        enabled = true,
        default_method = "iron",
        ft_runners = { python = "iron", r = "iron", julia = "iron" },
        never_run = { "yaml" },
      },
    },

    config = function(_, opts)
      require("quarto").setup(opts)
      local runner = require("quarto.runner")

      -- == JOB & LOG STATE ==
      local preview_job_id = 0
      local log_bufnr = -1
      local log_chan = 0

      local function ensure_log_buffer()
        if log_bufnr == -1 or not vim.api.nvim_buf_is_valid(log_bufnr) then
          log_bufnr = vim.api.nvim_create_buf(true, true)
          vim.api.nvim_buf_set_name(log_bufnr, "QuartoPreviewLog")
          vim.api.nvim_buf_set_option(log_bufnr, "filetype", "log")
          vim.api.nvim_buf_set_option(log_bufnr, "buftype", "nofile")
          log_chan = vim.api.nvim_open_term(log_bufnr, {})
        end
        return log_bufnr
      end

      local function open_log_tab_quietly()
        local buf = ensure_log_buffer()
        local current_win = vim.api.nvim_get_current_win()
        local visible = false
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          if vim.api.nvim_win_get_buf(win) == buf then
            visible = true
            break
          end
        end
        if not visible then
          vim.cmd("tab split")
          local new_win = vim.api.nvim_get_current_win()
          vim.api.nvim_win_set_buf(new_win, buf)
          vim.cmd("normal! G")
          vim.api.nvim_set_current_win(current_win)
        end
      end

      local function append_to_log(data)
        if log_chan == 0 then
          return
        end
        vim.schedule(function()
          local clean_data = table.concat(data, "\r\n")
          if #clean_data > 0 then
            pcall(vim.api.nvim_chan_send, log_chan, clean_data .. "\r\n")
            if log_bufnr ~= -1 and vim.api.nvim_buf_is_valid(log_bufnr) then
              for _, win in ipairs(vim.api.nvim_list_wins()) do
                if vim.api.nvim_win_get_buf(win) == log_bufnr then
                  vim.api.nvim_win_set_cursor(win, { vim.api.nvim_buf_line_count(log_bufnr), 0 })
                end
              end
            end
          end
        end)
      end

      -- <leader>qp: PREVIEW
      vim.keymap.set("n", "<leader>qp", function()
        if preview_job_id ~= 0 then
          vim.fn.jobstop(preview_job_id)
        end
        open_log_tab_quietly()
        append_to_log({ "[1m[34m--- STARTING PREVIEW ---[0m" })
        local filename = vim.fn.expand("%")
        local cmd = { "quarto", "preview", filename }
        preview_job_id = vim.fn.jobstart(cmd, {
          on_stdout = function(_, data)
            append_to_log(data)
          end,
          on_stderr = function(_, data)
            append_to_log(data)
          end,
          on_exit = function(_, code)
            append_to_log({ "[1m[34m--- EXITED with code " .. code .. " ---[0m" })
            preview_job_id = 0
          end,
          stdout_buffered = false,
          stderr_buffered = false,
        })
        print("Previewing " .. filename)
      end, { desc = "Quarto Preview (Log Tab)" })

      vim.keymap.set("n", "<leader>qc", function()
        if preview_job_id ~= 0 then
          vim.fn.jobstop(preview_job_id)
          preview_job_id = 0
          append_to_log({ "[1m[31m--- STOPPED MANUALLY ---[0m" })
          print("Preview stopped.")
        else
          print("No preview running.")
        end
      end, { desc = "Close Quarto Preview" })

      vim.keymap.set("n", "<leader>qP", function()
        if preview_job_id ~= 0 then
          vim.fn.jobstop(preview_job_id)
        end
        vim.cmd("w")
        open_log_tab_quietly()
        append_to_log({ "[1m[33m--- RESTARTING ---[0m" })
        local filename = vim.fn.expand("%")
        preview_job_id = vim.fn.jobstart({ "quarto", "preview", filename }, {
          on_stdout = function(_, data)
            append_to_log(data)
          end,
          on_stderr = function(_, data)
            append_to_log(data)
          end,
          on_exit = function()
            preview_job_id = 0
          end,
        })
        print("Restarted preview.")
      end, { desc = "Restart Preview" })

      vim.keymap.set("n", "<localleader>rc", runner.run_cell, { desc = "run cell", silent = true })
      vim.keymap.set("n", "<localleader>ra", runner.run_above, { desc = "run cell and above", silent = true })
      vim.keymap.set("n", "<localleader>rA", runner.run_all, { desc = "run all cells", silent = true })
      vim.keymap.set("n", "<localleader>rl", runner.run_line, { desc = "run line", silent = true })
      vim.keymap.set("v", "<localleader>r", runner.run_range, { desc = "run visual range", silent = true })
      vim.keymap.set("n", "<localleader>RA", function()
        runner.run_all(true)
      end, { desc = "run all cells of all languages", silent = true })
      vim.keymap.set(
        "n",
        "<leader>qh",
        require("quarto").searchHelp,
        { silent = true, noremap = true, desc = "Quarto Help" }
      )

      -- == WIKI LINK & TEMPLATE SYSTEM ==

      -- 1. Helper: Insert Template
      local function insert_template()
        -- Define your template directory (relative to project root)
        local template_dir = "_templates"
        local cwd = vim.fn.getcwd()
        local full_template_path = cwd .. "/" .. template_dir

        -- Check if directory exists
        if vim.fn.isdirectory(full_template_path) == 0 then
          print("Template directory not found: " .. template_dir)
          print("Create a folder named '_templates' in your project root.")
          return
        end

        -- Get all .qmd and .md files in the template directory
        local files = vim.fn.glob(full_template_path .. "/*.{qmd,md}", false, true)
        if #files == 0 then
          print("No templates found in " .. template_dir)
          return
        end

        -- Beautify list for the picker (remove full path)
        local options = {}
        for _, file in ipairs(files) do
          table.insert(options, vim.fn.fnamemodify(file, ":t"))
        end

        -- Show Picker
        vim.ui.select(options, {
          prompt = "Select Template:",
          format_item = function(item)
            return item
          end,
        }, function(choice)
          if not choice then
            return
          end

          -- Read the selected file
          local filepath = full_template_path .. "/" .. choice
          local lines = vim.fn.readfile(filepath)

          -- Perform Substitutions
          local date_str = os.date("%Y-%m-%d")
          local time_str = os.date("%H:%M")
          -- Get current buffer filename without extension for Title
          local title_str = vim.fn.expand("%:t:r")
          -- Capitalize first letter of title
          title_str = title_str:gsub("^%l", string.upper)

          local new_lines = {}
          for _, line in ipairs(lines) do
            line = line:gsub("{{date}}", date_str)
            line = line:gsub("{{time}}", time_str)
            line = line:gsub("{{title}}", title_str)
            table.insert(new_lines, line)
          end

          -- Insert at cursor
          vim.api.nvim_put(new_lines, "l", true, true)
        end)
      end

      -- 2. Helper: Follow Wiki Link
      local function follow_wiki_link()
        local line = vim.api.nvim_get_current_line()
        local col = vim.api.nvim_win_get_cursor(0)[2]

        for s, target, _, e in line:gmatch("()%[%[([^|%]]+)|?([^%]]*)%]%]()") do
          if col >= s - 1 and col < e then
            local fname = target
            local path_qmd = vim.fn.findfile(fname .. ".qmd", "**")
            local path_md = vim.fn.findfile(fname .. ".md", "**")
            local final_path = ""

            if path_qmd ~= "" then
              final_path = path_qmd
            elseif path_md ~= "" then
              final_path = path_md
            end

            if final_path ~= "" then
              vim.cmd("edit " .. final_path)
            else
              local choice = vim.fn.confirm("Note '" .. fname .. "' does not exist. Create it?", "&Yes\n&No")
              if choice == 1 then
                vim.cmd("edit " .. fname .. ".qmd")
                vim.cmd("write")
                print("Created " .. fname .. ".qmd. (Press <leader>qt to insert template)")
              end
            end
            return
          end
        end
      end

      -- == AUTOCMDS FOR QUARTO BUFFERS ==
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "quarto",
        callback = function()
          local function insert_chunk(lang)
            return function()
              vim.snippet.expand("```{" .. lang .. "}\n$0\n```")
            end
          end

          vim.keymap.set("n", "<leader>cp", insert_chunk("python"), { desc = "Insert Python Chunk", buffer = true })
          vim.keymap.set("n", "<leader>cr", insert_chunk("r"), { desc = "Insert R Chunk", buffer = true })
          vim.keymap.set("n", "<leader>cj", insert_chunk("julia"), { desc = "Insert Julia Chunk", buffer = true })

          -- WIKI LINKS
          vim.keymap.set("n", "<CR>", follow_wiki_link, { desc = "Follow Wiki Link", buffer = true })
          vim.keymap.set("n", "gf", follow_wiki_link, { desc = "Follow Wiki Link", buffer = true })

          -- TEMPLATES
          vim.keymap.set("n", "<leader>qt", insert_template, { desc = "Insert Template", buffer = true })
        end,
      })
    end,
  },
}
