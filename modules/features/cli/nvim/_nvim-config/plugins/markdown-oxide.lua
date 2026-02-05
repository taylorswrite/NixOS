return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      markdown_oxide = {
        -- Tell the LSP to run on both markdown and quarto files
        filetypes = { "markdown", "quarto" },
        capabilities = {
          workspace = {
            didChangeWatchedFiles = {
              dynamicRegistration = true,
            },
          },
        },
      },
    },
  },
}
