return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      markdown_oxide = {
        -- Tell the LSP to run on both markdown and quarto files
        filetypes = { "markdown", "quarto" },
        root_dir = require("lspconfig.util").root_pattern(".git", "parent.lock", "flake.nix", "quarto.yml"),
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
