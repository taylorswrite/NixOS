return {
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  ft = { "markdown" },
  build = function()
    vim.fn["mkdp#util#install"]()
  end,
  config = function()
    -- Set up markdown preview configuration
    vim.g.mkdp_auto_start = 0
    vim.g.mkdp_auto_close = 1
    vim.g.mkdp_refresh_slow = 0
    vim.g.mkdp_command_for_global = 0
    vim.g.mkdp_open_to_the_world = 0
    vim.g.mkdp_open_ip = ""
    vim.g.mkdp_browser = ""
    vim.g.mkdp_echo_preview_url = 1
    vim.g.mkdp_browserfunc = ""
    
    -- Preview options
    vim.g.mkdp_preview_options = {
      mkit = {},
      katex = {},
      uml = {},
      maid = {},
      disable_sync_scroll = 0,
      sync_scroll_type = "middle",
      hide_yaml_meta = 1,
      sequence_diagrams = {},
      flowchart_diagrams = {},
      content_editable = false,
      disable_filename = 0,
      toc = {}
    }
    
    -- File types that will trigger MarkdownPreview
    vim.g.mkdp_filetypes = { "markdown" }
    
    -- Theme (dark or light)
    vim.g.mkdp_theme = "dark"
    
    -- Custom CSS (optional)
    vim.g.mkdp_markdown_css = ""
    vim.g.mkdp_highlight_css = ""
    
    -- Port (empty for random)
    vim.g.mkdp_port = ""
    
    -- Page title format
    vim.g.mkdp_page_title = "「${name}」"
    
    -- Images path
    vim.g.mkdp_images_path = ""
  end,
}