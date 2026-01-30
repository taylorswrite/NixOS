return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- Ensure quarto and related parsers are installed
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, {
          "quarto",
          "nix",
          "markdown",
          "markdown_inline",
          "python",
          "r",
          "julia",
          "bash",
          "yaml",
        })
      end
      
      -- Disable concealment for treesitter highlighting
      opts.highlight = opts.highlight or {}
      opts.highlight.disable = { "conceal" }
    end,
  },
}
