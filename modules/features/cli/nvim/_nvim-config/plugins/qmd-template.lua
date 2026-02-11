local function create_quarto_note()
  local title = vim.fn.input("Note Title: ")
  if title == "" then return end
  
  -- Convert title to filename: "My Note" -> "2024-05-20-my-note.qmd"
  local date = os.date("%Y-%m-%d")
  local filename = string.lower(title:gsub(" ", "-"))
  local path = "notes/" .. date .. "-" .. filename .. ".qmd"
  
  -- Create the file with template content
  local file = io.open(path, "w")
  file:write("---\n")
  file:write("title: \"" .. title .. "\"\n")
  file:write("date: " .. date .. "\n")
  file:write("categories: [pkm]\n")
  file:write("---\n\n")
  file:close()
  
  -- Open the new file
  vim.cmd("edit " .. path)
end

-- Keymap to trigger: <leader>nn (New Note)
vim.keymap.set("n", "<leader>nn", create_quarto_note, { desc = "Create new Quarto note" })
